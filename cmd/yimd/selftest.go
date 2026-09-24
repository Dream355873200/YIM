// selftest: 端到端验证 网关→etcd发现→Kitex RPC→幂等→分片落库 链路。
// 用户/会话种子数据直连 Meta 库 —— 测试脚手架, 不属于业务链路;
// ID 分配则走 Seq Svc RPC, 与业务同源。
package main

import (
	"context"
	"fmt"

	"github.com/cloudwego/kitex/client"
	etcd "github.com/kitex-contrib/registry-etcd"
	"go.uber.org/zap"

	"github.com/yim/internal/config"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/store"
	"github.com/yim/kitex_gen/yim"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	seqservice "github.com/yim/kitex_gen/yim/seqservice"
)

func runSelftest(cfg *config.Config, msgCli messageservice.Client) {
	ctx := context.Background()
	db, err := store.OpenMySQL(ctx, cfg.MySQLDSN)
	if err != nil {
		logger.L.Fatal("open mysql", zap.Error(err))
	}
	defer db.Close()

	resolver, err := etcd.NewEtcdResolver(cfg.EtcdEndpoints)
	if err != nil {
		logger.L.Fatal("etcd resolver", zap.Error(err))
	}
	seqCli, err := seqservice.NewClient("yim.seq", client.WithResolver(resolver))
	if err != nil {
		logger.L.Fatal("kitex client yim.seq", zap.Error(err))
	}

	// 造两个用户 (INSERT IGNORE 幂等)
	allocID := func(biz string) int64 {
		rsp, err := seqCli.AllocId(ctx, &yim.AllocIdReq{Biz: biz, KeyId: 0, Count: 1})
		if err != nil {
			logger.L.Fatal("alloc "+biz, zap.Error(err))
		}
		return rsp.Start
	}
	uid1, uid2 := allocID("uid"), allocID("uid")
	for _, u := range []int64{uid1, uid2} {
		// nickname 唯一键 (里程碑5): 带 uid 保证重复自检不冲突
		if _, err := db.Meta.ExecContext(ctx,
			"INSERT IGNORE INTO users (uid, nickname) VALUES (?, ?)", u, fmt.Sprintf("dev-%d", u)); err != nil {
			logger.L.Fatal("insert user", zap.Error(err))
		}
	}

	// 建一个单聊会话
	convID := allocID("conv_id")
	if _, err := db.Meta.ExecContext(ctx, fmt.Sprintf(
		"INSERT INTO conversations (conv_id, type, member_uids) VALUES (?, 1, JSON_ARRAY(%d, %d))",
		uid1, uid2), convID); err != nil {
		logger.L.Fatal("insert conv", zap.Error(err))
	}

	shard := store.RouteMsg(convID)
	logger.L.Info("selftest: conv routed",
		zap.Int64("conv_id", convID),
		zap.String("shard", shard.QualifiedName()),
	)

	content := &yim.ConvMsgContent{
		Type: yim.MsgType_MSG_TEXT,
		Text: "hello yim",
	}

	// 同一 client_msg_id 发两次, 第二次必须命中幂等 (返回相同 msg_id/seq)
	const clientMsgID = 9876543210
	rsp1, err := msgCli.SendMessage(ctx, &yim.SendMessageReq{
		ClientMsgId: clientMsgID, ConvId: convID, FromUid: uid1, Content: content,
	})
	if err != nil {
		logger.L.Fatal("send#1", zap.Error(err))
	}
	rsp2, err := msgCli.SendMessage(ctx, &yim.SendMessageReq{
		ClientMsgId: clientMsgID, ConvId: convID, FromUid: uid1, Content: content,
	})
	if err != nil {
		logger.L.Fatal("send#2 (idempotent)", zap.Error(err))
	}

	// 再发一条新消息, 验证 seq 单调递增
	rsp3, err := msgCli.SendMessage(ctx, &yim.SendMessageReq{
		ClientMsgId: clientMsgID + 1, ConvId: convID, FromUid: uid2, Content: content,
	})
	if err != nil {
		logger.L.Fatal("send#3", zap.Error(err))
	}

	logger.L.Info("selftest result",
		zap.Int64("conv_id", convID),
		zap.Int64("send1_msg_id", rsp1.MsgId), zap.Int64("send1_seq", rsp1.Seq),
		zap.Int64("send2_msg_id", rsp2.MsgId), zap.Int64("send2_seq", rsp2.Seq),
		zap.Int64("send3_msg_id", rsp3.MsgId), zap.Int64("send3_seq", rsp3.Seq),
		zap.Bool("idempotent_ok", rsp1.MsgId == rsp2.MsgId && rsp1.Seq == rsp2.Seq),
		zap.Bool("seq_monotonic", rsp3.Seq > rsp1.Seq),
	)
}
