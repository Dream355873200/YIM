// readstate.go: 已读状态查询 (READ 事件的拉取兜底)。
//
// READ 瞬态信令只在 MarkRead 那一刻发给在线对端 —— 对端在拉取之前读过的
// 水位没有事件可推, 客户端进窗时调这里补齐, 否则"对方先读过"永远不显示已读。
// read_seq 存 user_conv_state (MarkRead 写入), 读走 Redis 热键 miss 回 DB。
package message

import (
	"context"

	"github.com/yim/kitex_gen/yim"
)

func (s *Service) GetReadState(ctx context.Context, opUID, convID int64) ([]*yim.ReadState, *yim.Error) {
	// 成员校验 fail-close: 与 PullHistory 同款, 非成员 (code 25) 不泄露他人水位
	meta, err := s.cache.GetConvMeta(ctx, s.db, convID)
	if err != nil {
		return nil, &yim.Error{Code: 1, Msg: "conv not found"}
	}
	isMember := false
	for _, m := range meta.MemberUIDs {
		if m == opUID {
			isMember = true
			break
		}
	}
	if !isMember {
		return nil, &yim.Error{Code: 25, Msg: "not a member of this conversation"}
	}
	out := make([]*yim.ReadState, 0, len(meta.MemberUIDs))
	for _, m := range meta.MemberUIDs {
		out = append(out, &yim.ReadState{Uid: m, ReadSeq: s.getReadSeq(ctx, m, convID)})
	}
	return out, nil
}
