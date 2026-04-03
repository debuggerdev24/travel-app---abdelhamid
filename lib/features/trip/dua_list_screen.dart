import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/dua/dua_item_model.dart';
import 'package:trael_app_abdelhamid/services/dua_service.dart';

class DuaListScreen extends StatefulWidget {
  const DuaListScreen({super.key});

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  bool _loading = true;
  String? _error;
  List<DuaItemModel> _items = const [];

  final AudioPlayer _player = AudioPlayer();
  String? _playingId;
  StreamSubscription<void>? _completeSub;

  @override
  void initState() {
    super.initState();
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingId = null);
    });
    _load();
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _player.stop();
      if (mounted) setState(() => _playingId = null);

      final list = await DuaService.instance.fetchDuas(showErrorToast: false);
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

  Future<void> _togglePlay(DuaItemModel dua) async {
    final url = serverMediaUrl(dua.audioPath);
    if (url == null || url.isEmpty) return;

    try {
      if (_playingId == dua.id) {
        await _player.stop();
        if (mounted) setState(() => _playingId = null);
        return;
      }
      await _player.stop();
      if (mounted) setState(() => _playingId = dua.id);
      await _player.play(UrlSource(url));
    } catch (_) {
      if (mounted) {
        setState(() => _playingId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not play audio')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: 'Dua List',
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
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: "Couldn't load dua list",
            textAlign: TextAlign.center,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.85),
            ),
          ),
          10.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: AppText(
              text: _error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
          ),
          16.h.verticalSpace,
          TextButton(
            onPressed: _load,
            child: AppText(
              text: 'Retry',
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
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
                    text: 'No duas available yet',
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
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          final dua = _items[index];
          return _DuaItemTile(
            dua: dua,
            isPlaying: _playingId == dua.id,
            onPlayTap: () => _togglePlay(dua),
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
    final hasAudio =
        dua.audioPath != null && dua.audioPath!.trim().isNotEmpty;

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
          _descriptionBlock(dua.description),
        ],
      ],
    );
  }

  /// If CMS uses a blank line between Arabic and translation, show both blocks.
  Widget _descriptionBlock(String raw) {
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
              color: AppColors.primaryColor.setOpacity(0.5),
            ),
          ),
          6.h.verticalSpace,
          AppText(
            text: parts.sublist(1).join('\n\n'),
            textAlign: TextAlign.start,
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.5),
            ),
          ),
        ],
      );
    }

    return AppText(
      text: raw,
      textAlign: TextAlign.start,
      style: textStyle14Regular.copyWith(
        color: AppColors.primaryColor.setOpacity(0.5),
      ),
    );
  }
}
