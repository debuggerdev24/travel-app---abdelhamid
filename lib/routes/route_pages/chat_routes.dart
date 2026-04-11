import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/features/chat/chat_detail_screen.dart';
import 'package:trael_app_abdelhamid/features/chat/chat_screen.dart';
import 'package:trael_app_abdelhamid/features/chat/group_info_screen.dart';
import 'package:trael_app_abdelhamid/features/chat/live_location_screen.dart';

List<RouteBase> get chatRoutes => [
  GoRoute(
    path: UserAppRoutes.chatScreen.path,
    name: UserAppRoutes.chatScreen.name,
    builder: (context, state) => ChatScreen(),
  ),
  GoRoute(
    path: UserAppRoutes.chatDetailScreen.path,
    name: UserAppRoutes.chatDetailScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      final chatId = data['chatId'] as String;
      return ChatDetailScreen(
        key: ValueKey<String>('chat_detail_$chatId'),
        chatId: chatId,
        name: data['name'] as String,
        image: data['image'] as String,
        avatarUrl: data['avatarUrl'] as String?,
        isGroup: data['isGroup'] ?? false,
      );
    },
  ),
  GoRoute(
    path: UserAppRoutes.groupInfoScreen.path,
    name: UserAppRoutes.groupInfoScreen.name,
    builder: (context, state) {
      final data = state.extra as Map<String, dynamic>;
      return GroupInfoScreen(name: data['name'], image: data['image']);
    },
  ),
  GoRoute(
    path: UserAppRoutes.liveLocationScreen.path,
    name: UserAppRoutes.liveLocationScreen.name,
    builder: (context, state) => LiveLocationScreen(),
  ),
];
