import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/cms/cms_models.dart';
import 'package:trael_app_abdelhamid/services/cms_content_service.dart';

class TermsConditionScreen extends StatefulWidget {
  const TermsConditionScreen({super.key});

  @override
  State<TermsConditionScreen> createState() => _TermsConditionScreenState();
}

class _TermsConditionScreenState extends State<TermsConditionScreen> {
  bool _loading = true;
  String? _error;
  List<RuleSection> _sections = [];

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
      final list = await CmsContentService.instance.getRules(
        'terms',
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _sections = list;
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

  bool _hasRenderableContent() {
    for (final s in _sections) {
      if (s.title.trim().isNotEmpty) return true;
      for (final t in s.terms) {
        if (t.trim().isNotEmpty) return true;
      }
    }
    return false;
  }

  Widget _emptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, bottom: 32.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 320.w),
          child: Column(
            children: [
              Icon(
                Icons.gavel_outlined,
                size: 56.sp,
                color: AppColors.primaryColor.setOpacity(0.35),
              ),
              20.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text: 'Terms & conditions are not available yet',
                style: textStyle16SemiBold.copyWith(
                  fontSize: 17.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              14.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text:
                    'We could not load any terms from the server. This content is usually added by your travel team in the admin panel.\n\nPlease try again later, or contact support if you need a copy of the terms.',
                style: textStyle14Regular.copyWith(
                  height: 1.5,
                  fontSize: 14.sp,
                  color: AppColors.primaryColor.setOpacity(0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 12.h),
      child: AppText(
        text: title,
        style: textStyle16SemiBold.copyWith(
          fontSize: 16.sp,
          color: AppColors.primaryColor.setOpacity(0.8),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•  ",
            style: textStyle14Regular.copyWith(
              fontSize: 14.sp,
              color: AppColors.textcolor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(
                fontSize: 14.sp,
                color: AppColors.textcolor.setOpacity(0.6),
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
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              21.h.verticalSpace,
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 26.w),
                    ),
                  ),
                  AppText(
                    text: "Terms & Conditions",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: _error!,
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
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
              else if (!_hasRenderableContent())
                _emptyState()
              else
                ..._sections.expand((section) {
                  return [
                    _sectionTitle(section.title),
                    ...section.terms.map(_bullet),
                  ];
                }),
              40.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
