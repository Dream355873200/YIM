// selftest: 调度系统端到端自检 —— 对每个任务制造"待补偿"现场, 用真实任务
// 执行一轮, 用 SQL 验证效果。前置: MySQL 在跑; comet 不在跑不影响断言
// (扫描补偿的推送目标无连接 → 落离线箱, 恰好也验证防线2)。
package main

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/yim/internal/sched"
	"github.com/yim/internal/store"
)

func runSelftest(tasks []sched.Task, db *store.MySQL) {
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	defer cancel()

	type cleanupFn func()
	var cleanups []cleanupFn
	defer func() {
		for _, c := range cleanups {
			c()
		}
	}()

	pass := 0
	fail := 0
	run := func(name string, fn func(ctx context.Context) error) {
		start := time.Now()
		if err := fn(ctx); err != nil {
			fail++
			fmt.Printf("  [FAIL] %-52s %v\n", name, err)
			return
		}
		pass++
		fmt.Printf("  [PASS] %-52s (%dms)\n", name, time.Since(start).Milliseconds())
	}

	fmt.Println("==== yim-sched selftest ====")

	// ---- 公共现场: 找一条真实消息 + 一个真实会话 ----
	msg, err := pickMessage(ctx, db)
	if err != nil {
		fmt.Printf("  [SKIP] 找不到任何 message 行 (先跑 comet selftest 造数据): %v\n", err)
		fmt.Printf("==== %d passed, %d failed, skipped ====\n", pass, fail)
		return
	}

	// ---- 1. local_message 扫描补偿 (防线3) ----
	run("scan: 残留 local_message 被重投并闭环", func(ctx context.Context) error {
		shardDB := db.ShardDB(store.MsgShard{DBIndex: msg.dbIndex})
		// 同主键可能有历史行, 清掉再造现场 (dev 库, 该行只是投递登记)
		if _, err := shardDB.ExecContext(ctx,
			"DELETE FROM local_message WHERE conv_id=? AND msg_id=?", msg.convID, msg.msgID); err != nil {
			return err
		}
		old := time.Now().Add(-3 * time.Minute).UnixMilli() // 须超过 scanGrace(60s)
		if _, err := shardDB.ExecContext(ctx,
			"INSERT INTO local_message (msg_id, conv_id, status, create_time_ms) VALUES (?,?,0,?)",
			msg.msgID, msg.convID, old); err != nil {
			return fmt.Errorf("seed: %w", err)
		}
		if err := execAllShards(ctx, tasks, "local-msg-scan"); err != nil {
			return err
		}
		// 闭环标记走 markBatcher 异步攒批 (≤50ms + goroutine 调度), 轮询等它落地
		var status int
		deadline := time.Now().Add(2 * time.Second)
		for {
			if err := shardDB.QueryRowContext(ctx,
				"SELECT status FROM local_message WHERE conv_id=? AND msg_id=?",
				msg.convID, msg.msgID).Scan(&status); err != nil {
				return fmt.Errorf("row vanished: %w", err)
			}
			if status == 1 || time.Now().After(deadline) {
				break
			}
			time.Sleep(50 * time.Millisecond)
		}
		if status != 1 {
			return fmt.Errorf("status=%d, want 1 (scan did not close the loop)", status)
		}
		return nil
	})

	// ---- 2. offline_box 对账: 超期条目被关闭 ----
	run("offline-box: 超期登记被标已补偿", func(ctx context.Context) error {
		uid := int64(99999001) // 无连接的合成 uid: PushAll 必然不 delivered → 走超期关闭分支
		old := time.Now().Add(-8 * 24 * time.Hour).UnixMilli()
		if _, err := db.Meta.ExecContext(ctx,
			"INSERT INTO offline_box (uid, conv_id, msg_id, seq, status, create_time_ms) VALUES (?,?,0,1,0,?)",
			uid, msg.convID, old); err != nil {
			return fmt.Errorf("seed: %w", err)
		}
		cleanups = append(cleanups, func() {
			_, _ = db.Meta.ExecContext(context.Background(), "DELETE FROM offline_box WHERE uid=?", uid)
		})
		if err := execAllShards(ctx, tasks, "offline-box-reconcile"); err != nil {
			return err
		}
		var status int
		if err := db.Meta.QueryRowContext(ctx,
			"SELECT status FROM offline_box WHERE uid=?", uid).Scan(&status); err != nil {
			return err
		}
		if status != 1 {
			return fmt.Errorf("status=%d, want 1 (expired entry not closed)", status)
		}
		return nil
	})

	// ---- 3. 未读数对账: last_seq 落后被追平 ----
	run("unread: 落后的 conv.last_seq 被单调追平", func(ctx context.Context) error {
		var orig int64
		if err := db.Meta.QueryRowContext(ctx,
			"SELECT last_seq FROM conversations WHERE conv_id=?", msg.convID).Scan(&orig); err != nil {
			return fmt.Errorf("no conv row: %w", err)
		}
		if _, err := db.Meta.ExecContext(ctx,
			"UPDATE conversations SET last_seq=? WHERE conv_id=?", orig-3, msg.convID); err != nil {
			return err
		}
		if err := execAllShards(ctx, tasks, "unread-reconcile"); err != nil {
			return err
		}
		var now int64
		if err := db.Meta.QueryRowContext(ctx,
			"SELECT last_seq FROM conversations WHERE conv_id=?", msg.convID).Scan(&now); err != nil {
			return err
		}
		if now < orig {
			return fmt.Errorf("last_seq=%d, want >= %d (reconcile did not catch up)", now, orig)
		}
		return nil
	})

	// ---- 4. 布隆重建信号 ----
	run("bloom-rebuild: 信号发布成功", func(ctx context.Context) error {
		return execAllShards(ctx, tasks, "bloom-rebuild")
	})

	// ---- 5. local_message 清理 ----
	run("cleanup: 已投递且过期的登记被删除", func(ctx context.Context) error {
		old := time.Now().Add(-8 * 24 * time.Hour).UnixMilli()
		shardDB := db.ShardDB(store.MsgShard{DBIndex: msg.dbIndex})
		if _, err := shardDB.ExecContext(ctx,
			"INSERT INTO local_message (msg_id, conv_id, status, create_time_ms) VALUES (999001,?,1,?)",
			msg.convID, old); err != nil {
			return fmt.Errorf("seed: %w", err)
		}
		if err := execAllShards(ctx, tasks, "local-msg-cleanup"); err != nil {
			return err
		}
		var n int
		if err := shardDB.QueryRowContext(ctx,
			"SELECT COUNT(*) FROM local_message WHERE msg_id=999001 AND conv_id=?", msg.convID).Scan(&n); err != nil {
			return err
		}
		if n != 0 {
			return fmt.Errorf("row survived cleanup")
		}
		return nil
	})

	fmt.Printf("==== %d passed, %d failed ====\n", pass, fail)
	if fail > 0 {
		fmt.Println("SELFTEST FAILED")
	} else {
		fmt.Println("SELFTEST ALL PASS")
	}
}

