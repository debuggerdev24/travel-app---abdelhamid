import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class ChatDetailScreen extends StatelessWidget {
  final String name;
  final String image;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.image,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 18.h,
                        horizontal: 27.w,
                      ),
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                      ),
                    ),
                    AppText(
                      textAlign: TextAlign.center,
                      text: name,
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                    if (!isGroup) 35.w.horizontalSpace,

                    GestureDetector(
                      onTap: () {
                        if (isGroup) {
                          context.pushNamed(
                            UserAppRoutes.groupInfoScreen.name,
                            extra: {'name': name, 'image': image},
                          );
                        } else {}
                      },
                      child: isGroup
                          ? SvgIcon(AppAssets.info, size: 24.w)
                          : SvgIcon(
                              AppAssets.call,
                              size: 24.w,
                              color: AppColors.greyColor,
                            ),
                    ),
                    8.w.horizontalSpace,
                    if (!isGroup)
                      GestureDetector(
                        onTap: () async {
                          final result = await context.pushNamed(
                            UserAppRoutes.liveLocationScreen.name,
                          );

                          if (result != null && result is Map) {
                            // ignore: use_build_context_synchronously
                            Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            ).addLocationMessage(
                              lat: result["lat"],
                              lng: result["lng"],
                            );
                          }
                        },
                        child: SvgIcon(
                          AppAssets.location,
                          size: 24.w,
                          color: AppColors.greyColor,
                        ),
                      ),
                  ],
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      vertical: 18.h,
                      horizontal: 27.w,
                    ),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageItem(provider.messages[index]);
                    },
                  ),
                ),

                _buildBottomInput(provider),
              ],
            ),

            if (provider.showAttachmentMenu)
              Positioned(
                bottom: 80.h,
                right: 20.w,
                child: _buildAttachmentMenu(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;

    /// NEW: If message type is LOCATION
    if (message['type'] == 'location') {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isMe)
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: AssetImage(AppAssets.profilephoto),
                  ),
                  10.w.horizontalSpace,
                ],
              ),

            mapMessageBubble(
              location: LatLng(message["lat"], message["lng"]),
              height: 180.h,
              width: 260.w,
            ),

            if (isMe)
              Row(
                children: [
                  10.w.horizontalSpace,
                  CircleAvatar(
                    radius: 22.r,
                    backgroundImage: AssetImage(AppAssets.profilephoto),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    /// ELSE → Normal TEXT / AUDIO message
    final isAudio = message['type'] == 'audio';

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage: AssetImage(AppAssets.profilephoto),
                ),
                10.w.horizontalSpace,
              ],
            ),

          Flexible(
            child: Container(
              width: isAudio ? 260.w : 220.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.1),
                ),
                color: AppColors.lightgreyColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                  bottomLeft: isMe ? Radius.circular(12.r) : Radius.circular(0),
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

          if (isMe)
            Row(
              children: [
                10.w.horizontalSpace,
                CircleAvatar(
                  radius: 22.r,
                  backgroundImage: AssetImage(AppAssets.profilephoto),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> msg, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe)
          Align(
            alignment: Alignment.topLeft,
            child: AppText(
              text: msg['sender'],
              style: textStyle16SemiBold.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        if (!isMe) 4.h.verticalSpace,
        AppText(
          text: msg['message'],
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.8),
          ),
        ),
        4.h.verticalSpace,
        AppText(
          text: msg['time'],
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.6),
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
          text: message['duration'],
          style: textStyle12semiBold.copyWith(color: Colors.black),
        ),
      ],
    );
  }

  Widget mapMessageBubble({
    required LatLng location,
    required double height,
    required double width,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: location, zoom: 14),
          markers: {
            Marker(
              markerId: const MarkerId("sharedLocation"),
              position: location,
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          scrollGesturesEnabled: false,
        ),
      ),
    );
  }

  Widget _buildBottomInput(ChatProvider provider) {
    if (provider.isRecording) {
      return _buildRecordingBar(provider);
    }

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.lightgreyColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type Here...',
                  hintStyle: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          10.w.horizontalSpace,
          GestureDetector(
            onTap: provider.toggleAttachmentMenu,
            child: SvgIcon(AppAssets.attachment, size: 24.w),
          ),
          10.w.horizontalSpace,
          GestureDetector(
            onTap: provider.startRecording,
            child: SvgIcon(AppAssets.micphone, size: 48.w),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingBar(ChatProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        30,
                        (i) => Container(
                          width: 2.w,
                          height: 10.h + (i % 3) * 5.h,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  10.w.horizontalSpace,
                  GestureDetector(
                    onTap: provider.stopRecording,
                    child: Container(
                      height: 48.h,
                      width: 48.w,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                        color: AppColors.blueColor,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: SvgIcon(AppAssets.send, size: 30.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          10.w.horizontalSpace,
          GestureDetector(
            onTap: provider.stopRecording,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.redColor,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgIcon(AppAssets.delete),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentMenu() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAttachmentItem(AppAssets.photo, 'Image/Video'),
          Divider(height: 10.h),
          _buildAttachmentItem(AppAssets.camera, 'Camera'),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgIcon(icon, size: 20.w, color: Colors.grey[700]),
          10.w.horizontalSpace,
          AppText(
            text: label,
            style: textStyle14Medium.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
