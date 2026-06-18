import 'package:easy_localization/easy_localization.dart';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/dua/dua_item_model.dart';
import 'package:travel_app_abdelhamid/services/dua_service.dart';

import 'package:provider/provider.dart';

class DuaListState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<DuaItemModel> _items = const [];

  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  StreamSubscription<void>? _completeSub;

  bool get loading => _loading;
  String? get error => _error;
  List<DuaItemModel> get items => _items;
  String? get playingId => _playingId;

  DuaListState() {
    _completeSub = _player.onPlayerComplete.listen((_) {
      _playingId = null;
      notifyListeners();
    });
    load();
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _player.stop();
      _playingId = null;
      notifyListeners();

      final list = await DuaService.instance.fetchDuas(showErrorToast: false);
      _items = list;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = userFacingApiError(e);
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay(DuaItemModel dua, BuildContext context) async {
    final url = serverMediaUrl(dua.audioPath);
    if (url == null || url.isEmpty) return;

    try {
      if (_playingId == dua.id) {
        await _player.stop();
        _playingId = null;
        notifyListeners();
        return;
      }
      await _player.stop();
      _playingId = dua.id;
      notifyListeners();
      await _player.play(UrlSource(url));
    } catch (_) {
      _playingId = null;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not play audio'.tr())));
      }
    }
  }
}

class DuaListScreen extends StatelessWidget {
  const DuaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DuaListState(),
      child: const _DuaListScreenView(),
    );
  }
}

class _DuaListScreenView extends StatelessWidget {
  const _DuaListScreenView();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: 'Dua List'.tr(),
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 28.5.w),
                ],
              ),
              16.h.verticalSpace,
              Expanded(child: _body(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = context.watch<DuaListState>();

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: "Couldn't load dua list",
            textAlign: TextAlign.center,
            style: textStyle14Medium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          10.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: AppText(
              text: state.error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          16.h.verticalSpace,
          TextButton(
            onPressed: () => context.read<DuaListState>().load(),
            child: AppText(
              text: 'Retry'.tr(),
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<DuaListState>().load(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: 'No duas available yet'.tr(),
                    textAlign: TextAlign.center,
                    style: textStyle14Regular.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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
      onRefresh: () => context.read<DuaListState>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          final dua = state.items[index];
          return _DuaItemTile(
            dua: dua,
            isPlaying: state.playingId == dua.id,
            onPlayTap: () => context.read<DuaListState>().togglePlay(dua, context),
          );
        },
      ),
    );
  }
}

class _DuaItemTile extends StatelessWidget {
  final DuaItemModel dua;
  final bool isPlaying;
  final VoidCallback onPlayTap;

  const _DuaItemTile({
    required this.dua,
    required this.isPlaying,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = dua.audioPath != null && dua.audioPath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppText(
                text: dua.title,
                style: textStyle16SemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (hasAudio)
              GestureDetector(
                onTap: onPlayTap,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: isPlaying
                      ? Icon(
                          Icons.stop_circle_outlined,
                          size: 26.w,
                          color: AppColors.secondary,
                        )
                      : SvgIcon(
                          AppAssets.play,
                          size: 24.w,
                          color: AppColors.primaryColor,
                        ),
                ),
              ),
          ],
        ),
        if (dua.description.trim().isNotEmpty) ...[
          8.h.verticalSpace,
          _descriptionBlock(context, dua.description),
        ],
      ],
    );
  }

  /// If CMS uses a blank line between Arabic and translation, show both blocks.
  Widget _descriptionBlock(BuildContext context, String raw) {
    final parts = raw
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            text: parts.first,
            textAlign: TextAlign.right,
            style: textStyle14Regular.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          6.h.verticalSpace,
          AppText(
            text: parts.sublist(1).join('\n\n'),
            textAlign: TextAlign.start,
            style: textStyle14Regular.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      );
    }

    return AppText(
      text: raw,
      textAlign: TextAlign.start,
      style: textStyle14Regular.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
