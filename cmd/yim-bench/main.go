// yim-bench: 真实链路压测 (里程碑7)。
//
// 不 mock 任何环节: HTTP 网关 → message → seq → Kafka → job → comet →
// TCP 客户端收 PUSH + 回 ACK, 全部走生产路径 (与 comet selftest 同款客户端)。
//
// 拓扑: users 个用户各持一条 TCP 长连接在线 (CONNECT 一次验签 + 心跳 +
// 收推回 ACK); convs 个单聊会话 (相邻用户配对, 单聊扇出=1, 度量干净);
// 发送端以 rate/s 经 HTTP 网关发 total 条消息。
//
// 指标:
//
//	send = HTTP 发送往返 (网关→message 落库应答)
//	e2e  = 发起发送 → 对端收到 MESSAGE_PUSH (含 Kafka/Job/Comet 全链路)
//	投递率 = 窗口内收到 push 的消息 / 发送成功的消息
//
// 用法:
//
//	bin/yim-bench.exe -users 50 -convs 25 -total 5000 -rate 200
package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"sort"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/yim/internal/comet"
	"github.com/yim/kitex_gen/yim"
)

func main() {
	httpAddr := flag.String("http", "127.0.0.1:8080", "gateway HTTP addr")
	tcpAddr := flag.String("tcp", "127.0.0.1:8900", "comet TCP addr")
	users := flag.Int("users", 50, "online users (one TCP conn each)")
	convs := flag.Int("convs", 25, "single-chat conversations (adjacent user pairs)")
	total := flag.Int("total", 5000, "total messages to send")
	rate := flag.Int("rate", 200, "target send rate (msg/s)")
	workers := flag.Int("workers", 32, "concurrent HTTP senders")
	payload := flag.Int("payload", 64, "message text size (bytes)")
	wait := flag.Duration("wait", 30*time.Second, "max wait for delivery after sends")
	ack := flag.Bool("ack", true, "reply ACK on push (false = never ACK: 全量重试风暴, 压定时器)")
	ackBatchMs := flag.Int("ack-batch-ms", 100, "per-conv watermark ACK flush interval (ms); 0 = 每条 push 一帧 ACK (对照)")
	flag.Parse()

	debugPush = os.Getenv("YIM_BENCH_DEBUG") == "1"

	if *users < 2 || *convs < 1 || *total < 1 || *rate < 1 {
		fmt.Fprintln(os.Stderr, "invalid flags")
		os.Exit(2)
	}

	b := &bench{
		httpBase:   "http://" + *httpAddr,
		tcpAddr:    *tcpAddr,
		payload:    strings.Repeat("y", *payload),
		salt:       time.Now().UnixNano(), // client_msg_id 跨 run 隔离, 不撞历史幂等键
		ack:        *ack,
		ackBatchMs: *ackBatchMs,
		tokens:     map[int64]string{},
		pending:    map[pushKey]time.Time{},
		leftover:   map[pushKey]time.Time{},
	}
	// 连接池对齐 workers: DefaultTransport 的 MaxIdleConnsPerHost=2 会让高并发
	// 请求反复建连, Windows 临时端口 (~14k) 耗尽后 dial 报 bind 错 (同 job 侧教训)
	http.DefaultTransport.(*http.Transport).MaxIdleConnsPerHost = *workers + 16
	http.DefaultTransport.(*http.Transport).MaxIdleConns = (*workers + 16) * 2
	b.run(*users, *convs, *total, *rate, *workers, *wait)
}

// ============================================================
// 指标收集
// ============================================================

type pushKey struct{ convID, seq int64 }

var debugPush bool

type bench struct {
	httpBase   string
	tcpAddr    string
	payload    string
	salt       int64
	ack        bool
	ackBatchMs int

	mu       sync.Mutex
	pending  map[pushKey]time.Time // (conv, seq) → 发起发送时刻, push 到达时消费
	leftover map[pushKey]time.Time // push 赢了 HTTP 应答的乱序缓存 (同机时钟无偏差, 仅竞争窗口)
	sendLat  []float64             // ms
	e2eLat   []float64             // ms
	tokens   map[int64]string      // uid → JWT (里程碑9 网关鉴权: 发送按 token 身份)

	sent, sendErr, delivered, pushErr atomic.Int64
	msgSeq                            atomic.Int64
}

