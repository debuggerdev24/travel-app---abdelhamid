import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/jwt_user_id.dart';
import 'package:travel_app_abdelhamid/core/utils/log_helper.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/custom_switch_button.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/network_avatar.dart';
import 'package:travel_app_abdelhamid/model/chat/group_info_model.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/services/chat_api_service.dart';

class GroupInfoScreen extends StatefulWidget {
  /// Chat document id (messages, delete chat).
  final String chatId;

  /// Group document id for profile/members APIs (`groupId` query param).
  final String groupId;
  final String name;
  final String image;
  final String? avatarUrl;
  final bool isLocalChat;

  const GroupInfoScreen({
    super.key,
    required this.chatId,
    required this.groupId,
    required this.name,
    required this.image,
    this.avatarUrl,
    this.isLocalChat = false,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  GroupInfoModel? _info;
  bool _loading = true;
  String? _error;
  bool _actionInProgress = false;
  bool _notificationsOn = true;
  bool _showAllMembers = false;
  final TextEditingController _emergencyMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  @override
  void dispose() {
    _emergencyMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.isLocalChat) {
      // Mock data for local chat
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() {
        _info = GroupInfoModel(
          chatId: widget.chatId,
          name: widget.name,
          imageUrl: widget.image,
          description: 'A mock group for tracking travelers and local chat.',
          destination: 'Mecca, SA',
          dateRange: 'Nov 1 - Nov 10, 2026',
          createdByLabel: 'Guide User',
          createdOnLabel: 'Oct 15, 2026',
          sharedMedia: [],
          members: [
            GroupMemberModel(
              memberId: 'self',
              userId: currentUserIdOrNull() ?? 'user_1',
              name: 'You',
              role: 'Guide',
              avatarUrl: widget.avatarUrl ?? '',
            ),
            GroupMemberModel(
              memberId: 'mem_1',
              userId: 'u1',
              name: 'Ahmed Mohamed',
              role: 'Member',
              avatarUrl: '',
            ),
            GroupMemberModel(
              memberId: 'mem_2',
              userId: 'u2',
              name: 'Sarah Johnson',
              role: 'Member',
              avatarUrl: '',
            ),
          ],
        );
        _loading = false;
      });
      return;
    }

    try {
      final profileFuture = ChatApiService.instance.getChatProfile(
        groupId: widget.groupId,
        showErrorToast: false,
      );
      final membersFuture = ChatApiService.instance.getGroupMembers(
        chatId: widget.groupId,
        showErrorToast: false,
      );

      final results = await Future.wait([profileFuture, membersFuture]);
      final profile = Map<String, dynamic>.from(results[0] as Map);
      final membersRaw = results[1] as List<Map<String, dynamic>>;
      final members = membersRaw
          .map((e) => GroupMemberModel.fromJson(e))
          .where((m) => m.memberId.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _info = GroupInfoModel.fromProfileJson(
          chatId: widget.chatId,
          json: profile,
          members: members,
          currentUserId: currentUserIdOrNull(),
        );
        _loading = false;
      });
      final groupImage = _info?.imageUrl;
      if (groupImage != null && groupImage.isNotEmpty) {
        context.read<ChatProvider>().updateConversationAvatar(
          widget.chatId,
          groupImage,
        );
      }
    } catch (e, st) {
      LogHelper.instance.error('loadGroupInfo', e, st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load group info. Please try again.';
      });
    }
  }

  Future<void> _exitGroup() async {
    final info = _info;
    if (info == null || _actionInProgress) return;

    final uid = currentUserIdOrNull();
    final self = info.memberForUser(uid);
    if (self == null) {
      ToastHelper.showError('Could not find your membership in this group.');
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Exit group?',
      message: 'You will no longer receive messages from this group.',
      confirmLabel: 'Exit',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionInProgress = true);
    if (widget.isLocalChat) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      ToastHelper.showSuccess('You left the group (mock).');
      _popToChatList();
      return;
    }

    try {
      await ChatApiService.instance.removeGroupMember(
        chatId: widget.groupId,
        memberId: self.memberId,
      );
      if (!mounted) return;
      context.read<ChatProvider>().loadConversations(silent: true);
      ToastHelper.showSuccess('You left the group.');
      _popToChatList();
    } catch (e, st) {
      LogHelper.instance.error('exitGroup', e, st);
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _deleteGroup() async {
    final info = _info;
    if (info == null || _actionInProgress) return;
    if (!info.isCurrentUserAdmin && !widget.isLocalChat) {
      ToastHelper.showError('Only admins can delete this group.');
      return;
    }

    final confirmed = await _confirmAction(
      title: 'Delete group?',
      message: 'This will permanently delete the group for everyone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionInProgress = true);
    if (widget.isLocalChat) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      ToastHelper.showSuccess('Group deleted (mock).');
      _popToChatList();
      return;
    }

    try {
      await ChatApiService.instance.deleteChat(chatId: widget.chatId);
      if (!mounted) return;
      context.read<ChatProvider>().loadConversations(silent: true);
      ToastHelper.showSuccess('Group deleted.');
      _popToChatList();
    } catch (e, st) {
      LogHelper.instance.error('deleteGroup', e, st);
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  void _popToChatList() {
    var pops = 0;
    while (context.canPop() && pops < 2) {
      context.pop();
      pops++;
    }
  }

  Future<bool?> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive ? AppColors.redColor : AppColors.blueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildError()
            : _buildContent(_info!),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              textAlign: TextAlign.center,
              text: _error!,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
            20.h.verticalSpace,
            AppActionButton(
              label: 'Retry',
              icon: AppAssets.arrow,
              color: AppColors.blueColor,
              onTap: _loadGroupInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(GroupInfoModel info) {
    final visibleMembers = _showAllMembers
        ? info.members
        : info.members.take(3).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 60.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                  ),
                ),
                Center(
                  child: AppText(
                    text: 'Group Info',
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          20.h.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkAvatar(
                imageUrl: info.imageUrl,
                radius: 48.r,
                fallbackKind: AvatarFallbackKind.group,
              ),
              16.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: '${info.name} - Group',
                      style: textStyle18Bold.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    if (info.destination != null) ...[
                      5.h.verticalSpace,
                      AppText(
                        text: info.destination!,
                        style: textStyle14Regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                    if (info.dateRange != null) ...[
                      5.h.verticalSpace,
                      AppText(
                        text: info.dateRange!,
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (info.description != null && info.description!.isNotEmpty) ...[
            12.h.verticalSpace,
            AppText(
              text: info.description!,
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
          25.h.verticalSpace,
          if (info.createdByLabel != null && info.createdByLabel!.isNotEmpty)
            _buildInfoRow('Created By', info.createdByLabel!),
          if (info.createdByLabel != null && info.createdByLabel!.isNotEmpty)
            5.h.verticalSpace,
          if (info.createdByLabel != null && info.createdByLabel!.isNotEmpty)
            Divider(color: AppColors.primaryColor.setOpacity(0.2)),
          if (info.createdOnLabel != null &&
              info.createdOnLabel!.isNotEmpty) ...[
            5.h.verticalSpace,
            _buildInfoRow('Created On', info.createdOnLabel!),
          ],
          20.h.verticalSpace,
          _buildNotificationSwitch(),
          30.h.verticalSpace,
          _buildSharedMedia(info),
          25.h.verticalSpace,
          AppText(
            text: 'Members',
            style: textStyle18Bold.copyWith(color: AppColors.primaryColor),
          ),
          14.h.verticalSpace,
          _buildMembersList(info, visibleMembers),
          35.h.verticalSpace,
          if (info.isCurrentUserAdmin) ...[
            _buildEmergencyButton(),
            20.h.verticalSpace,
          ],
          if (_actionInProgress)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: AppActionButton(
                    label: 'Exit',
                    icon: AppAssets.exit,
                    color: AppColors.blueColor,
                    onTap: _exitGroup,
                  ),
                ),
                SizedBox(width: 15.w),
                if (info.isCurrentUserAdmin)
                  Expanded(
                    child: AppActionButton(
                      label: 'Delete',
                      icon: AppAssets.delete,
                      color: AppColors.redColor,
                      onTap: _deleteGroup,
                    ),
                  ),
              ],
            ),
          42.h.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: label,
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.setOpacity(0.5),
            fontSize: 14.sp,
          ),
        ),
        Flexible(
          child: AppText(
            textAlign: TextAlign.end,
            text: value,
            style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: 'Notification',
          style: textStyle18Bold.copyWith(color: AppColors.primaryColor),
        ),
        CustomSwitchButton(
          value: _notificationsOn,
          onChanged: (value) => setState(() => _notificationsOn = value),
        ),
      ],
    );
  }

  Widget _buildSharedMedia(GroupInfoModel info) {
    final media = info.sharedMedia.where((m) => m.isImage).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: 'Shared Media & Docs',
              style: textStyle18Bold.copyWith(
                color: AppColors.primaryColor,
                fontSize: 18.sp,
              ),
            ),
            if (media.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.r),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: AppText(
                  text: 'View All',
                  style: textStyle14Medium.copyWith(
                    color: AppColors.secondary,
                    fontSize: 12.sp,
                  ),
                ),
              ),
          ],
        ),
        19.h.verticalSpace,
        if (media.isEmpty)
          AppText(
            text: 'No shared media yet.',
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.45),
            ),
          )
        else
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(
                    media[index].url,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100.w,
                      height: 100.h,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: SvgIcon(AppAssets.photo, size: 28.w),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMembersList(
    GroupInfoModel info,
    List<GroupMemberModel> visibleMembers,
  ) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (visibleMembers.isEmpty)
            AppText(
              text: 'No members found.',
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.5),
              ),
            )
          else
            ...visibleMembers.map(
              (member) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: [
                    NetworkAvatar(
                      imageUrl: member.avatarUrl,
                      radius: 20.r,
                      fallbackKind: AvatarFallbackKind.user,
                    ),
                    18.w.horizontalSpace,
                    Expanded(
                      child: AppText(
                        text: member.name,
                        style: textStyle12Regular.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    AppText(
                      text: member.role,
                      style: textStyle14Medium.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (info.members.length > 3) ...[
            Divider(indent: 10.w, endIndent: 10.w),
            10.h.verticalSpace,
            GestureDetector(
              onTap: () => setState(() => _showAllMembers = !_showAllMembers),
              child: Center(
                child: AppText(
                  text: _showAllMembers
                      ? 'Show Less'
                      : 'View All Members (${info.members.length})',
                  style: textStyle18Bold.copyWith(
                    color: AppColors.blueColor,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: AppColors.redColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showEmergencyMessageDialog,
          borderRadius: BorderRadius.circular(8.r),
          child: Row(
            children: [
              16.w.horizontalSpace,
              Icon(Icons.emergency, color: Colors.white, size: 20.sp),
              16.w.horizontalSpace,
              AppText(
                text: "Send Emergency Message",
                style: textStyle14Regular.copyWith(color: Colors.white),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16.sp),
              16.w.horizontalSpace,
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyMessageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          text: "Emergency Broadcast",
          style: textStyle18Bold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "This message will be sent to all members in this group immediately.",
                style: textStyle14Regular.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              16.h.verticalSpace,
              TextField(
                controller: _emergencyMessageController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter emergency message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              text: "Cancel",
              style: textStyle14Regular.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_emergencyMessageController.text.trim().isNotEmpty) {
                _sendEmergencyMessage();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redColor,
            ),
            child: AppText(
              text: "Send",
              style: textStyle14Regular.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmergencyMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          text: "Emergency message sent to group!",
          style: textStyle14Regular.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.redColor,
        duration: Duration(seconds: 3),
      ),
    );
    _emergencyMessageController.clear();
  }
}
