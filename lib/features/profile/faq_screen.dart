import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/cms/cms_models.dart';
import 'package:travel_app_abdelhamid/services/cms_content_service.dart';

import 'package:provider/provider.dart';

class FaqState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<FaqItem> _faqs = [];
  List<bool> _expanded = [];

  bool get loading => _loading;
  String? get error => _error;
  List<FaqItem> get faqs => _faqs;
  List<bool> get expanded => _expanded;

  void loadStart() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void loadSuccess(List<FaqItem> list) {
    _faqs = list;
    _expanded = List<bool>.generate(list.length, (i) => i == 0);
    _loading = false;
    notifyListeners();
  }

  void loadError(String err) {
    _error = err;
    _loading = false;
    notifyListeners();
  }

  void toggleExpanded(int index) {
    if (index < _expanded.length) {
      _expanded[index] = !_expanded[index];
      notifyListeners();
    }
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FaqState(),
      child: const _FaqView(),
    );
  }
}

class _FaqView extends StatefulWidget {
  const _FaqView();

  @override
  State<_FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<_FaqView> {

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<FaqState>();
    state.loadStart();
    try {
      final list = await CmsContentService.instance.getFaqs(
        showErrorToast: false,
      );
      if (!mounted) return;
      state.loadSuccess(list);
    } catch (e) {
      if (!mounted) return;
      state.loadError(userFacingApiError(e));
    }
  }

  Widget build(BuildContext context) {
    final state = context.watch<FaqState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    AppText(
                      text: "FAQ".tr(),
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                            text: "Travel-related FAQs".tr(),
                            style: textStyle16SemiBold.copyWith(
                              fontSize: 18.sp,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          AppText(
                            text: "Answers from your travel team".tr(),
                            style: textStyle14Regular.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              20.h.verticalSpace,

              if (state.loading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              else if (state.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      AppText(
                        text: state.error!,
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      16.h.verticalSpace,
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
              else if (state.faqs.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: AppText(
                    text: "No FAQs available yet.".tr(),
                    style: textStyle14Regular.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ListView.builder(
                  itemCount: state.faqs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final faq = state.faqs[index];
                    final isExpanded = index < state.expanded.length
                        ? state.expanded[index]
                        : false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.read<FaqState>().toggleExpanded(index);
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
