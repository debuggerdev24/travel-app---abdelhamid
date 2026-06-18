import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/profile/team_member_model.dart';
import 'package:travel_app_abdelhamid/services/profile_content_service.dart';

import 'package:provider/provider.dart';

class MeetOurTeamState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<TeamMemberModel> _members = [];

  bool get loading => _loading;
  String? get error => _error;
  List<TeamMemberModel> get members => _members;

  void loadStart() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void loadSuccess(List<TeamMemberModel> list) {
    _members = list;
    _loading = false;
    notifyListeners();
  }

  void loadError(String err) {
    _error = err;
    _loading = false;
    notifyListeners();
  }
}

class MeetOurTeamScreen extends StatelessWidget {
  const MeetOurTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeetOurTeamState(),
      child: const _MeetOurTeamView(),
    );
  }
}

class _MeetOurTeamView extends StatefulWidget {
  const _MeetOurTeamView();

  @override
  State<_MeetOurTeamView> createState() => _MeetOurTeamViewState();
}

class _MeetOurTeamViewState extends State<_MeetOurTeamView> {

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final state = context.read<MeetOurTeamState>();
    state.loadStart();
    try {
      final list = await ProfileContentService.instance.getTeamMembers(
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
    final state = context.watch<MeetOurTeamState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              22.h.verticalSpace,
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  AppText(
                    text: "Meet Our Team".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              22.h.verticalSpace,
              Expanded(child: _buildBody(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(MeetOurTeamState state) {
    if (state.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    if (state.error != null) {
      return Padding(
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
      );
    }
    if (state.members.isEmpty) {
      return SingleChildScrollView(child: _emptyState());
    }
    return ListView.separated(
      itemCount: state.members.length,
      separatorBuilder: (_, __) => 24.h.verticalSpace,
      itemBuilder: (context, index) {
        final m = state.members[index];
        return _teamCard(m);
      },
    );
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
                Icons.groups_outlined,
                size: 56.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              20.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text: 'No team members yet'.tr(),
                style: textStyle16SemiBold.copyWith(
                  fontSize: 17.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              14.h.verticalSpace,
              AppText(
                textAlign: TextAlign.center,
                text:
                    'Team profiles will show here once they are added in the admin panel.'.tr(),
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

  Widget _teamCard(TeamMemberModel member) {
    final imageUrl = serverMediaUrl(member.profilePictureRaw);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                  )
                : _avatarPlaceholder(),
          ),
          16.w.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        text: member.name,
                        style: textStyle14Medium.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    6.w.horizontalSpace,
                    AppText(
                      text: member.roleLabel,
                      style: textStyle14Medium.copyWith(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                4.h.verticalSpace,
                AppText(
                  text: member.description,
                  style: textStyle12Regular.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 80.w,
      height: 80.w,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person_outline,
        size: 40.sp,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
