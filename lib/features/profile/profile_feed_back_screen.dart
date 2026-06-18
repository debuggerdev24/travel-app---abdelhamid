import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/services/profile_content_service.dart';

class ProfileFeedbackState extends ChangeNotifier {
  bool _submitting = false;

  bool get submitting => _submitting;

  void setSubmitting(bool value) {
    _submitting = value;
    notifyListeners();
  }
}

class ProfileFeedbackScreen extends StatelessWidget {
  const ProfileFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileFeedbackState(),
      child: const _ProfileFeedbackView(),
    );
  }
}

class _ProfileFeedbackView extends StatefulWidget {
  const _ProfileFeedbackView();

  @override
  State<_ProfileFeedbackView> createState() => _ProfileFeedbackViewState();
}

class _ProfileFeedbackViewState extends State<_ProfileFeedbackView> {
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
    final state = context.read<ProfileFeedbackState>();
    if (state.submitting) return;
    final rating = ratingProvider.rating;
    if (rating < 1) {
      ToastHelper.showError('Please select a star rating.'.tr());
      return;
    }
    final text = reviewController.text.trim();
    if (text.isEmpty) {
      ToastHelper.showError('Please write your feedback.'.tr());
      return;
    }
    state.setSubmitting(true);
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
      ToastHelper.showSuccess('Thank you for your feedback!'.tr());
      context.pop();
    } catch (_) {
      // Error toast from API layer
    } finally {
      if (mounted) state.setSubmitting(false);
    }
  }

  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<TripProvider>(context);
    final state = context.watch<ProfileFeedbackState>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Dismiss any active toasts when leaving the screen
          ToastHelper.dismiss();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                                onTap: () {
                                  ToastHelper.dismiss();
                                  context.pop();
                                },
                                child: SvgPicture.asset(
                                  AppAssets.backIcon,
                                  width: 28.5.w,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            AppText(
                              text: "Your Feedback".tr(),
                              style: textStyle32Bold.copyWith(
                                fontSize: 26.sp,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),

                        25.h.verticalSpace,

                        AppText(
                          text: "How was your experience with the app?".tr(),
                          style: textStyle16SemiBold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        52.h.verticalSpace,

                        AppText(
                          text: "Your feedback helps us improve!".tr(),
                          style: textStyle16SemiBold.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        16.h.verticalSpace,

                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: AppTextField(
                            controller: reviewController,
                            hintText: "Write your feedback here...".tr(),
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
                  isLoading: state.submitting,
                  onTap: () => _submit(context, ratingProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
