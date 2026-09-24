// eventprobe: 一次性诊断工具 — 实测 PRESENCE 上/下线事件的端到端延迟。
// 场景: B (90004) 挂在线收事件; A (90003) 反复 连接/断开 (模拟登录/退出/重登),
// 打印 B 每收到一帧的时间戳, 人工对比 A 动作时刻与事件到达时刻。
package main

import (
	"fmt"
	"net"
	"time"

	"github.com/yim/internal/comet"
	"github.com/yim/internal/config"
	"github.com/yim/kitex_gen/yim"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		panic(err)
	}

	// B: 观察者, 收 CMD_EVENT 打时间戳
	b := dialProbe(cfg, "dev.90004", "probe-b")
	go func() {
		for {
			f, err := b.s.ReadFrame()
			if err != nil {
				fmt.Println("B read err:", err)
				return
			}
			if f.Cmd == yim.Command_CMD_EVENT {
				ev := f.GetEvent()
				fmt.Printf("B %s  EVENT type=%s uid=%d online=%v\n",
					time.Now().Format("15:04:05.000"), ev.GetType(), ev.GetUid(), ev.GetOnline())
			}		}
	}()

	time.Sleep(500 * time.Millisecond) // 等 B 就绪

	for round := 1; round <= 3; round++ {
		t0 := time.Now()
		a := dialProbe(cfg, "dev.90003", fmt.Sprintf("probe-a-%d", round))
		fmt.Printf("A %s  CONNECT (round %d)\n", t0.Format("15:04:05.000"), round)
		time.Sleep(3 * time.Second)
		t1 := time.Now()
		a.c.Close() // 模拟退出
		fmt.Printf("A %s  CLOSE\n", t1.Format("15:04:05.000"))
		time.Sleep(3 * time.Second)
	}
	fmt.Println("probe done")
}

func dialProbe(cfg *config.Config, token, device string) *probeClient {
	c, err := net.DialTimeout("tcp", cfg.CometTCP, 3*time.Second)
	if err != nil {
		panic(err)
	}
	pc := &probeClient{c: c, s: comet.NewTCPStream(c)}
	_ = pc.s.WriteFrame(&yim.Frame{FrameId: 1, Cmd: yim.Command_CMD_CONNECT,
		Payload: &yim.Frame_Connect{Connect: &yim.ConnectReq{
			Token:  token,
			Device: &yim.DeviceInfo{Type: yim.DeviceType_DEVICE_DESKTOP, DeviceId: device},
		}}})
	return pc
}

type probeClient struct {
	c net.Conn
	s *comet.TCPStream
}
