// revoke.go (里程碑13): 消息撤回。
//
// 实现 = 校验 + 复用 SendMessage 写一条 MSG_REVOKE 消息:
//   校验: 只能撤自己的消息, 时间窗 2 分钟, 已撤过的直接幂等返回
//   载体: MSG_REVOKE 走正常发送链路 (seq/推送/recent/幂等全套),
//         对端经由既有推送路径收到撤回事实, 无需新协议
// 原消息行保留在库里 (撤回是"追加事实"不是"改写历史"), 客户端按
// ext.ref_msg_id 隐藏原行。
package message

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
)

// RevokeWindow 撤回时间窗: 发出后 2 分钟内可撤。
const RevokeWindow = 2 * time.Minute

var ErrRevokeDenied = errors.New("revoke denied")

// RevokeMessage 校验并写 MSG_REVOKE 消息, 返回撤回消息自身 (msg_id, seq)。
// client_msg_id = 原消息 msg_id: 同一条消息重复撤回天然幂等 (与真实客户端
// cmid 的时间戳<<16 空间不重叠)。
func (s *Service) RevokeMessage(ctx context.Context, msgID, convID, opUID int64) (int64, int64, error) {
	shard := store.RouteMsg(convID)
	db := s.db.ShardDB(shard)

	var fromUID int64
	var ts int64
	err := db.QueryRowContext(ctx, fmt.Sprintf(
		"SELECT from_uid, server_time_ms FROM %s WHERE msg_id = ? AND conv_id = ?",
		shard.Table()), msgID, convID).Scan(&fromUID, &ts)
	if errors.Is(err, sql.ErrNoRows) {
		return 0, 0, fmt.Errorf("message %d not found", msgID)
	}
	if err != nil {
		return 0, 0, fmt.Errorf("load message: %w", err)
	}
	if fromUID != opUID {
		return 0, 0, ErrRevokeDenied
	}
	if time.Since(time.UnixMilli(ts)) > RevokeWindow {
		return 0, 0, fmt.Errorf("revoke window (%v) exceeded", RevokeWindow)
	}

	// 已撤过: 幂等返回原撤回消息
	var dup int64
	err = db.QueryRowContext(ctx, fmt.Sprintf(
		"SELECT msg_id FROM %s WHERE conv_id = ? AND msg_type = 10 AND content LIKE ? LIMIT 1",
		shard.Table()), convID, fmt.Sprintf(`%%"refMsgId":"%d"%%`, msgID)).Scan(&dup)
	if err == nil {
		var seq int64
		if err := db.QueryRowContext(ctx, fmt.Sprintf(
			"SELECT seq FROM %s WHERE msg_id = ?", shard.Table()), dup).Scan(&seq); err == nil {
			return dup, seq, nil
		}
	}

	content := &yim.ConvMsgContent{
		Type: yim.MsgType_MSG_REVOKE,
		Ext:  &yim.Ext{RefMsgId: msgID, OpUid: opUID},
	}
	return s.SendMessage(ctx, msgID, convID, opUID, content)
}
