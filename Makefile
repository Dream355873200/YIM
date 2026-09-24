PROTO_DIR := api/proto
GOPATH_BIN := $(shell go env GOPATH)/bin
KITEX := $(GOPATH_BIN)/kitex
export KITEX_TOOL_USE_PROTOC := 1

SERVICES := service_message service_seq service_comet service_router service_logic service_job service_relation

.PHONY: proto proto-dart build run tidy

# 契约变更后重新生成: kitex_gen/yim (pb + client/server wrapper)
proto:
	@for f in $(SERVICES); do \
		$(KITEX) -module github.com/yim -I $(PROTO_DIR) $(PROTO_DIR)/$$f.proto; \
	done
	@echo "proto generated -> kitex_gen/yim"

# Flutter 客户端契约 (Phase 6): Frame/Connect/Push 等线上协议 + 消息域模型。
# 需要 protoc-gen-dart (dart pub global activate protoc_plugin)。
# 不生成 *_pbgrpc: 客户端走 HTTP 网关 + TCP 长连接, 不直连 gRPC。
proto-dart:
	protoc -I $(PROTO_DIR) --dart_out=clients/yim_app/lib/gen \
		$(PROTO_DIR)/common.proto $(PROTO_DIR)/message.proto $(PROTO_DIR)/protocol.proto
	@echo "dart proto generated -> clients/yim_app/lib/gen"

build:
	go build -o bin/yimd.exe ./cmd/yimd
	go build -o bin/yim-message.exe ./cmd/yim-message
	go build -o bin/yim-seq.exe ./cmd/yim-seq
	go build -o bin/yim-comet.exe ./cmd/yim-comet
	go build -o bin/yim-logic.exe ./cmd/yim-logic
	go build -o bin/yim-job.exe ./cmd/yim-job
	go build -o bin/yim-sched.exe ./cmd/yim-sched
	go build -o bin/yim-relation.exe ./cmd/yim-relation

run: build
	./bin/yim-seq.exe &
	./bin/yim-logic.exe &
	./bin/yim-message.exe &
	./bin/yim-job.exe &
	./bin/yim-comet.exe &
	./bin/yim-sched.exe &
	./bin/yim-relation.exe &
	./bin/yimd.exe

tidy:
	go mod tidy
