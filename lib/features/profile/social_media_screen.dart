import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/model/cms/cms_models.dart';
import 'package:travel_app_abdelhamid/services/cms_content_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<SocialLinkItem> _items = [];

  bool get loading => _loading;
  String? get error => _error;
  List<SocialLinkItem> get items => _items;

  void loadStart() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void loadSuccess(List<SocialLinkItem> list) {
    _items = list;
    _loading = false;
    notifyListeners();
  }

  void loadError(String err) {
    _error = err;
    _loading = false;
    notifyListeners();
  }
}

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SocialMediaState(),
      child: const _SocialMediaView(),
    );
  }
}

class _SocialMediaView extends StatefulWidget {
  const _SocialMediaView();

  @override
  State<_SocialMediaView> createState() => _SocialMediaViewState();
}

class _SocialMediaViewState extends State<_SocialMediaView> {

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<SocialMediaState>();
    state.loadStart();
    try {
      final list = await CmsContentService.instance.getSocials(
        showErrorToast: false,
      );
      if (!mounted) return;
      state.loadSuccess(list);
    } catch (e) {
      if (!mounted) return;
      state.loadError(userFacingApiError(e));
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

  Widget build(BuildContext context) {
    final state = context.watch<SocialMediaState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  50.w.horizontalSpace,
                  AppText(
                    textAlign: TextAlign.center,
                    text: "Social Media \nLinks".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              12.h.verticalSpace,
              AppText(
                text:
                    "Stay connected with us! Follow our latest updates, photos, and travel stories on social media.".tr(),
                style: textStyle14Regular.copyWith(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              22.h.verticalSpace,
              if (state.loading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (state.error != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text: state.error!,
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: _load,
                        child: AppText(
                          text: "Retry".tr(),
                          style: textStyle14Medium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (state.items.isEmpty)
                Expanded(
                  child: Center(
                    child: AppText(
                      text: "No social links available yet.".tr(),
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return GestureDetector(
                        onTap: () => _openLink(item.link),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(
                            vertical: 15.h,
                            horizontal: 20.w,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
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
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    if (item.description.isNotEmpty)
                                      AppText(
                                        text: item.description,
                                        style: textStyle14Regular.copyWith(
                                          fontSize: 14.sp,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
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
                                  color: Theme.of(context).colorScheme.primary,
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
