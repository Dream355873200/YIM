// HTTP API: 网关层只做协议转换 (HTTP JSON ↔ proto) + Kitex RPC 转发。
// 请求/响应结构与 gRPC 契约保持 snake_case 一致。
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/cloudwego/hertz/pkg/app"
	"github.com/cloudwego/hertz/pkg/app/server"
	"go.uber.org/zap"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"

	"github.com/yim/internal/config"
	"github.com/yim/internal/logger"
	"github.com/yim/internal/middleware"
	"github.com/yim/kitex_gen/yim"
	logicservice "github.com/yim/kitex_gen/yim/logicservice"
	messageservice "github.com/yim/kitex_gen/yim/messageservice"
	relationservice "github.com/yim/kitex_gen/yim/relationservice"
)

// writeProto 统一 protojson 响应 (UseProtoNames: 字段名与 .proto 定义一致)。
func writeProto(c *app.RequestContext, code int, m proto.Message) {
	b, err := protojson.MarshalOptions{UseProtoNames: true}.Marshal(m)
	if err != nil {
		logger.L.Error("marshal proto response", zap.Error(err))
		writeErr(c, 500, "marshal response")
		return
	}
	c.Data(code, "application/json; charset=utf-8", b)
}

// writeErr 参数级错误; RPC/内部错误一律 500 不外泄细节。
func writeErr(c *app.RequestContext, code int, msg string) {
	c.JSON(code, map[string]string{"error": msg})
}

