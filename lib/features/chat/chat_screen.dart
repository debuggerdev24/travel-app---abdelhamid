import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_avatar.dart';
import 'package:travel_app_abdelhamid/model/chat/chat_model.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            20.h.verticalSpace,
            _buildHeader(),
            20.h.verticalSpace,
            _buildTabs(context),
            20.h.verticalSpace,
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.loadingConversations &&
                      provider.chatList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.conversationsError != null &&
                      provider.chatList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: AppText(
                          textAlign: TextAlign.center,
                          text: provider.conversationsError!,
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor.setOpacity(0.6),
                          ),
                        ),
                      ),
                    );
                  }
                  if (!provider.loadingConversations &&
                      provider.chatList.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => provider.loadConversations(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 120.h),
                          Center(
                            child: AppText(
                              textAlign: TextAlign.center,
                              text: 'No conversations yet.',
                              style: textStyle14Regular.copyWith(
                                color: AppColors.primaryColor.setOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.loadConversations(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      itemCount: provider.chatList.length,
                      separatorBuilder: (context, index) => 20.h.verticalSpace,
                      itemBuilder: (context, index) {
                        return _buildChatItem(
                          context,
                          provider.chatList[index],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          24.w.horizontalSpace,
          AppText(
            textAlign: TextAlign.center,
            text: "Chat",
            style: textStyle16SemiBold.copyWith(
              fontSize: 26.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SvgIcon(AppAssets.search, size: 24.w, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 27.w),
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(130.r),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.setOpacity(0.2),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              _tabItem(context, provider, "All", 0),
              _tabItem(context, provider, "Groups", 1),
              _tabItem(context, provider, "Direct", 2),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItem(
    BuildContext context,
    ChatProvider provider,
    String label,
    int index,
  ) {
    final bool isSelected = provider.selectedTabIndex == index;

    return GestureDetector(
      onTap: () => provider.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 39.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.setOpacity(0.01),
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: textStyle14Medium.copyWith(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, ChatModel data) {
    final chatProvider = context.read<ChatProvider>();
    final extra = <String, Object?>{
      'chatId': data.chatId,
      'groupId': data.groupId,
      'name': data.name,
      'image': data.image,
      'avatarUrl': data.avatarUrl,
      'isGroup': data.isGroup,
    };
    // primeChatOpen skips notifyListeners so the list does not rebuild on the
    // same frame as the route push (that rebuild was delaying navigation).
    chatProvider.primeChatOpen(data.chatId);
    context.pushNamed(UserAppRoutes.chatDetailScreen.name, extra: extra);
  }

  Widget _buildChatItem(BuildContext context, ChatModel data) {
    final hasUnread = data.unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openChat(context, data),
        child: Row(
          children: [
            _avatar(data),
            15.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: data.name,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle18Bold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      AppText(
                        text: data.time,
                        style: textStyle14Regular.copyWith(
                          color: hasUnread
                              ? AppColors.blueColor
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.4),
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  2.h.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText(
                          text: data.message,
                          style: textStyle14Regular.copyWith(
                            color: hasUnread
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.75)
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.4),
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          constraints: BoxConstraints(
                            minWidth: 22.w,
                            minHeight: 22.w,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: data.unread > 9 ? 7.w : 6.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            text: data.unread > 99 ? '99+' : '${data.unread}',
                            style: textStyle18Bold.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(ChatModel data) {
    return NetworkAvatar(
      imageUrl: data.avatarUrl,
      radius: 24.r,
      fallbackKind: data.isGroup
          ? AvatarFallbackKind.group
          : AvatarFallbackKind.user,
    );
  }
}
