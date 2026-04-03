import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/essential/emergency_contacts_model.dart';
import 'package:trael_app_abdelhamid/services/essential_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  bool _loading = true;
  String? _error;
  EmergencyContactsData? _data;

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
      final data = await EssentialService.instance.getEmergencyContacts(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
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
      if (medical.ambulanceCode != null &&
          medical.ambulanceCode!.isNotEmpty) {
        rows.add(["Ambulance", medical.ambulanceCode!]);
      }
      if (rows.isNotEmpty) {
        cards.add(_contactCard(title: "Medical", rows: rows));
      }
    }

    final police = d.police;
    if (police != null && police.policeHelpline != null &&
        police.policeHelpline!.isNotEmpty) {
      final pl = police.policeHelpline!;
      final title = (police.contactType != null &&
              police.contactType!.isNotEmpty)
          ? police.contactType!
          : "Police";
      cards.add(
        _contactCard(
          title: "Police",
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
      backgroundColor: Colors.white,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  13.w.horizontalSpace,
                  AppText(
                    text: "Emergency Contacts",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: "Couldn't load emergency contacts",
              textAlign: TextAlign.center,
              style: textStyle14Medium.copyWith(
                color: AppColors.primaryColor.setOpacity(0.85),
              ),
            ),
            10.h.verticalSpace,
            AppText(
              text: _error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
            16.h.verticalSpace,
            TextButton(
              onPressed: _load,
              child: AppText(
                text: "Retry",
                style: textStyle14Medium.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return RefreshIndicator(
        onRefresh: _load,
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
                      text: "No emergency contacts available",
                      textAlign: TextAlign.center,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.7),
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

    final cards = _buildCards(data);
    if (cards.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: "No emergency contacts available",
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
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        children: cards,
      ),
    );
  }

  Widget _contactCard({
    required String title,
    required List<List<String>> rows,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: AppColors.primaryColor.setOpacity(0.8),
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
                        color: AppColors.primaryColor.setOpacity(0.8),
                      ),
                    ),
                  ),
                  AppText(
                    text: " : ",
                    style: textStyle14Regular.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.primaryColor.setOpacity(0.8),
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      text: e[1],
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primaryColor.setOpacity(0.8),
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