// registerRoutes 挂载业务路由。
// 里程碑9: uid/op_uid 一律取 JWT 中间件注入的身份, body 同名字段不可信;
// 业务错误码 (Error.code) 按来源映射 HTTP 状态 (22/25 类 403, 其余 400)。
func registerRoutes(hz *server.Hertz, msgCli messageservice.Client, logicCli logicservice.Client, relCli relationservice.Client, cfg *config.Config) {
	api := hz.Group("/api/v1")

	// 注册/登录 (里程碑5): Logic Svc RPC 转发, 密码不出网关
	api.POST("/register", func(ctx context.Context, c *app.RequestContext) {
		var req yim.RegisterReq
		opts := protojson.UnmarshalOptions{DiscardUnknown: true}
		if opts.Unmarshal(c.Request.Body(), &req) != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		if req.Nickname == "" || req.Password == "" {
			writeErr(c, 400, "nickname and password are required")
			return
		}
		rsp, err := logicCli.Register(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("register rpc", zap.Error(err))
			writeErr(c, 500, "register failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	api.POST("/login", func(ctx context.Context, c *app.RequestContext) {
		var req yim.LoginReq
		opts := protojson.UnmarshalOptions{DiscardUnknown: true}
		if opts.Unmarshal(c.Request.Body(), &req) != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		if req.Nickname == "" || req.Password == "" {
			writeErr(c, 400, "nickname and password are required")
			return
		}
		rsp, err := logicCli.Login(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("login rpc", zap.Error(err))
			writeErr(c, 500, "login failed")
			return
		}
		if rsp.GetError() != nil {
			// 统一口径的凭据错误: 401, 不泄露具体原因
			writeErr(c, 401, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 发消息 (幂等: 同 client_msg_id 重放返回同一 msg_id/seq)
	// 请求体用 protojson 解析: 枚举收字符串 ("MSG_TEXT"), encoding/json 做不到
	// 安全 (里程碑9): from_uid 由 JWT 中间件注入的身份覆盖 —— body 里传谁都不算数
	api.POST("/messages", func(ctx context.Context, c *app.RequestContext) {
		var req yim.SendMessageReq
		opts := protojson.UnmarshalOptions{DiscardUnknown: true}
		if err := opts.Unmarshal(c.Request.Body(), &req); err != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		if req.Content == nil || req.ClientMsgId == 0 || req.ConvId == 0 {
			writeErr(c, 400, "client_msg_id, conv_id, content are required")
			return
		}
		req.FromUid = middleware.UID(c)

		rsp, err := msgCli.SendMessage(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("send message", zap.Error(err),
				zap.Int64("conv_id", req.ConvId), zap.Uint64("client_msg_id", req.ClientMsgId))
			writeErr(c, 500, "send message failed")
			return
		}
		logger.C(ctx).Info("message sent",
			zap.Int64("msg_id", rsp.MsgId), zap.Int64("seq", rsp.Seq), zap.Int64("conv_id", req.ConvId))
		writeProto(c, 200, rsp)
	})

	// 撤回: POST /messages/revoke {conv_id, msg_id} (只能撤自己 2 分钟内的,
	// 服务端校验; 成功 = 落一条 MSG_REVOKE 消息走正常推送)
	api.POST("/messages/revoke", func(ctx context.Context, c *app.RequestContext) {
		var body struct {
			ConvID int64 `json:"conv_id,string"` // 客户端约定: int64 一律字符串 (protojson 兼容)
			MsgID  int64 `json:"msg_id,string"`
		}
		if err := json.Unmarshal(c.Request.Body(), &body); err != nil || body.ConvID == 0 || body.MsgID == 0 {
			writeErr(c, 400, "conv_id and msg_id required")
			return
		}
		rsp, err := msgCli.RevokeMessage(ctx, &yim.RevokeMessageReq{
			MsgId: body.MsgID, ConvId: body.ConvID, OpUid: int64(middleware.UID(c)),
		})
		if err != nil {
			logger.C(ctx).Error("revoke message rpc", zap.Error(err))
			writeErr(c, 500, "revoke failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 全文搜索: GET /messages/search?keyword= (MSG_TEXT LIKE, 时间倒序, 顶 20)
	api.GET("/messages/search", func(ctx context.Context, c *app.RequestContext) {
		kw := c.Query("keyword")
		if strings.TrimSpace(kw) == "" {
			writeErr(c, 400, "keyword query required")
			return
		}
		rsp, err := msgCli.SearchMessages(ctx, &yim.SearchMessagesReq{
			Uid:     int64(middleware.UID(c)),
			Keyword: kw,
		})
		if err != nil {
			logger.C(ctx).Error("search messages rpc", zap.Error(err))
			writeErr(c, 500, "search failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 建会话: type="single"|"group" (缺省 single), member_uids 至少 2 人。
	// 单聊 (min_uid,max_uid) 唯一索引去重, 重复创建返回同一 conv_id。
	// 安全 (里程碑9): 发起者 = token 身份强制并入 member_uids (防冒名建会话);
	// 单聊的好友校验在 Message Svc 服务端做 (不信任网关前置)
	api.POST("/conversations", func(ctx context.Context, c *app.RequestContext) {
		var req yim.CreateConvReq
		opts := protojson.UnmarshalOptions{DiscardUnknown: true}
		if err := opts.Unmarshal(c.Request.Body(), &req); err != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		uid := middleware.UID(c)
		hasSelf := false
		for _, m := range req.MemberUids {
			if m == uid {
				hasSelf = true
				break
			}
		}
		if !hasSelf {
			req.MemberUids = append(req.MemberUids, uid)
		}
		if len(req.MemberUids) < 2 {
			writeErr(c, 400, "member_uids requires at least 2 users")
			return
		}
		if req.Type == yim.ConvType_CONV_UNKNOWN {
			req.Type = yim.ConvType_CONV_SINGLE
		}
		req.OwnerUid = middleware.UID(c) // 里程碑9: 群主 seed / 校验归属
		rsp, err := msgCli.CreateConv(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("create conv rpc", zap.Error(err))
			writeErr(c, 500, "create conv failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 拉历史: GET /conversations/:id/messages?before_seq=&limit=
	// 游标翻页: before_seq=0 从最新开始, 响应末尾最小 seq 作为下一次 before_seq
	// 安全 (里程碑9): op_uid = token 身份, 服务端校验会话成员 (code 25 → 403)
	api.GET("/conversations/:id/messages", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conversation id")
			return
		}
		beforeSeq, _ := strconv.ParseInt(c.DefaultQuery("before_seq", "0"), 10, 64)
		limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))

		rsp, err := msgCli.PullHistory(ctx, &yim.PullHistoryReq{
			ConvId:    convID,
			Mode:      yim.PullMode_PULL_PAGE_BACKWARD,
			BeforeSeq: beforeSeq,
			Limit:     int32(limit),
			OpUid:     middleware.UID(c),
		})
		if err != nil {
			logger.C(ctx).Error("pull history", zap.Error(err), zap.Int64("conv_id", convID))
			writeErr(c, 500, "pull history failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 403, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// ========== 里程碑9: 会话列表/已读 + 好友/群成员/资料/在线 ==========

	// 会话列表: GET /conversations?page=&page_size=
	api.GET("/conversations", func(ctx context.Context, c *app.RequestContext) {
		pageNum, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
		pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "50"))
		rsp, err := msgCli.ListConversations(ctx, &yim.ListConversationsReq{
			Uid: middleware.UID(c),
			Page: &yim.PageInfo{PageNum: int32(pageNum), PageSize: int32(pageSize)},
		})
		if err != nil {
			logger.C(ctx).Error("list conversations rpc", zap.Error(err))
			writeErr(c, 500, "list conversations failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 已读回执: POST /conversations/:id/read {read_seq}
	api.POST("/conversations/:id/read", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conversation id")
			return
		}
		var body struct {
			ReadSeq int64 `json:"read_seq,string"`
		}
		if err := json.Unmarshal(c.Request.Body(), &body); err != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		rsp, err := msgCli.MarkRead(ctx, &yim.MarkReadReq{
			Uid: middleware.UID(c), ConvId: convID, ReadSeq: body.ReadSeq,
		})
		if err != nil {
			logger.C(ctx).Error("mark read rpc", zap.Error(err))
			writeErr(c, 500, "mark read failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 已读状态查询: GET /conversations/:id/read-states → 各成员 read_seq
	// (READ 事件只有实时那条, 对端先读过的水位进窗时拉这里补齐)
	api.GET("/conversations/:id/read-states", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conversation id")
			return
		}
		rsp, err := msgCli.GetReadState(ctx, &yim.GetReadStateReq{
			OpUid: middleware.UID(c), ConvId: convID,
		})
		if err != nil {
			logger.C(ctx).Error("get read state rpc", zap.Error(err))
			writeErr(c, 500, "get read state failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 403, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 发好友申请: POST /friend/requests {to_uid, message}
	api.POST("/friend/requests", func(ctx context.Context, c *app.RequestContext) {
		var req yim.SendFriendRequestReq
		if (protojson.UnmarshalOptions{DiscardUnknown: true}).Unmarshal(c.Request.Body(), &req) != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		req.FromUid = middleware.UID(c)
		rsp, err := relCli.SendFriendRequest(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("send friend request rpc", zap.Error(err))
			writeErr(c, 500, "send friend request failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 处理申请: POST /friend/requests/:from_uid {action: "accept"|"reject"}
	api.POST("/friend/requests/:from_uid", func(ctx context.Context, c *app.RequestContext) {
		fromUID, err := strconv.ParseInt(c.Param("from_uid"), 10, 64)
		if err != nil || fromUID <= 0 {
			writeErr(c, 400, "invalid from_uid")
			return
		}
		var body struct {
			Action string `json:"action"`
		}
		if err := json.Unmarshal(c.Request.Body(), &body); err != nil || (body.Action != "accept" && body.Action != "reject") {
			writeErr(c, 400, "action must be accept or reject")
			return
		}
		rsp, err := relCli.HandleFriendRequest(ctx, &yim.HandleFriendRequestReq{
			OpUid: middleware.UID(c), FromUid: fromUID, Accept: body.Action == "accept",
		})
		if err != nil {
			logger.C(ctx).Error("handle friend request rpc", zap.Error(err))
			writeErr(c, 500, "handle friend request failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 申请列表: GET /friend/requests?direction=in|out (缺省 in)
	api.GET("/friend/requests", func(ctx context.Context, c *app.RequestContext) {
		rsp, err := relCli.ListFriendRequests(ctx, &yim.ListFriendRequestsReq{
			Uid:      middleware.UID(c),
			Incoming: c.DefaultQuery("direction", "in") != "out",
		})
		if err != nil {
			logger.C(ctx).Error("list friend requests rpc", zap.Error(err))
			writeErr(c, 500, "list friend requests failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 好友列表: GET /friends?page=&page_size=
	api.GET("/friends", func(ctx context.Context, c *app.RequestContext) {
		pageNum, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
		pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "50"))
		rsp, err := relCli.ListFriends(ctx, &yim.ListFriendsReq{
			Uid:  middleware.UID(c),
			Page: &yim.PageInfo{PageNum: int32(pageNum), PageSize: int32(pageSize)},
		})
		if err != nil {
			logger.C(ctx).Error("list friends rpc", zap.Error(err))
			writeErr(c, 500, "list friends failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 删好友: DELETE /friends/:uid
	api.DELETE("/friends/:uid", func(ctx context.Context, c *app.RequestContext) {
		friendUID, err := strconv.ParseInt(c.Param("uid"), 10, 64)
		if err != nil || friendUID <= 0 {
			writeErr(c, 400, "invalid uid")
			return
		}
		rsp, err := relCli.DeleteFriend(ctx, &yim.DeleteFriendReq{
			OpUid: middleware.UID(c), FriendUid: friendUID,
		})
		if err != nil {
			logger.C(ctx).Error("delete friend rpc", zap.Error(err))
			writeErr(c, 500, "delete friend failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 拉人入群: POST /groups/:conv_id/members {member_uids} (仅群主, 服务端校验)
	api.POST("/groups/:conv_id/members", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("conv_id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conv_id")
			return
		}
		var req yim.AddGroupMembersReq
		if (protojson.UnmarshalOptions{DiscardUnknown: true}).Unmarshal(c.Request.Body(), &req) != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		rsp, err := relCli.AddGroupMembers(ctx, &yim.AddGroupMembersReq{
			ConvId: convID, MemberUids: req.MemberUids, OwnerUid: middleware.UID(c),
		})
		if err != nil {
			logger.C(ctx).Error("add group members rpc", zap.Error(err))
			writeErr(c, 500, "add group members failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 踢人: DELETE /groups/:conv_id/members/:uid (仅群主)
	api.DELETE("/groups/:conv_id/members/:uid", func(ctx context.Context, c *app.RequestContext) {
		convID, err1 := strconv.ParseInt(c.Param("conv_id"), 10, 64)
		targetUID, err2 := strconv.ParseInt(c.Param("uid"), 10, 64)
		if err1 != nil || err2 != nil || convID <= 0 || targetUID <= 0 {
			writeErr(c, 400, "invalid conv_id or uid")
			return
		}
		rsp, err := relCli.RemoveGroupMember(ctx, &yim.RemoveGroupMemberReq{
			OpUid: middleware.UID(c), ConvId: convID, TargetUid: targetUID,
		})
		if err != nil {
			logger.C(ctx).Error("remove group member rpc", zap.Error(err))
			writeErr(c, 500, "remove group member failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 退群: POST /groups/:conv_id/quit
	api.POST("/groups/:conv_id/quit", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("conv_id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conv_id")
			return
		}
		rsp, err := relCli.QuitGroup(ctx, &yim.QuitGroupReq{
			Uid: middleware.UID(c), ConvId: convID,
		})
		if err != nil {
			logger.C(ctx).Error("quit group rpc", zap.Error(err))
			writeErr(c, 500, "quit group failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 群成员列表: GET /groups/:conv_id/members
	api.GET("/groups/:conv_id/members", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("conv_id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conv_id")
			return
		}
		rsp, err := relCli.ListGroupMembers(ctx, &yim.ListGroupMembersReq{ConvId: convID})
		if err != nil {
			logger.C(ctx).Error("list group members rpc", zap.Error(err))
			writeErr(c, 500, "list group members failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 改群信息: PATCH /groups/:conv_id/info {name?, avatar?} (仅群主, 服务端校验;
	// 空串/缺省字段不覆盖)。avatar = /files/image 上传返回的相对 URL
	api.PATCH("/groups/:conv_id/info", func(ctx context.Context, c *app.RequestContext) {
		convID, err := strconv.ParseInt(c.Param("conv_id"), 10, 64)
		if err != nil || convID <= 0 {
			writeErr(c, 400, "invalid conv_id")
			return
		}
		var body struct {
			Name   string `json:"name"`
			Avatar string `json:"avatar"`
		}
		if err := json.Unmarshal(c.Request.Body(), &body); err != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		rsp, err := relCli.UpdateGroupInfo(ctx, &yim.UpdateGroupInfoReq{
			OpUid:   int64(middleware.UID(c)),
			ConvId:  convID,
			Name:    body.Name,
			Avatar:  body.Avatar,
		})
		if err != nil {
			logger.C(ctx).Error("update group info rpc", zap.Error(err))
			writeErr(c, 500, "update group info failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 批量资料: GET /users/profiles?uids=1,2,3
	api.GET("/users/profiles", func(ctx context.Context, c *app.RequestContext) {
		uids, err := parseUIDs(c.Query("uids"))
		if err != nil || len(uids) == 0 {
			writeErr(c, 400, "uids query required (comma separated)")
			return
		}
		rsp, err := relCli.GetProfiles(ctx, &yim.GetProfilesReq{Uids: uids})
		if err != nil {
			logger.C(ctx).Error("get profiles rpc", zap.Error(err))
			writeErr(c, 500, "get profiles failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 搜索用户 (加好友): GET /users/search?keyword=
	// 纯数字 = uid 精确 OR 昵称前缀; 否则昵称前缀。op_uid 取 token 身份。
	api.GET("/users/search", func(ctx context.Context, c *app.RequestContext) {
		kw := c.Query("keyword")
		if kw == "" {
			writeErr(c, 400, "keyword query required")
			return
		}
		rsp, err := relCli.SearchUsers(ctx, &yim.SearchUsersReq{
			Keyword: kw,
			OpUid:   int64(middleware.UID(c)),
		})
		if err != nil {
			logger.C(ctx).Error("search users rpc", zap.Error(err))
			writeErr(c, 500, "search users failed")
			return
		}
		writeProto(c, 200, rsp)
	})

	// 改昵称: PATCH /users/me {nickname} (头像走 /files/avatar 上传)
	api.PATCH("/users/me", func(ctx context.Context, c *app.RequestContext) {
		var req yim.UpdateProfileReq
		if (protojson.UnmarshalOptions{DiscardUnknown: true}).Unmarshal(c.Request.Body(), &req) != nil {
			writeErr(c, 400, "invalid json body")
			return
		}
		req.Uid = middleware.UID(c)
		req.Avatar = "" // 头像只能走上传接口 (服务端落盘产生可信 URL)
		rsp, err := relCli.UpdateProfile(ctx, &req)
		if err != nil {
			logger.C(ctx).Error("update profile rpc", zap.Error(err))
			writeErr(c, 500, "update profile failed")
			return
		}
		if rsp.GetError() != nil {
			writeErr(c, 400, rsp.GetError().GetMsg())
			return
		}
		writeProto(c, 200, rsp)
	})

	// 在线状态: GET /presence?uids=1,2,3 (连接级: route:{uid} 存在即在线)
	api.GET("/presence", func(ctx context.Context, c *app.RequestContext) {
		uids, err := parseUIDs(c.Query("uids"))
		if err != nil || len(uids) == 0 {
			writeErr(c, 400, "uids query required (comma separated)")
			return
		}
		rsp, err := relCli.GetPresence(ctx, &yim.GetPresenceReq{Uids: uids})
		if err != nil {
			logger.C(ctx).Error("get presence rpc", zap.Error(err))
			writeErr(c, 500, "get presence failed")
			return
		}
		writeProto(c, 200, rsp)
	})
}

// parseUIDs "1,2,3" → []int64。
func parseUIDs(s string) ([]int64, error) {
	if s == "" {
		return nil, fmt.Errorf("empty")
	}
	parts := strings.Split(s, ",")
	out := make([]int64, 0, len(parts))
	for _, p := range parts {
		v, err := strconv.ParseInt(strings.TrimSpace(p), 10, 64)
		if err != nil || v <= 0 {
			return nil, fmt.Errorf("invalid uid %q", p)
		}
		out = append(out, v)
	}
	return out, nil
}