// onPush TCP 收到 MESSAGE_PUSH: 配到 pending 就记 e2e; 配不到 (push 先于
// HTTP 应答回来) 进乱序缓存, 等应答侧注册时回头消费。delivered 计所有收到的推。
// YIM_BENCH_DEBUG=1 时打印慢样本 (>500ms) 供跨日志 (comet/job) 逐条关联。
func (b *bench) onPush(convID, seq int64, now time.Time) {
	b.delivered.Add(1)
	b.mu.Lock()
	key := pushKey{convID, seq}
	if start, ok := b.pending[key]; ok {
		delete(b.pending, key)
		b.e2eLat = append(b.e2eLat, ms(now.Sub(start)))
		b.mu.Unlock()
		if d := now.Sub(start); d > 500*time.Millisecond && debugPush {
			fmt.Printf("SLOW push conv=%d seq=%d arrive=%s e2e=%s\n",
				convID, seq, now.Format("15:04:05.000"), d.Round(time.Millisecond))
		}
		return
	}
	b.leftover[key] = now
	b.mu.Unlock()
}

// onSendRsp HTTP 应答到达: 记 send 延迟, 注册 pending, 先查乱序缓存。
func (b *bench) onSendRsp(convID, seq int64, start time.Time) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.sendLat = append(b.sendLat, ms(time.Since(start)))
	key := pushKey{convID, seq}
	if recv, ok := b.leftover[key]; ok {
		delete(b.leftover, key)
		b.e2eLat = append(b.e2eLat, ms(recv.Sub(start)))
		return
	}
	b.pending[key] = start
}

func ms(d time.Duration) float64 { return float64(d.Microseconds()) / 1000.0 }

// ============================================================
// 主流程
// ============================================================

type convPair struct {
	convID    int64
	senderUID int64 // 固定一端发送: 推送目标恒为另一端, 扇出=1
}

type user struct {
	uid   int64
	token string
	conn  *clientConn
}

func (b *bench) run(nUsers, nConvs, total, rate, workers int, wait time.Duration) {
	fmt.Printf("==== YIM bench ====\n")
	fmt.Printf("config: users=%d convs=%d total=%d rate=%d/s workers=%d\n",
		nUsers, nConvs, total, rate, workers)

	// 1. 注册 + 登录 (已存在走登录)
	us := make([]*user, nUsers)
	for i := 0; i < nUsers; i++ {
		u, err := b.ensureUser(fmt.Sprintf("bench_u%d", i))
		if err != nil {
			fmt.Printf("FATAL: ensure user %d: %v\n", i, err)
			os.Exit(1)
		}
		us[i] = u
	}
	fmt.Printf("users ready: uid %d..%d\n", us[0].uid, us[nUsers-1].uid)

	// 2. 建单聊会话 (相邻配对 u[i] ↔ u[i+1], 发送者取 u[i])
	cps := make([]convPair, nConvs)
	for i := 0; i < nConvs; i++ {
		a, c := us[i%nUsers], us[(i+1)%nUsers]
		convID, err := b.ensureConv(a.uid, c.uid)
		if err != nil {
			fmt.Printf("FATAL: ensure conv %d: %v\n", i, err)
			os.Exit(1)
		}
		cps[i] = convPair{convID: convID, senderUID: a.uid}
	}
	fmt.Printf("convs ready: %d (first %v)\n", nConvs, cps[:min(nConvs, 3)])

	// 3. 全员上线
	for i, u := range us {
		c, err := b.connect(*u, fmt.Sprintf("bench-dev-%d", i))
		if err != nil {
			fmt.Printf("FATAL: connect user %d: %v\n", i, err)
			os.Exit(1)
		}
		u.conn = c
	}
	fmt.Printf("all %d users online\n", nUsers)
	defer func() {
		for _, u := range us {
			u.conn.close()
		}
	}()

	// 4. 限速发送: 50ms 粗 tick × 每 tick 批量派发。
	// 教训 (里程碑8): 每条一个 tick 的写法在 Windows 上被 ticker 精度地板
	// (~500µs) 限死 2000/s —— 三轮"系统瓶颈"追查后才发现是测量工具自己。
	// 粗 tick 批量派发的平均速率精确, 只引入 ±tick 的节奏抖动 (对吞吐测量无害)。
	start := time.Now()
	jobs := make(chan convPair, 4096)
	var wg sync.WaitGroup
	for w := 0; w < workers; w++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for cp := range jobs {
				b.sendOne(cp)
			}
		}()
	}
	const tick = 50 * time.Millisecond
	perTick := int64(rate) * int64(tick) / int64(time.Second)
	if perTick < 1 {
		perTick = 1
	}
	ticker := time.NewTicker(tick)
	defer ticker.Stop()
	dispatched := 0
	for dispatched < total {
		n := perTick
		if left := int64(total - dispatched); left < n {
			n = left
		}
		for j := int64(0); j < n; j++ {
			jobs <- cps[dispatched%len(cps)]
			dispatched++
		}
		<-ticker.C
	}
	close(jobs)
	wg.Wait()
	elapsed := time.Since(start)

	// 5. 等投递收敛 (在途消息走完 Kafka/Job/Comet)
	deadline := time.Now().Add(wait)
	for time.Now().Before(deadline) {
		if b.delivered.Load() >= b.sent.Load() {
			break
		}
		time.Sleep(200 * time.Millisecond)
	}
	settle := time.Since(start)

	b.report(total, rate, elapsed, settle)
}

