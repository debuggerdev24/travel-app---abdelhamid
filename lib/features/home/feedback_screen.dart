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
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/services/profile_content_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController reviewController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context, TripProvider ratingProvider) async {
    if (_submitting) return;
    final tripId = ratingProvider.selectedTrip?.id;
    if (tripId == null || tripId.isEmpty) {
      ToastHelper.showError('Select a trip first, then try again.');
      return;
    }
    final rating = ratingProvider.rating;
    if (rating < 1) {
      ToastHelper.showError('Please select a star rating.');
      return;
    }
    final text = reviewController.text.trim();
    if (text.isEmpty) {
      ToastHelper.showError('Please enter your review.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ProfileContentService.instance.submitReview(
        forTrip: true,
        rating: rating,
        review: text,
        tripId: tripId,
        showErrorToast: true,
      );
      if (!context.mounted) return;
      ratingProvider.setReview(text);
      ratingProvider.submitReview();
      ToastHelper.showSuccess('Thank you for your review!');
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
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: SvgPicture.asset(
                              AppAssets.backIcon,
                              width: 28.5.w,
                            ),
                          ),
                          24.w.horizontalSpace,
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
                        text:
                            "Give this trip a star rating based on your experience.",
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
                              padding: EdgeInsets.only(right: 12.r),
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
                        text: "Traveler's Review",
                        style: textStyle16SemiBold,
                      ),

                      16.h.verticalSpace,

                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blueColor.setOpacity(0.12),
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: AppTextField(
                          controller: reviewController,
                          hintText: "Enter Comment Here...",
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