// execAllShards 找到任务并在其全部分片上各执行一次 (真实执行体, 不 mock)。
func execAllShards(ctx context.Context, tasks []sched.Task, name string) error {
	for _, t := range tasks {
		if t.Name() != name {
			continue
		}
		for _, shard := range t.Shards() {
			sctx, cancel := context.WithTimeout(ctx, 15*time.Second)
			err := t.Exec(sctx, shard)
			cancel()
			if err != nil {
				return fmt.Errorf("shard %s: %w", shard, err)
			}
		}
		return nil
	}
	return fmt.Errorf("task %q not registered", name)
}

type msgRef struct {
	convID, msgID int64
	dbIndex       int
}

// pickMessage 跨库找一条真实消息 (扫描补偿的重建事件需要真实 seq/from_uid)。
func pickMessage(ctx context.Context, db *store.MySQL) (msgRef, error) {
	for dbIndex := 0; dbIndex < store.MsgDBCount; dbIndex++ {
		for t := 0; t < store.MsgTablePerDB; t++ {
			tbl := fmt.Sprintf("message_%02d", t)
			var m msgRef
			m.dbIndex = dbIndex
			err := db.ShardDB(store.MsgShard{DBIndex: dbIndex}).QueryRowContext(ctx,
				fmt.Sprintf("SELECT conv_id, msg_id FROM %s LIMIT 1", tbl)).Scan(&m.convID, &m.msgID)
			if err == sql.ErrNoRows {
				continue
			}
			if err != nil {
				return msgRef{}, err
			}
			return m, nil
		}
	}
	return msgRef{}, fmt.Errorf("no message rows in any shard")
}