// sendOne 发一条消息: client_msg_id 全局唯一 (盐+序号), start 在请求前取,
// 应答回来后注册 (conv, seq) 供 push 侧匹配 e2e。
// 里程碑9: 身份 = 发送者 token (网关 JWT 注入 from_uid, body 里的 from_uid 仅存档)。
func (b *bench) sendOne(cp convPair) {
	cmid := b.salt + b.msgSeq.Add(1)
	start := time.Now()
	var rsp sendRsp
	err := b.post("/api/v1/messages", b.tokens[cp.senderUID], map[string]any{
		"client_msg_id": cmid,
		"conv_id":       cp.convID,
		"from_uid":      cp.senderUID,
		"content":       map[string]any{"type": "MSG_TEXT", "text": b.payload},
	}, &rsp)
	if err != nil || rsp.Err != nil {
		b.sendErr.Add(1)
		return
	}
	seq, err := rsp.Seq.Int64()
	if err != nil {
		b.sendErr.Add(1)
		return
	}
	b.sent.Add(1)
	b.onSendRsp(cp.convID, seq, start)
}

// ============================================================
// HTTP 客户端 (标准库, JSON snake_case 与网关 protojson 输出一致)
// ============================================================

func (b *bench) post(path, token string, in, out any) error {
	body, _ := json.Marshal(in)
	req, err := http.NewRequest("POST", b.httpBase+path, bytes.NewReader(body))
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token) // 里程碑9: 网关 JWT 鉴权
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	raw, _ := io.ReadAll(resp.Body)
	if resp.StatusCode != 200 {
		return fmt.Errorf("HTTP %d: %s", resp.StatusCode, string(raw))
	}
	return json.Unmarshal(raw, out)
}

type apiErr struct {
	Msg string `json:"msg"`
}

// 网关响应是 protojson (UseProtoNames): int64 输出为 JSON 字符串, 用 json.Number 接
type loginRsp struct {
	Token string      `json:"token"`
	Uid   json.Number `json:"uid"`
	Err   *apiErr     `json:"error"`
}
type convRsp struct {
	Conv struct {
		ConvId json.Number `json:"conv_id"`
	} `json:"conv"`
	Err *apiErr `json:"error"`
}
type sendRsp struct {
	MsgId json.Number `json:"msg_id"`
	Seq   json.Number `json:"seq"`
	Err   *apiErr     `json:"error"`
}

