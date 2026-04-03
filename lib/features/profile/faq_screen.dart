import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/cms/cms_models.dart';
import 'package:trael_app_abdelhamid/services/cms_content_service.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _loading = true;
  String? _error;
  List<FaqItem> _faqs = [];
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await CmsContentService.instance.getFaqs(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _faqs = list;
        _expanded = List<bool>.generate(
          list.length,
          (i) => i == 0,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingApiError(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                      ),
                    ),
                    AppText(
                      text: "FAQ",
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(
                    color: AppColors.primaryColor.setOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.setOpacity(0.08),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: SvgIcon(AppAssets.faq, size: 34.w),
                    ),
                    12.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: "Travel-related FAQs",
                            style: textStyle16SemiBold.copyWith(
                              fontSize: 18.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          AppText(
                            text: "Answers from your travel team",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor.setOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              20.h.verticalSpace,

              if (_loading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      AppText(
                        text: _error!,
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      16.h.verticalSpace,
                      TextButton(
                        onPressed: _load,
                        child: AppText(
                          text: "Retry",
                          style: textStyle14Medium.copyWith(
                            color: AppColors.blueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_faqs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: AppText(
                    text: "No FAQs available yet.",
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.6),
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: _faqs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    final isExpanded = index < _expanded.length
                        ? _expanded[index]
                        : false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (index < _expanded.length) {
                                _expanded[index] = !isExpanded;
                              }
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AppText(
                                    text: faq.question,
                                    style: textStyle16SemiBold.copyWith(
                                      fontSize: 16.sp,
                                      color: AppColors.primaryColor.setOpacity(
                                        0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blueColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isExpanded ? Icons.remove : Icons.add,
                                      size: 18.w,
                                      color: AppColors.blueColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          AppText(
                            text: faq.answer,
                            style: textStyle14Regular.copyWith(
                              fontSize: 14.sp,
                              color: AppColors.textcolor.setOpacity(0.6),
                            ),
                          ),
                        const Divider(color: Colors.black12, thickness: 1),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
