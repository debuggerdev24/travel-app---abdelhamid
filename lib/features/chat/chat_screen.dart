import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/chat/chat_model.dart';
import 'package:trael_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';


class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: provider.chatList.length,
                    separatorBuilder: (context, index) => 20.h.verticalSpace,
                    itemBuilder: (context, index) {
                      return _buildChatItem(context, provider.chatList[index]);
                    },
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
              color: AppColors.secondary,
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
            color: AppColors.lightblueColor,
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
          color: isSelected ? Colors.white : Colors.transparent,
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
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatModel data) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          UserAppRoutes.chatDetailScreen.name,
          extra: {
            'name': data.name,
            'image': data.image,
            'isGroup': data.isGroup,
          },
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: AssetImage(data.image),
            backgroundColor: Colors.grey,
          ),
          15.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: data.name,
                      style: textStyle18Bold.copyWith(
                        color: AppColors.primaryColor,
                        fontSize: 16.sp,
                      ),
                    ),
                    AppText(
                      text: data.time,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.4),
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
                          color: AppColors.primaryColor.setOpacity(0.4),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (data.unread > 0)
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          shape: BoxShape.circle,
                        ),
                        child: AppText(
                          text: data.unread.toString(),
                          style: textStyle18Bold.copyWith(
                            color: Colors.white,
                            fontSize: 12.sp,
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
    );
  }
}