// ensureUser 注册失败 (重名) 落回登录 —— 幂等的用户准备。
func (b *bench) ensureUser(nick string) (*user, error) {
	_ = b.post("/api/v1/register", "", map[string]any{
		"nickname": nick, "password": "bench-pass-123"}, &map[string]any{})
	var lr loginRsp
	if err := b.post("/api/v1/login", "", map[string]any{
		"nickname": nick, "password": "bench-pass-123"}, &lr); err != nil {
		return nil, fmt.Errorf("login: %w", err)
	}
	if lr.Err != nil {
		return nil, fmt.Errorf("login: %s", lr.Err.Msg)
	}
	uid, err := lr.Uid.Int64()
	if err != nil {
		return nil, fmt.Errorf("login uid %q: %w", lr.Uid, err)
	}
	b.mu.Lock()
	b.tokens[uid] = lr.Token
	b.mu.Unlock()
	return &user{uid: uid, token: lr.Token}, nil
}

// ensureConv 单聊去重: 重复创建返回同一 conv_id (already_exist)。
func (b *bench) ensureConv(a, c int64) (int64, error) {
	// 好友种子 (里程碑9): 单聊好友校验 fail-close —— 相邻对先结为好友。
	// 跨轮复用用户时已是好友 → "already friends" 视为种子成功
	if err := b.seedFriend(a, c); err != nil {
		return 0, err
	}
	var cr convRsp
	if err := b.post("/api/v1/conversations", b.tokens[a],
		map[string]any{"type": "CONV_SINGLE", "member_uids": []int64{a, c}}, &cr); err != nil {
		return 0, err
	}
	if cr.Err != nil {
		return 0, fmt.Errorf("%s", cr.Err.Msg)
	}
	return cr.Conv.ConvId.Int64()
}

// seedFriend a→c 申请 + c 同意, 走真实 HTTP 链路 (与客户端同路径)。
func (b *bench) seedFriend(a, c int64) error {
	if err := b.post("/api/v1/friend/requests", b.tokens[a],
		map[string]any{"to_uid": c, "message": "bench"}, &map[string]any{}); err != nil {
		if strings.Contains(err.Error(), "already friends") {
			return nil
		}
		return fmt.Errorf("friend request %d->%d: %w", a, c, err)
	}
	return b.post(fmt.Sprintf("/api/v1/friend/requests/%d", a), b.tokens[c],
		map[string]any{"action": "accept"}, &map[string]any{})
}

// ============================================================
// TCP 客户端 (复用 comet.TCPStream 帧编解码, 与真实客户端同路径)
// ============================================================

type clientConn struct {
	c    net.Conn
	s    *comet.TCPStream
	b    *bench
	ab   *ackBatcher // 非 nil = 水位攒批形态; nil = 逐条 ACK
	done chan struct{}
}

func (b *bench) connect(u user, device string) (*clientConn, error) {
	c, err := net.DialTimeout("tcp", b.tcpAddr, 3*time.Second)
	if err != nil {
		return nil, err
	}
	if tc, ok := c.(*net.TCPConn); ok {
		_ = tc.SetNoDelay(true) // ACK 小帧不走 Nagle, 与服务端对称
	}
	s := comet.NewTCPStream(c)
	if err := s.WriteFrame(&yim.Frame{Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  u.token,
			Device: &yim.DeviceInfo{Type: yim.DeviceType_DEVICE_DESKTOP, DeviceId: device},
		}}}); err != nil {
		c.Close()
		return nil, fmt.Errorf("write connect: %w", err)
	}
	rsp, err := s.ReadFrame()
	if err != nil {
		c.Close()
		return nil, fmt.Errorf("read connect rsp: %w", err)
	}
	if rsp.Cmd != yim.Command_CMD_CONNECT_RSP || rsp.GetError() != nil {
		c.Close()
		return nil, fmt.Errorf("connect rejected: %v", rsp.GetError())
	}

	cc := &clientConn{c: c, s: s, b: b, done: make(chan struct{})}
	if b.ack && b.ackBatchMs > 0 {
		cc.ab = newAckBatcher(cc)
		go cc.ab.flusher(b.ackBatchMs)
	}
	go cc.reader()
	go cc.heartbeat()
	return cc, nil
}

