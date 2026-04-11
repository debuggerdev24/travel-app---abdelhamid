import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/live_location_constants.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String name;
  final String image;
  final String? avatarUrl;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.image,
    this.avatarUrl,
    this.isGroup = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  ChatProvider? _chat;
  bool _chatLoadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chat ??= context.read<ChatProvider>();
    if (_chatLoadStarted) return;
    _chatLoadStarted = true;
    // Earliest safe place to use [context.read]; runs before first paint so the
    // fetch starts in parallel with building this route (smoother than post-frame).
    _chat!.enterChatRoom(
      chatId: widget.chatId,
      title: widget.name,
      avatarUrl: widget.avatarUrl,
      isGroup: widget.isGroup,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _chat?.leaveChatRoom();
    super.dispose();
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendSocketText(text);
    _textController.clear();
  }

  Future<void> _openLocationInMapsApp(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ToastHelper.showError('Could not open Maps');
      }
    } catch (_) {
      ToastHelper.showError('Could not open Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 18.h, right: 10.w),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                  ),
                ),
                Expanded(
                  child: AppText(
                    textAlign: TextAlign.center,
                    text: widget.name,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                if (!widget.isGroup) 35.w.horizontalSpace,

                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    if (widget.isGroup) {
                      context.pushNamed(
                        UserAppRoutes.groupInfoScreen.name,
                        extra: {'name': widget.name, 'image': widget.image},
                      );
                    } else {}
                  },
                  child: widget.isGroup
                      ? SvgIcon(AppAssets.info, size: 24.w)
                      : SvgIcon(
                          AppAssets.call,
                          size: 24.w,
                          color: AppColors.greyColor,
                        ),
                ),
                SizedBox(width: widget.isGroup ? 18.h : 10.w),
              ],
            ),

            Expanded(
              child: provider.loadingMessages
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          16.h.verticalSpace,
                          AppText(
                            text: 'Loading messages…',
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor.setOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                        vertical: 18.h,
                        horizontal: 16.w,
                      ),
                      itemCount: provider.messages.length,
                      itemBuilder: (context, index) {
                        final i = provider.messages.length - 1 - index;
                        return _buildMessageItem(
                          context,
                          provider,
                          provider.messages[i],
                        );
                      },
                    ),
            ),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: provider.loadingMessages ? 0.45 : 1,
              child: AbsorbPointer(
                absorbing: provider.loadingMessages,
                child: _buildBottomInput(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canModerateOwnMessage(Map<String, dynamic> message) {
    if (message['isMe'] != true) return false;
    final text = message['message']?.toString() ?? '';
    if (text == 'This message was deleted') return false;
    return true;
  }

  void _showOwnMessageActions(
    BuildContext context,
    ChatProvider provider,
    Map<String, dynamic> message,
  ) {
    if (!_canModerateOwnMessage(message)) return;
    final id = message['_id']?.toString();
    if (id == null || id.isEmpty) return;
    final type = message['type']?.toString() ?? 'text';
    final canEdit = type == 'text';

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canEdit)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditMessageDialog(
                    context,
                    provider,
                    id,
                    message['message']?.toString() ?? '',
                  );
                },
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.redColor),
              title: Text(
                'Delete for everyone',
                style: TextStyle(color: AppColors.redColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteMessage(context, provider, id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMessageDialog(
    BuildContext context,
    ChatProvider provider,
    String messageId,
    String initial,
  ) {
    final controller = TextEditingController(text: initial);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText(
          text: 'Edit message',
          style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final t = controller.text.trim();
              if (t.isEmpty) {
                ToastHelper.showError('Message cannot be empty');
                return;
              }
              Navigator.pop(ctx);
              await provider.editOwnTextMessage(
                messageId: messageId,
                newText: t,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMessage(
    BuildContext context,
    ChatProvider provider,
    String messageId,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text(
          'This removes the message for everyone in the chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteOwnMessage(messageId);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.redColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    ChatProvider provider,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (x == null) return;
    await provider.uploadChatImage(x.path);
  }

  void _showLocationShareSheet(BuildContext context, ChatProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: AppText(
                  text: 'Share location',
                  textAlign: TextAlign.center,
                  style: textStyle16SemiBold.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              ListTile(
                leading: SvgIcon(
                  AppAssets.location,
                  size: 26.w,
                  color: AppColors.primaryColor,
                ),
                title: AppText(
                  text: 'Current location',
                  style: textStyle14Medium.copyWith(color: Colors.black87),
                ),
                subtitle: AppText(
                  text: 'Send a map pin of where you are now',
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.setOpacity(0.55),
                    fontSize: 12.sp,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await provider.sendCurrentLocationFromGps();
                },
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    text: 'Live location',
                    style: textStyle12semiBold.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.65),
                    ),
                  ),
                ),
              ),
              ...kLiveLocationDurationOptionsMinutes.map(
                (minutes) => ListTile(
                  leading: SvgIcon(
                    AppAssets.map,
                    size: 24.w,
                    color: AppColors.primaryColor,
                  ),
                  title: AppText(
                    text: liveLocationDurationTitle(minutes),
                    style: textStyle14Medium.copyWith(color: Colors.black87),
                  ),
                  subtitle: AppText(
                    text: liveLocationDurationSubtitle(minutes),
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.55),
                      fontSize: 12.sp,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await provider.startLiveLocationFromGps(
                      durationMinutes: minutes,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    ChatProvider provider,
    Map<String, dynamic> message,
  ) {
    final isMe = message['isMe'] as bool;

    if (message['type'] == 'location') {
      final isLive = message['isLive'] == true;
      final mid = message['_id']?.toString() ?? '';
      final bubble = mapMessageBubble(
        location: LatLng(
          (message['lat'] as num).toDouble(),
          (message['lng'] as num).toDouble(),
        ),
        height: 180.h,
        width: 260.w,
        isLive: isLive,
        markerIdSuffix: mid.isNotEmpty
            ? mid
            : '${message['lat']}_${message['lng']}',
      );
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: GestureDetector(
          onLongPress: isMe
              ? () => _showOwnMessageActions(context, provider, message)
              : null,
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[_bubbleAvatar(isMe), 10.w.horizontalSpace],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    _locationMessageTypeBanner(isLive: isLive),
                    bubble,
                    6.h.verticalSpace,
                    AppText(
                      text: message['time']?.toString() ?? '',
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.5),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) ...[10.w.horizontalSpace, _bubbleAvatar(isMe)],
            ],
          ),
        ),
      );
    }

    if (message['type'] == 'image') {
      final url = message['imageUrl']?.toString() ?? '';
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: GestureDetector(
          onTap: url.isNotEmpty
              ? () => _openChatImageFullScreen(context, url)
              : null,
          onLongPress: isMe
              ? () => _showOwnMessageActions(context, provider, message)
              : null,
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[_bubbleAvatar(isMe), 10.w.horizontalSpace],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: url.isEmpty
                          ? Container(
                              width: 200.w,
                              height: 160.h,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image),
                            )
                          : Image.network(
                              url,
                              width: 220.w,
                              height: 200.h,
                              fit: BoxFit.cover,
                              loadingBuilder: (c, w, ev) {
                                if (ev == null) return w;
                                return SizedBox(
                                  width: 220.w,
                                  height: 200.h,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                width: 220.w,
                                height: 120.h,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                    ),
                    6.h.verticalSpace,
                    AppText(
                      text: message['time']?.toString() ?? '',
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.5),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) ...[10.w.horizontalSpace, _bubbleAvatar(isMe)],
            ],
          ),
        ),
      );
    }

    final isAudio = message['type'] == 'audio';

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe) Row(children: [_bubbleAvatar(isMe), 10.w.horizontalSpace]),
          Flexible(
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: isMe
                    ? () => _showOwnMessageActions(context, provider, message)
                    : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isAudio
                        ? 260.w
                        : MediaQuery.sizeOf(context).width * 0.74,
                  ),
                  child: Container(
                    width: isAudio ? 260.w : null,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primaryColor.setOpacity(0.1),
                      ),
                      color: AppColors.lightgreyColor.setOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                        bottomLeft: isMe
                            ? Radius.circular(12.r)
                            : Radius.circular(0),
                        bottomRight: isMe
                            ? Radius.circular(0)
                            : Radius.circular(12.r),
                      ),
                    ),
                    child: isAudio
                        ? _buildAudioMessage(message)
                        : _buildTextMessage(message, isMe),
                  ),
                ),
              ),
            ),
          ),
          if (isMe) Row(children: [10.w.horizontalSpace, _bubbleAvatar(isMe)]),
        ],
      ),
    );
  }

  Widget _bubbleAvatar(bool isMe) {
    final url = widget.avatarUrl;
    if (url != null && url.isNotEmpty && isMe) {
      return CircleAvatar(
        radius: 22.r,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey,
      );
    }
    if (!isMe) {
      return CircleAvatar(
        radius: 22.r,
        backgroundImage: AssetImage(AppAssets.profilePhoto),
        backgroundColor: Colors.grey,
      );
    }
    return CircleAvatar(
      radius: 22.r,
      backgroundImage: AssetImage(widget.image),
      backgroundColor: Colors.grey,
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg, bool isMe) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = isMe ? TextAlign.right : TextAlign.left;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        if (!isMe)
          AppText(
            text: msg['sender']?.toString() ?? '',
            textAlign: TextAlign.left,
            style: textStyle16SemiBold.copyWith(color: AppColors.primaryColor),
          ),
        if (!isMe) 4.h.verticalSpace,
        AppText(
          text: msg['message']?.toString() ?? '',
          textAlign: textAlign,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.setOpacity(0.8),
          ),
        ),
        if (msg['edited'] == true) ...[
          4.h.verticalSpace,
          AppText(
            text: 'Edited',
            textAlign: textAlign,
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.45),
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        4.h.verticalSpace,
        AppText(
          text: msg['time']?.toString() ?? '',
          textAlign: textAlign,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.setOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioMessage(Map<String, dynamic> message) {
    return Row(
      children: [
        Icon(Icons.play_arrow_rounded, color: Colors.grey[600], size: 30.w),
        Expanded(
          child: Container(
            height: 30.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                20,
                (index) => Container(
                  width: 2.w,
                  height: 10.h + (index % 5) * 4.h,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        AppText(
          text: message['duration']?.toString() ?? '00:00',
          style: textStyle12semiBold.copyWith(color: Colors.black),
        ),
      ],
    );
  }

  /// Visual distinction: live share (green) vs one-time “current location” (amber).
  static const Color _liveLocationAccent = Color(0xFF2E7D32);
  static const Color _liveLocationTint = Color(0xFFE8F5E9);

  Widget _locationMessageTypeBanner({required bool isLive}) {
    if (isLive) {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: _liveLocationTint,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: _liveLocationAccent.setOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.radar, size: 16.sp, color: _liveLocationAccent),
              6.w.horizontalSpace,
              AppText(
                text: 'Live location',
                style: textStyle12semiBold.copyWith(
                  color: _liveLocationAccent,
                  fontSize: 12.sp,
                ),
              ),
              6.w.horizontalSpace,
              AppText(
                text: '· updating',
                style: textStyle14Regular.copyWith(
                  color: _liveLocationAccent.setOpacity(0.75),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.secondary.setOpacity(0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.secondary.setOpacity(0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 16.sp, color: AppColors.secondary),
            6.w.horizontalSpace,
            AppText(
              text: 'Current location',
              style: textStyle12semiBold.copyWith(
                color: AppColors.primaryColor,
                fontSize: 12.sp,
              ),
            ),
            6.w.horizontalSpace,
            AppText(
              text: '· one-time pin',
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.55),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapMessageBubble({
    required LatLng location,
    required double height,
    required double width,
    required bool isLive,
    required String markerIdSuffix,
  }) {
    final frameColor = isLive ? _liveLocationAccent : AppColors.secondary;
    final pinHue = isLive
        ? BitmapDescriptor.hueGreen
        : BitmapDescriptor.hueOrange;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
        border: Border.all(color: frameColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: frameColor.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: location, zoom: 14),
              markers: {
                Marker(
                  markerId: MarkerId(
                    '${isLive ? 'live' : 'pin'}_$markerIdSuffix',
                  ),
                  position: location,
                  icon: BitmapDescriptor.defaultMarkerWithHue(pinHue),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: false,
            ),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openLocationInMapsApp(
                  location.latitude,
                  location.longitude,
                ),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput(ChatProvider provider) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              constraints: BoxConstraints(minHeight: 40.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightgreyColor.setOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _textController,
                readOnly: provider.loadingMessages,
                minLines: 1,
                maxLines: 5,
                style: textStyle14Regular.copyWith(
                  color: AppColors.primaryColor,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 8.h,
                  ),
                  hintText: 'Type Here...',
                  hintStyle: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.setOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
              ),
            ),
          ),
          6.w.horizontalSpace,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _chatInputIconButton(
                onTap: _sendText,
                child: SvgIcon(
                  AppAssets.send,
                  size: 24.w,
                  color: AppColors.blueColor,
                ),
              ),
              SizedBox(width: 4.w),
              _chatInputIconButton(
                onTap: () => _pickAndUploadImage(provider, ImageSource.gallery),
                child: SvgIcon(AppAssets.photo, size: 22.w),
              ),
              SizedBox(width: 4.w),
              _chatInputIconButton(
                onTap: () => _showLocationShareSheet(context, provider),
                child: SvgIcon(
                  AppAssets.pin,
                  size: 22.w,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatInputIconButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(child: child),
        ),
      ),
    );
  }

  void _openChatImageFullScreen(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (ctx) => _ChatFullScreenImagePage(imageUrl: imageUrl),
      ),
    );
  }
}

/// Full-screen pinch-zoom viewer for chat images.
class _ChatFullScreenImagePage extends StatelessWidget {
  const _ChatFullScreenImagePage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            loadingBuilder: (context, event) {
              if (event == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final total = event.expectedTotalBytes;
              final loaded = event.cumulativeBytesLoaded;
              final value = total != null && total > 0 ? loaded / total : null;
              return Center(child: CircularProgressIndicator(value: value));
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 64,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
