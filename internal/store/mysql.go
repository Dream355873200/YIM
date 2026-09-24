package store

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/go-sql-driver/mysql"
)

// MySQL 元库 + N 个分片消息库的连接池集合。
// 每分片库独立连接池: 单分片慢查询不会占满全局连接。
type MySQL struct {
	Meta   *sql.DB
	msgDBs []*sql.DB
}

// OpenMySQL dsnBase 形如 "root:root@tcp(127.0.0.1:3306)/any?charset=utf8mb4&parseTime=true&loc=Local",
// 库名部分被替换为 yim_msg_{0..N-1} 与 yim_meta。
func OpenMySQL(ctx context.Context, dsnBase string) (*MySQL, error) {
	cfg, err := mysql.ParseDSN(dsnBase)
	if err != nil {
		return nil, fmt.Errorf("parse dsn: %w", err)
	}

	open := func(dbName string) (*sql.DB, error) {
		c := *cfg
		c.DBName = dbName
		db, err := sql.Open("mysql", c.FormatDSN())
		if err != nil {
			return nil, err
		}
		// MaxIdle == MaxOpen: 高并发下池扩到上限后不再回收空闲连接,
		// 否则 load 波动时每秒开/关成百上千连接, Windows 动态端口仅 ~14k
		// (netsh int ipv4 show dynamicport), TIME_WAIT 堆积后 dial 报
		// "bind: An invalid argument was supplied" (2000/s 压测实测)。
		db.SetMaxOpenConns(64)
		db.SetMaxIdleConns(64)
		db.SetConnMaxLifetime(30 * time.Minute)
		if err := db.PingContext(ctx); err != nil {
			return nil, fmt.Errorf("ping %s: %w", dbName, err)
		}
		return db, nil
	}

	m := &MySQL{msgDBs: make([]*sql.DB, MsgDBCount)}
	if m.Meta, err = open("yim_meta"); err != nil {
		return nil, err
	}
	for i := range m.msgDBs {
		if m.msgDBs[i], err = open(fmt.Sprintf("yim_msg_%d", i)); err != nil {
			return nil, err
		}
	}
	return m, nil
}

// ShardDB 取分片库连接池
func (m *MySQL) ShardDB(s MsgShard) *sql.DB { return m.msgDBs[s.DBIndex] }

// Close 关闭全部连接池
func (m *MySQL) Close() {
	_ = m.Meta.Close()
	for _, db := range m.msgDBs {
		_ = db.Close()
	}
}
