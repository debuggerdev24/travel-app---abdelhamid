import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class DuaListScreen extends StatelessWidget {
  const DuaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              horizontal: 27.w,
              vertical: 16.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                    Spacer(),
                    Align(
                      alignment:Alignment.center,
                      child: AppText(
                        text: "Dua List",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(
                        AppAssets.save,
                        size: 26.w,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                16.h.verticalSpace,
                Column(
                  spacing: 15.h,
                  children: [
                    DuaItem(
                      title: "Du’a when Leaving Home:",
                      arabicText:
                          "بَلاَوَسِمِالله َّكْل ُت َعلَى ِالله َلاَْل وَ تـ وْ َِّلا . َ وةَ إ َّ ـُق ح ƅِ ʪِ",
                      translation:
                          "Bismillah Tawakkaltu Alallah, laa hawla walaa Quwwata illa billah.",
                    ),

                    DuaItem(
                      title: "When riding a car/plane:",
                      arabicText:
                          "َين ِ مُْقِرن َّا لَهُ  ُكن مَ هَذا وَ ٰ خرَ لَنَ َّ ذِيسَ َّاَنال بْحَاُنَ ّس",
                      translation:
                          "Subhanalazee Sakh-khara lana haaza wa maa kunnaa lahu muqrineen. Wa innaa ilaa Rabbinaa lamunqaliboon",
                    ),

                    DuaItem(
                      title: "Intention for Umrah:",
                      arabicText:
                          "ني  مِ َّـ ْلهَ ََقب وَتـ  ِليْ هَ رْ ةَ فَـيَسِّ رَ ّنيِ أُِريْ ُد الْعُمْ ِمإهََُّللّٰا",
                      translation:
                          "Allahumma innee ureedu ‘umrata fayassirhaa lee wa taqabbalhaa mimmee.",
                    ),

                    DuaItem(
                      title: "Talbiyah :",
                      arabicText:
                          "لَبَّيْكَ اَللّٰهُمَّ لَبَّيْكَ. لَبَّيْكَ لَا شَرِيْكَ لَكَ لَبَّيْكَ. اِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ. لَا شَرِيْكَ لَكَ",
                      translation:
                          "Labbak Allahumma Labbak. Labbayka Laa shareeka laka Labbak. Innal Hamda wan-ni mata laka wal mulk. La-shareeka lak.",
                    ),

                    DuaItem(
                      title: "An important Du’a to be recited frequently:",
                      arabicText:
                          "اَللّٰهُمَّ اِنِّىْ اَسْاَلُكَ رِضَاكَ وَالْجَنَّةَ وَاَعُوْذُبِكَ مِنْ سَخَطِكَ وَالنَّارِ",
                      translation:
                          "Allahumma innee Asaluka Ridaaka wal Jannah, wa a’u’zubika min sakhatika wan-Naar.",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DuaItem extends StatelessWidget {
  final String title;
  final String arabicText;
  final String translation;

  const DuaItem({
    super.key,
    required this.title,
    required this.arabicText,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            ),
            SvgIcon(AppAssets.play, size: 24.w),
          ],
        ),
        4.h.verticalSpace,

        /// Arabic Text
        AppText(
          text: arabicText,
          textAlign: TextAlign.right,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
        ),
        4.h.verticalSpace,

        /// Translation
        AppText(
          text: translation,
          textAlign: TextAlign.start,
          style: textStyle14Regular.copyWith(
            color: AppColors.primaryColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
