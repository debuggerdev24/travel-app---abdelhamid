import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class GuideChatScreen extends StatefulWidget {
  const GuideChatScreen({super.key});

  @override
  State<GuideChatScreen> createState() => _GuideChatScreenState();
}

class _GuideChatScreenState extends State<GuideChatScreen> {
  int _selectedTab = 0;

  // Local message storage for static chats
  static final Map<String, List<Map<String, dynamic>>> _localMessages = {
    'chat_1': [
      {
        '_id': 'msg_1',
        'isMe': false,
        'type': 'text',
        'message': 'When is the next tour starting?',
        'sender': 'Ahmed Mohamed',
        'time': '10:30 AM',
        'edited': false,
      },
    ],
    'chat_2': [
      {
        '_id': 'msg_2',
        'isMe': false,
        'type': 'text',
        'message': 'Thank you for the guidance!',
        'sender': 'Sarah Johnson',
        'time': '9:15 AM',
        'edited': false,
      },
    ],
    'chat_3': [
      {
        '_id': 'msg_3',
        'isMe': false,
        'type': 'text',
        'message': 'Meeting point confirmed',
        'sender': 'Group A Travelers',
        'time': '8:00 AM',
        'edited': false,
      },
    ],
    'chat_4': [
      {
        '_id': 'msg_4',
        'isMe': false,
        'type': 'text',
        'message': 'Can you recommend a restaurant?',
        'sender': 'Omar Hassan',
        'time': 'Yesterday',
        'edited': false,
      },
    ],
    'chat_5': [
      {
        '_id': 'msg_5',
        'isMe': false,
        'type': 'text',
        'message': 'We\'re ready for tomorrow\'s tour',
        'sender': 'Family Trip Group',
        'time': 'Yesterday',
        'edited': false,
      },
    ],
  };

  // Sample chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'chatId': 'chat_1',
      'name': 'Ahmed Mohamed',
      'message': 'When is the next tour starting?',
      'time': '2 min ago',
      'unread': 2,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_2',
      'name': 'Sarah Johnson',
      'message': 'Thank you for the guidance!',
      'time': '15 min ago',
      'unread': 0,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_3',
      'groupId': 'group_1',
      'name': 'Group A Travelers',
      'message': 'Meeting point confirmed',
      'time': '1 hour ago',
      'unread': 5,
      'isGroup': true,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_4',
      'name': 'Omar Hassan',
      'message': 'Can you recommend a restaurant?',
      'time': '3 hours ago',
      'unread': 0,
      'isGroup': false,
      'image': '',
      'avatarUrl': null,
    },
    {
      'chatId': 'chat_5',
      'groupId': 'group_2',
      'name': 'Family Trip Group',
      'message': 'We\'re ready for tomorrow\'s tour',
      'time': '5 hours ago',
      'unread': 1,
      'isGroup': true,
      'image': '',
      'avatarUrl': null,
    },
  ];

  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _chatProvider.addListener(_onChatProviderUpdate);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onChatProviderUpdate);
    super.dispose();
  }

  void _onChatProviderUpdate() {
    // Sync messages back to local storage when they change
    final activeChatId = _chatProvider.activeChatId;
    if (activeChatId != null && _localMessages.containsKey(activeChatId)) {
      _localMessages[activeChatId] = List.from(_chatProvider.messages);
    }
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
            16.h.verticalSpace,
            _buildTabs(),
            16.h.verticalSpace,
            Expanded(child: _buildChatView()),
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
            text: "Chat".tr(),
            style: textStyle16SemiBold.copyWith(
              fontSize: 26.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Icon(
            Icons.search,
            size: 24.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 27.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(130.r),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          _tabItem("All".tr(), 0),
          _tabItem("Groups".tr(), 1),
          _tabItem("Direct".tr(), 2),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: AppText(
              text: label,
              style: textStyle14Medium.copyWith(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    final displayedChats = _chats.where((chat) {
      if (_selectedTab == 0) return true;
      if (_selectedTab == 1) return chat['isGroup'] == true;
      return chat['isGroup'] == false;
    }).toList();

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: displayedChats.length,
      separatorBuilder: (context, index) => 20.h.verticalSpace,
      itemBuilder: (context, index) {
        return _buildChatItem(
          chatId: displayedChats[index]['chatId'],
          groupId: displayedChats[index]['groupId'],
          name: displayedChats[index]['name'],
          message: displayedChats[index]['message'],
          time: displayedChats[index]['time'],
          unread: displayedChats[index]['unread'],
          isGroup: displayedChats[index]['isGroup'],
          image: displayedChats[index]['image'],
          avatarUrl: displayedChats[index]['avatarUrl'],
        );
      },
    );
  }

  void _openChat({
    required String chatId,
    String? groupId,
    required String name,
    required String image,
    String? avatarUrl,
    required bool isGroup,
  }) {
    final chatProvider = context.read<ChatProvider>();

    // Initialize local messages if not exists
    if (!_localMessages.containsKey(chatId)) {
      _localMessages[chatId] = [];
    }

    chatProvider.primeChatOpen(chatId);

    // Load local messages into ChatProvider
    chatProvider.loadLocalMessages(chatId, _localMessages[chatId]!);

    final extra = <String, dynamic>{
      'chatId': chatId,
      'groupId': groupId,
      'name': name,
      'image': image,
      'avatarUrl': avatarUrl,
      'isGroup': isGroup,
      'isLocalChat': true, // Flag to indicate this is a local/static chat
    };

    context.pushNamed(UserAppRoutes.chatDetailScreen.name, extra: extra);
  }

  Widget _buildChatItem({
    required String chatId,
    String? groupId,
    required String name,
    required String message,
    required String time,
    required int unread,
    required bool isGroup,
    required String image,
    String? avatarUrl,
  }) {
    final hasUnread = unread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openChat(
            chatId: chatId,
            groupId: groupId,
            name: name,
            image: image,
            avatarUrl: avatarUrl,
            isGroup: isGroup,
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              child: Icon(
                isGroup ? Icons.group : Icons.person,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24.sp,
              ),
            ),
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
                          text: name.startsWith('Trip: ')
                              ? '${"Trip".tr()}: ${name.substring(6)}'
                              : (name.startsWith('Trip:')
                                  ? '${"Trip".tr()}:${name.substring(5)}'
                                  : name),
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
                        text: time,
                        style: textStyle14Regular.copyWith(
                          color: hasUnread
                              ? AppColors.blueColor
                              : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.4),
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
                          text: message,
                          style: textStyle14Regular.copyWith(
                            color: hasUnread
                                ? Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.75)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.4),
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
                            horizontal: unread > 9 ? 7.w : 6.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blueColor,
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          alignment: Alignment.center,
                          child: AppText(
                            text: unread > 99 ? '99+' : '$unread',
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
}
