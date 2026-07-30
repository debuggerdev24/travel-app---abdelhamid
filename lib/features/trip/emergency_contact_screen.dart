import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/model/essential/emergency_contacts_model.dart';
import 'package:travel_app_abdelhamid/services/essential_service.dart';

class EmergencyContactsState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  EmergencyContactsData? _data;

  bool get loading => _loading;
  String? get error => _error;
  EmergencyContactsData? get data => _data;

  EmergencyContactsState() {
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await EssentialService.instance.getEmergencyContacts(
        showErrorToast: false,
      );
      _data = data;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = userFacingApiError(e);
      _loading = false;
      notifyListeners();
    }
  }
}

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmergencyContactsState(),
      child: const _EmergencyContactsScreenView(),
    );
  }
}

class _EmergencyContactsScreenView extends StatelessWidget {
  const _EmergencyContactsScreenView();

  List<Widget> _buildCards(EmergencyContactsData d) {
    final cards = <Widget>[];

    final medical = d.medical;
    if (medical != null) {
      final rows = <List<String>>[];
      final label =
          (medical.contactType != null && medical.contactType!.isNotEmpty)
          ? medical.contactType!
          : "Medical";
      if (medical.hospitalNumber != null &&
          medical.hospitalNumber!.isNotEmpty) {
        rows.add([label, medical.hospitalNumber!]);
      }
      if (medical.ambulanceCode != null && medical.ambulanceCode!.isNotEmpty) {
        rows.add(["Ambulance", medical.ambulanceCode!]);
      }
      if (rows.isNotEmpty) {
        cards.add(_contactCard(context: null, title: "Medical".tr(), rows: rows));
      }
    }

    final police = d.police;
    if (police != null &&
        police.policeHelpline != null &&
        police.policeHelpline!.isNotEmpty) {
      final pl = police.policeHelpline!;
      final title =
          (police.contactType != null && police.contactType!.isNotEmpty)
          ? police.contactType!
          : "Police";
      cards.add(
        _contactCard(
          context: null,
          title: "Police".tr(),
          rows: [
            [title, pl],
          ],
        ),
      );
    }

    final gl = d.groupLeader;
    if (gl != null) {
      final rows = <List<String>>[];
      if (gl.leaderName != null && gl.leaderName!.isNotEmpty) {
        rows.add(["Name", gl.leaderName!]);
      }
      if (gl.leaderNumber != null && gl.leaderNumber!.isNotEmpty) {
        rows.add(["Phone", gl.leaderNumber!]);
      }
      if (gl.whatsappNumber != null && gl.whatsappNumber!.isNotEmpty) {
        rows.add(["WhatsApp", gl.whatsappNumber!]);
      }
      if (rows.isNotEmpty) {
        cards.add(
          _contactCard(
            context: null,
            title: (gl.contactType != null && gl.contactType!.isNotEmpty)
                ? gl.contactType!
                : "Group Leader",
            rows: rows,
          ),
        );
      }
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 31.w, vertical: 27.h),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  13.w.horizontalSpace,
                  AppText(
                    text: "Emergency Contacts".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = context.watch<EmergencyContactsState>();

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: "Couldn't load emergency contacts",
              textAlign: TextAlign.center,
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            10.h.verticalSpace,
            AppText(
              text: state.error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            16.h.verticalSpace,
            TextButton(
              onPressed: () => context.read<EmergencyContactsState>().load(),
              child: AppText(
                text: "Retry".tr(),
                style: textStyle14Medium.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return RefreshIndicator(
        onRefresh: () => context.read<EmergencyContactsState>().load(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27.w),
                    child: AppText(
                      text: "No emergency contacts available".tr(),
                      textAlign: TextAlign.center,
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    final cards = _buildCards(data).map((w) => _injectContext(w, context)).toList();
    if (cards.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<EmergencyContactsState>().load(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: "No emergency contacts available".tr(),
                    textAlign: TextAlign.center,
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.7),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<EmergencyContactsState>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        children: cards,
      ),
    );
  }

  Widget _injectContext(Widget w, BuildContext context) {
    if (w is _ContactCardWidget) {
      return _ContactCardWidget(
        title: w.title,
        rows: w.rows,
        context: context,
      );
    }
    return w;
  }

  Widget _contactCard({
    required String title,
    required List<List<String>> rows,
    BuildContext? context,
  }) {
    return _ContactCardWidget(
      title: title,
      rows: rows,
      context: context,
    );
  }
}

class _ContactCardWidget extends StatelessWidget {
  final String title;
  final List<List<String>> rows;
  final BuildContext? context;

  const _ContactCardWidget({
    required this.title,
    required this.rows,
    this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    final ctx = context ?? buildContext;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueColor.setOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  fontSize: 18.sp,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              SvgIcon(AppAssets.phone, color: AppColors.secondary, size: 24.w),
            ],
          ),
          12.h.verticalSpace,
          ...rows.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120.w,
                    child: AppText(
                      text: e[0],
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(ctx).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AppText(
                    text: " : ",
                    style: textStyle14Regular.copyWith(
                      fontSize: 16.sp,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: e[1],
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(ctx).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
