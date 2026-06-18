import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/profile/office_location_model.dart';
import 'package:travel_app_abdelhamid/services/profile_content_service.dart';

import 'package:provider/provider.dart';

class OurLocationsState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  Map<String, List<OfficeLocation>> _byCountry = {};

  bool get loading => _loading;
  String? get error => _error;
  Map<String, List<OfficeLocation>> get byCountry => _byCountry;

  void loadStart() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void loadSuccess(Map<String, List<OfficeLocation>> map) {
    _byCountry = map;
    _loading = false;
    notifyListeners();
  }

  void loadError(String err) {
    _error = err;
    _loading = false;
    notifyListeners();
  }
}

class OurLocationsScreen extends StatelessWidget {
  const OurLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OurLocationsState(),
      child: const _OurLocationsView(),
    );
  }
}

class _OurLocationsView extends StatefulWidget {
  const _OurLocationsView();

  @override
  State<_OurLocationsView> createState() => _OurLocationsViewState();
}

class _OurLocationsViewState extends State<_OurLocationsView> {

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<OurLocationsState>();
    state.loadStart();
    try {
      final map = await ProfileContentService.instance.getLocations(
        showErrorToast: false,
      );
      if (!mounted) return;
      state.loadSuccess(map);
    } catch (e) {
      if (!mounted) return;
      state.loadError(userFacingApiError(e));
    }
  }

  Widget build(BuildContext context) {
    final state = context.watch<OurLocationsState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: SvgIcon(AppAssets.backIcon, size: 26.w, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    AppText(
                      text: "Our Locations".tr(),
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.loading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (state.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              else if (state.byCountry.isEmpty)
                _emptyState()
              else
                ..._buildCountrySections(state.byCountry),
              12.h.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCountrySections(Map<String, List<OfficeLocation>> byCountry) {
    final keys = byCountry.keys.toList()..sort();
    final out = <Widget>[];
    for (final country in keys) {
      final list = byCountry[country] ?? [];
      out.add(_sectionTitle("$country :"));
      for (final loc in list) {
        out.add(_locationCard(loc));
        out.add(12.h.verticalSpace);
      }
    }
    return out;
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
                Icons.location_on_outlined,
                size: 56.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              20.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text: 'No office locations yet'.tr(),
                style: textStyle16SemiBold.copyWith(
                  fontSize: 17.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              14.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text:
                    'Locations will appear here once they are added in the admin panel.'.tr(),
                style: textStyle14Regular.copyWith(
                  height: 1.5,
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      padding: EdgeInsets.only(top: 10.h, bottom: 8.w),
      child: AppText(
        text: title,
        style: textStyle16SemiBold.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _locationCard(OfficeLocation loc) {
    final lines = <String>[
      if (loc.name.trim().isNotEmpty) loc.name.trim(),
      loc.address.trim(),
      if (loc.contact.trim().isNotEmpty) 'Tel: ${loc.contact}',
      if (loc.workingHours.trim().isNotEmpty) loc.workingHours.trim(),
      if (loc.email.trim().isNotEmpty) loc.email.trim(),
    ].where((s) => s.isNotEmpty).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines
              .map(
                (text) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "•  ",
                        style: textStyle12Regular.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Expanded(
                        child: AppText(
                          text: text,
                          style: textStyle12Regular.copyWith(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
