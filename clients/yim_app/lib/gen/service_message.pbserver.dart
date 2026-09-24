// This is a generated file - do not edit.
//
// Generated from service_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'service_message.pb.dart' as $3;
import 'service_message.pbjson.dart';

export 'service_message.pb.dart';

abstract class MessageServiceBase extends $pb.GeneratedService {
  $async.Future<$3.SendMessageRsp> sendMessage(
      $pb.ServerContext ctx, $3.SendMessageReq request);
  $async.Future<$3.PullHistoryRsp> pullHistory(
      $pb.ServerContext ctx, $3.PullHistoryReq request);
  $async.Future<$3.SyncRsp2> sync($pb.ServerContext ctx, $3.SyncReq2 request);
  $async.Future<$3.AckPushRsp> ackPush(
      $pb.ServerContext ctx, $3.AckPushReq request);
  $async.Future<$3.RevokeMessageRsp> revokeMessage(
      $pb.ServerContext ctx, $3.RevokeMessageReq request);
  $async.Future<$3.MarkReadRsp> markRead(
      $pb.ServerContext ctx, $3.MarkReadReq request);
  $async.Future<$3.ListConversationsRsp> listConversations(
      $pb.ServerContext ctx, $3.ListConversationsReq request);
  $async.Future<$3.SearchMessagesRsp> searchMessages(
      $pb.ServerContext ctx, $3.SearchMessagesReq request);
  $async.Future<$3.CreateConvRsp> createConv(
      $pb.ServerContext ctx, $3.CreateConvReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SendMessage':
        return $3.SendMessageReq();
      case 'PullHistory':
        return $3.PullHistoryReq();
      case 'Sync':
        return $3.SyncReq2();
      case 'AckPush':
        return $3.AckPushReq();
      case 'RevokeMessage':
        return $3.RevokeMessageReq();
      case 'MarkRead':
        return $3.MarkReadReq();
      case 'ListConversations':
        return $3.ListConversationsReq();
      case 'SearchMessages':
        return $3.SearchMessagesReq();
      case 'CreateConv':
        return $3.CreateConvReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SendMessage':
        return sendMessage(ctx, request as $3.SendMessageReq);
      case 'PullHistory':
        return pullHistory(ctx, request as $3.PullHistoryReq);
      case 'Sync':
        return sync(ctx, request as $3.SyncReq2);
      case 'AckPush':
        return ackPush(ctx, request as $3.AckPushReq);
      case 'RevokeMessage':
        return revokeMessage(ctx, request as $3.RevokeMessageReq);
      case 'MarkRead':
        return markRead(ctx, request as $3.MarkReadReq);
      case 'ListConversations':
        return listConversations(ctx, request as $3.ListConversationsReq);
      case 'SearchMessages':
        return searchMessages(ctx, request as $3.SearchMessagesReq);
      case 'CreateConv':
        return createConv(ctx, request as $3.CreateConvReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MessageServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => MessageServiceBase$messageJson;
}
