import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/services/profile_content_service.dart';

class FeedbackState extends ChangeNotifier {
  bool _submitting = false;
  bool get submitting => _submitting;
  void setSubmitting(bool value) {
    _submitting = value;
    notifyListeners();
  }
}

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackState(),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final TextEditingController reviewController = TextEditingController();

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    BuildContext context,
    TripProvider ratingProvider,
  ) async {
    final state = context.read<FeedbackState>();
    if (state.submitting) return;
    final tripId = ratingProvider.selectedTrip?.id;
    if (tripId == null || tripId.isEmpty) {
      ToastHelper.showError('Select a trip first, then try again.'.tr());
      return;
    }
    final rating = ratingProvider.rating;
    if (rating < 1) {
      ToastHelper.showError('Please select a star rating.'.tr());
      return;
    }
    final text = reviewController.text.trim();
    if (text.isEmpty) {
      ToastHelper.showError('Please enter your review.'.tr());
      return;
    }
    state.setSubmitting(true);
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
      ToastHelper.showSuccess('Thank you for your review!'.tr());
      context.pop();
    } catch (_) {
      // Error toast from API layer
    } finally {
      if (mounted) state.setSubmitting(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<TripProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onSurface,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          24.w.horizontalSpace,
                          AppText(
                            text: "Your Feedback".tr(),
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
                            "Give this trip a star rating based on your experience.".tr(),
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
                        text: "Traveler's Review".tr(),
                        style: textStyle16SemiBold,
                      ),

                      16.h.verticalSpace,

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
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
                          hintText: "Enter Comment Here...".tr(),
                          maxLines: 4,
                        ),
                      ),

                      16.h.verticalSpace,
                    ],
                  ),
                ),
              ),

              AppButton(
                title: "Done".tr(),
                isLoading: context.watch<FeedbackState>().submitting,
                onTap: () => _submit(context, ratingProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
