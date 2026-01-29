import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class UmrahGuideScreen extends StatelessWidget {
  const UmrahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 43.h),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  23.w.horizontalSpace,
                  AppText(
                    textAlign: TextAlign.center,
                    text: "Umrah Guide\n(Step-by-Step)",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),

              16.h.verticalSpace,

              Expanded(
                child: ListView(
                  children: [
                    _step("1. Ihram (Intention & Purity)", [
                      "Begin at Meeqat with intention:\n“Labbaik Allahumma Umrah”",
                      "Perform ghusl (bath), trim nails, and wear Ihram (men: two white sheets; women: modest dress without face covering).",
                      "Enter state of Ihram — avoid perfume, cutting hair/nails, or intimate acts.",
                    ]),
                    _step("2. Talbiyah", [
                      "Recite continuously:\n“Labbayk Allahumma labbayk, labbayka la shareeka laka labbayk...”\n (Here I am, O Allah, responding to Your call…)”",
                    ]),
                    _step("3. Arrival at Masjid Al-Haram", [
                      "Enter with right foot saying:\n“Allahumma aftah li abwaba rahmatik” (O Allah, open for me the gates of Your mercy)Stop Talbiyah when you see the Ka’bah.",
                    ]),
                    _step("4. Tawaf (7 Circuits Around Kaaba)", [
                      "Keep Ka’bah to your left",
                      "Start from Black Stone, say “Bismillah, Allahu Akbar”",
                      "Men: fast pace for first 3 rounds (Ramal)",
                      "Between Yemeni corner & Black Stone, recite: “Rabbana atina fid-dunya hasanah...”",
                      "Complete 7 rounds → Pray 2 rak’ahs behind Maqaam Ibrahim.",
                    ]),
                    _step("5. Zamzam Water", [
                      "Drink Zamzam with the intention of healing & blessings.\n“Zamzam is for what it is drunk for.”",
                    ]),
                    _step("6. Sa’i (Between Safa & Marwah)", [
                      "Start at Safa, recite: “Innas-Safa wal-Marwah min",
                      "Face Ka’bah, make dua three times.",
                      "Walk to Marwah (men jog between green lights).",
                      "Complete 7 rounds, ending at Marwah.",
                    ]),
                    _step("7. Hair Trimming", [
                      "Men: shave or trim hair.",
                      "Women: cut a fingertip-length of hair.",
                    ]),
                    _step("8. Completion", [
                      "Exit Ihram.",
                      "All restrictions are lifted.",

                      "Mabrook! Your Umrah is complete. May Allah accept it.",
                    ]),
                  ],
                ),
              ),

              42.h.verticalSpace,

              _bottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomButtons(BuildContext con) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 12),
                ),
              ],
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: AppColors.blueColor),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(AppAssets.save, size: 20.w),
                10.w.horizontalSpace,
                AppText(
                  text: " Download",
                  style: textStyle14Medium.copyWith(color: AppColors.blueColor),
                ),
              ],
            ),
          ),
        ),
        14.w.horizontalSpace,
        Expanded(
          child: GestureDetector(
            onTap: () {
              log("sdfadwfawfadwfadwf===========>");
              con.pushNamed(UserAppRoutes.duaListScreen.name);
            },
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(25.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon(AppAssets.eye, size: 20.w),
                  10.w.horizontalSpace,
                  AppText(
                    text: " View Dua List",
                    style: textStyle14Medium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- STEP SECTION ----------------
Widget _step(String title, List<String> bullets) {
  return Padding(
    padding: EdgeInsets.only(bottom: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: title, style: textStyle16SemiBold),
        9.h.verticalSpace,

        ...bullets.map(
          (e) => Padding(
            padding: EdgeInsets.only(left: 12.w, bottom: 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: "•  ",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.withOpacity(0.5),
                  ),
                ),
                Expanded(child: _colorWords(e)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _colorWords(String text) {
  final wordsToColor = [
    "Meeqat",
    "Labbaik Allahumma Umrah",
    "Allahumma aftah li abwaba rahmatik",
    "left",
    "Black Stone",
    "Rabbana atina fid-dunya hasanah",
    "7 rounds",
    "Maqaam Ibrahim",
    "Safa",
    "Marwah",
    "Maqaam Ibrahim",
  ];

  // Create spans list
  List<TextSpan> spans = [];

  for (String word in wordsToColor) {
    if (text.toLowerCase().contains(word.toLowerCase())) {
      final regex = RegExp(word, caseSensitive: false);
      final match = regex.firstMatch(text)!;
      final before = text.substring(0, match.start);
      final highlight = text.substring(match.start, match.end);
      final after = text.substring(match.end);

      spans.add(
        TextSpan(
          text: before,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
        ),
      );

      spans.add(
        TextSpan(
          text: highlight,
          style: textStyle14Regular.copyWith(color: AppColors.primaryColor),
        ),
      );

      spans.add(
        TextSpan(
          text: after,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
        ),
      );

      return RichText(text: TextSpan(children: spans));
    }
  }

  return AppText(
    text: text,
    style: textStyle14Regular.copyWith(
      color: AppColors.primaryColor.withOpacity(0.5),
    ),
  );
}