// reader 收帧循环: MESSAGE_PUSH 记 e2e + 回确认 (真实客户端行为, 不给重推
// 淹没指标的机会)。攒批形态报"每会话连续水位" (16.5-③), 对照形态逐条回。
func (cc *clientConn) reader() {
	for {
		f, err := cc.s.ReadFrame()
		if err != nil {
			return // 停机/断连
		}
		if f.Cmd == yim.Command_CMD_MESSAGE_PUSH {
			p := f.GetMessagePush()
			cc.b.onPush(p.GetConvId(), p.GetMaxSeq(), time.Now())
			if cc.b.ack {
				if cc.ab != nil {
					if first := cc.ab.observe(p.GetConvId(), p.GetMaxSeq()); first {
						cc.ab.sendWatermark(p.GetConvId()) // 会话首条立即播种
					}
				} else {
					_ = cc.s.WriteFrame(&yim.Frame{Cmd: yim.Command_CMD_ACK,
						Payload: &yim.Frame_Ack{Ack: &yim.Ack{
							ConvId: p.GetConvId(), AckSeq: p.GetMaxSeq(),
							Target: yim.AckTarget_ACK_FOR_PUSH}}})
				}
			}
		}
	}
}

func (cc *clientConn) heartbeat() {
	t := time.NewTicker(30 * time.Second)
	defer t.Stop()
	for {
		select {
		case <-t.C:
			if cc.s.WriteFrame(&yim.Frame{Cmd: yim.Command_CMD_HEARTBEAT,
				Payload: &yim.Frame_Heartbeat{Heartbeat: &yim.Heartbeat{}}}) != nil {
				return
			}
		case <-cc.done:
			return
		}
	}
}

func (cc *clientConn) close() {
	select {
	case <-cc.done:
	default:
		close(cc.done)
	}
	cc.c.Close()
}

// ============================================================
// ACK 攒批 (16 里程碑 16.5-③, 服务端零改动)
// ============================================================

// ackBatcher push 确认攒批: 逐条"每 PUSH 一帧 ACK" → "每会话连续水位 100ms
// 一帧"。服务端 Ack.ack_seq 本就是累积语义 (<=ack_seq 全部已收到,
// pendingAcks.ack 遍历删除), 攒批只是降发送频率, 线格式零改动 —— ACK 帧量
// ≈ 会话数×10/s 而不是消息速率, comet AckPush RPC / yim.ack topic 同比例降。
//
// 正确性: 水位只报连续前缀 (seq==wm+1 才推进, 乱序进 stash 等补洞), 不会把
// 没收到的 seq 确认掉; 攒批周期 << retryDelays[0]=1s (确认回路 RTT 上界),
// 正常消息不会因攒批先触发重推。会话首条立即播种 (水位=首条 seq): 兼容跨轮
// 复用的会话 (seq 延续上轮), 避免水位从 0 起永远追不上。
type ackBatcher struct {
	cc *clientConn

	mu    sync.Mutex
	seen  map[int64]bool               // conv_id → 是否已播种
	wm    map[int64]int64              // conv_id → 连续已收水位
	stash map[int64]map[int64]struct{} // conv_id → 乱序暂存 (seq > wm+1)
	dirty map[int64]bool
}

func newAckBatcher(cc *clientConn) *ackBatcher {
	return &ackBatcher{
		cc:    cc,
		seen:  make(map[int64]bool),
		wm:    make(map[int64]int64),
		stash: make(map[int64]map[int64]struct{}),
		dirty: make(map[int64]bool),
	}
}

