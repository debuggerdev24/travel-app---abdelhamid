import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/model/cms/cms_models.dart';
import 'package:trael_app_abdelhamid/services/cms_content_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaScreen extends StatefulWidget {
  const SocialMediaScreen({super.key});

  @override
  State<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends State<SocialMediaScreen> {
  bool _loading = true;
  String? _error;
  List<SocialLinkItem> _items = [];

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
      final list = await CmsContentService.instance.getSocials(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _items = list;
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

  String _fallbackAssetForName(String name) {
    final n = name.toLowerCase();
    if (n.contains('instagram')) return AppAssets.instagram;
    if (n.contains('tiktok')) return AppAssets.tiktok;
    if (n.contains('facebook')) return AppAssets.facebook;
    if (n.contains('whatsapp')) return AppAssets.whatsapp;
    if (n.contains('google') || n.contains('review')) return AppAssets.starFill;
    return AppAssets.starFill;
  }

  Future<void> _openLink(String raw) async {
    final u = raw.trim();
    if (u.isEmpty) return;
    final uri = Uri.tryParse(u);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _leadingIcon(SocialLinkItem item) {
    final url = serverMediaUrl(item.iconRaw);
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          url,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              SvgIcon(_fallbackAssetForName(item.name), size: 40.w),
        ),
      );
    }
    return SvgIcon(_fallbackAssetForName(item.name), size: 40.w);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 35.h),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  50.w.horizontalSpace,
                  AppText(
                    textAlign: TextAlign.center,
                    text: "Social Media \nLinks",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              12.h.verticalSpace,
              AppText(
                text:
                    "Stay connected with us! Follow our latest updates, photos, and travel stories on social media.",
                style: textStyle14Regular.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.textcolor.setOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              22.h.verticalSpace,
              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              else if (_error != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
              else if (_items.isEmpty)
                Expanded(
                  child: Center(
                    child: AppText(
                      text: "No social links available yet.",
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.6),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return GestureDetector(
                        onTap: () => _openLink(item.link),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 20.w,
                          ),
                          decoration: BoxDecoration(
                            border: BoxBorder.all(
                              color: AppColors.primaryColor.setOpacity(0.2),
                            ),
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blueColor.setOpacity(0.1),
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _leadingIcon(item),
                              14.w.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      text: item.name.isNotEmpty
                                          ? item.name
                                          : 'Link',
                                      style: textStyle16SemiBold.copyWith(
                                        fontSize: 18.sp,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    if (item.description.isNotEmpty)
                                      AppText(
                                        text: item.description,
                                        style: textStyle14Regular.copyWith(
                                          fontSize: 14.sp,
                                          color: AppColors.primaryColor
                                              .setOpacity(0.8),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 24.h),
                                child: Icon(
                                  Icons.open_in_new,
                                  size: 24.w,
                                  color: AppColors.blueColor,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
