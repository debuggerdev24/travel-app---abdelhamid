import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/services/profile_content_service.dart';

class ProfileFeedbackScreen extends StatefulWidget {
  const ProfileFeedbackScreen({super.key});

  @override
  State<ProfileFeedbackScreen> createState() => _ProfileFeedbackScreenState();
}

class _ProfileFeedbackScreenState extends State<ProfileFeedbackScreen> {
  final TextEditingController reviewController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context, TripProvider ratingProvider) async {
    if (_submitting) return;
    final rating = ratingProvider.rating;
    if (rating < 1) {
      ToastHelper.showError('Please select a star rating.');
      return;
    }
    final text = reviewController.text.trim();
    if (text.isEmpty) {
      ToastHelper.showError('Please write your feedback.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ProfileContentService.instance.submitReview(
        forTrip: false,
        rating: rating,
        review: text,
        showErrorToast: true,
      );
      if (!context.mounted) return;
      ratingProvider.setReview(text);
      ratingProvider.submitReview();
      ToastHelper.showSuccess('Thank you for your feedback!');
      context.pop();
    } catch (_) {
      // Error toast from API layer
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<TripProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 15.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: SvgPicture.asset(
                                AppAssets.backIcon,
                                width: 28.5.w,
                              ),
                            ),
                          ),

                          AppText(
                            text: "Your Feedback",
                            style: textStyle32Bold.copyWith(
                              fontSize: 26.sp,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),

                      25.h.verticalSpace,

                      AppText(
                        text: "How was your experience with the app?",
                        style: textStyle16SemiBold,
                      ),

                      28.h.verticalSpace,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () {
                              ratingProvider.setRating(index + 1);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 20.r),
                              child: SvgPicture.asset(
                                index < ratingProvider.rating
                                    ? AppAssets.starFill
                                    : AppAssets.star,
                                width: 49.w,
                                color: AppColors.lightYellowColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      52.h.verticalSpace,

                      AppText(
                        text: "Your feedback helps us improve!",
                        style: textStyle16SemiBold,
                      ),

                      16.h.verticalSpace,

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueColor.setOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: AppTextField(
                          controller: reviewController,
                          hintText: "Write your feedback here...”",
                          maxLines: 4,
                        ),
                      ),

                      16.h.verticalSpace,
                    ],
                  ),
                ),
              ),

              AppButton(
                title: "Done",
                isLoading: _submitting,
                onTap: () => _submit(context, ratingProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