// observe 记一条已收 push, 返回 true = 会话首条 (调用方立即播种)。
func (ab *ackBatcher) observe(convID, seq int64) bool {
	ab.mu.Lock()
	defer ab.mu.Unlock()
	if !ab.seen[convID] {
		ab.seen[convID] = true
		ab.wm[convID] = seq
		return true
	}
	wm := ab.wm[convID]
	switch {
	case seq <= wm:
		// 重复推送 (重试与 ACK 竞速), 已确认
	case seq == wm+1:
		wm = seq
		if g := ab.stash[convID]; g != nil {
			for {
				if _, ok := g[wm+1]; !ok {
					break
				}
				wm++
				delete(g, wm)
			}
			if len(g) == 0 {
				delete(ab.stash, convID)
			}
		}
		ab.wm[convID] = wm
		ab.dirty[convID] = true
	default:
		g := ab.stash[convID]
		if g == nil {
			g = make(map[int64]struct{})
			ab.stash[convID] = g
		}
		g[seq] = struct{}{}
	}
	return false
}

// sendWatermark 立即发一帧水位 ACK (播种用)。
func (ab *ackBatcher) sendWatermark(convID int64) {
	ab.mu.Lock()
	seq := ab.wm[convID]
	ab.mu.Unlock()
	_ = ab.cc.s.WriteFrame(&yim.Frame{Cmd: yim.Command_CMD_ACK,
		Payload: &yim.Frame_Ack{Ack: &yim.Ack{ConvId: convID, AckSeq: seq,
			Target: yim.AckTarget_ACK_FOR_PUSH}}})
}

// flushAll 把脏会话的当前水位各发一帧 (一 conv 一帧顶 N 条)。
func (ab *ackBatcher) flushAll() {
	ab.mu.Lock()
	if len(ab.dirty) == 0 {
		ab.mu.Unlock()
		return
	}
	snap := make(map[int64]int64, len(ab.dirty))
	for c := range ab.dirty {
		snap[c] = ab.wm[c]
	}
	ab.dirty = make(map[int64]bool)
	ab.mu.Unlock()
	for conv, seq := range snap {
		_ = ab.cc.s.WriteFrame(&yim.Frame{Cmd: yim.Command_CMD_ACK,
			Payload: &yim.Frame_Ack{Ack: &yim.Ack{ConvId: conv, AckSeq: seq,
				Target: yim.AckTarget_ACK_FOR_PUSH}}})
	}
}

func (ab *ackBatcher) flusher(intervalMs int) {
	t := time.NewTicker(time.Duration(intervalMs) * time.Millisecond)
	defer t.Stop()
	for {
		select {
		case <-t.C:
			ab.flushAll()
		case <-ab.cc.done:
			ab.flushAll() // 收尾冲一次在途水位
			return
		}
	}
}

// ============================================================
// 报表
// ============================================================

func (b *bench) report(total, rate int, elapsed, settle time.Duration) {
	pct := func(v []float64, p float64) string {
		if len(v) == 0 {
			return "n/a"
		}
		s := append([]float64(nil), v...)
		sort.Float64s(s)
		return fmt.Sprintf("%6.1fms", s[min(len(s)-1, int(float64(len(s))*p))])
	}
	sent, del := b.sent.Load(), b.delivered.Load()
	ratio := 0.0
	if sent > 0 {
		ratio = float64(del) / float64(sent) * 100
	}
	fmt.Printf("\n==== report ====\n")
	fmt.Printf("sent=%d ok=%d http_err=%d\n", total, sent, b.sendErr.Load())
	fmt.Printf("delivered=%d (%.2f%%)\n", del, ratio)
	fmt.Printf("send elapsed=%s (avg %.1f msg/s)\n", elapsed.Round(time.Millisecond),
		float64(sent)/elapsed.Seconds())
	fmt.Printf("delivery settle=%s\n", settle.Round(time.Millisecond))
	fmt.Printf("send (HTTP)  latency: p50=%s p95=%s p99=%s\n",
		pct(b.sendLat, 0.50), pct(b.sendLat, 0.95), pct(b.sendLat, 0.99))
	fmt.Printf("e2e delivery latency: p50=%s p95=%s p99=%s\n",
		pct(b.e2eLat, 0.50), pct(b.e2eLat, 0.95), pct(b.e2eLat, 0.99))
	if remain := sent - del; remain > 0 {
		fmt.Printf("WARNING: %d messages undelivered within window (offline box / retry pending?)\n", remain)
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
