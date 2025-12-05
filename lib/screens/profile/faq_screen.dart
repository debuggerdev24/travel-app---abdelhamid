import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<Map<String, dynamic>> faqList = [
    {
      "question": "How can I book a trip?",
      "answer":
          "From the Home screen, choose your desired package, tap “Book Now”, complete payment, and the trip will automatically appear in “My Trips.”",
      "isExpanded": true
    },
    {
      "question": "What payment methods are accepted?",
      "answer": "We accept credit cards, debit cards, UPI, and net banking.",
      "isExpanded": false
    },
    {
      "question": "How do I upload my documents?",
      "answer": "You can upload documents from the “My Trips” section.",
      "isExpanded": false
    },
    {
      "question": "Can I access my trip details offline?",
      "answer": "Yes, once downloaded, your trip details can be accessed offline.",
      "isExpanded": false
    },
    {
      "question": "How do I see my hotel and flight details?",
      "answer": "Go to your trip overview page to view all details.",
      "isExpanded": false
    },
    {
      "question": "Can I chat with my guide or group?",
      "answer": "Yes, in-app chat is available for your guide and group.",
      "isExpanded": false
    },
    {
      "question": "How do I share my live location?",
      "answer": "Tap “Share Location” on the home screen.",
      "isExpanded": false
    },
    {
      "question": "What if I forget my personal login code?",
      "answer": "Click “Forgot Code” on the login page to reset.",
      "isExpanded": false
    },
    {
      "question": "How do I contact support during my trip?",
      "answer": "Support is available inside the app 24/7.",
      "isExpanded": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
                          child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                      ),
                    ),
                    AppText(
                      text: "FAQ",
                      style:  textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "Travel-related FAQs:",
                          style: textStyle16SemiBold.copyWith(
                            fontSize: 18.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        AppText(
                          text: "https://temheed.nl/faqs/",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.blueColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              20.h.verticalSpace,

              // ---------------- FAQ List ----------------
              ListView.builder(
                itemCount: faqList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isExpanded = faqList[index]["isExpanded"];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            faqList[index]["isExpanded"] = !isExpanded;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: AppText(
                                  text: faqList[index]["question"],
                                  style:  textStyle16SemiBold.copyWith(
                              fontSize:   16.sp,
                              color: AppColors.primaryColor.withOpacity(0.8)
                            ),
                                ),
                              ),
                            Container(
  width: 32.w,
  height: 32.w,
  decoration: BoxDecoration(
    color: AppColors.whiteColor,
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.blueColor,
      width: 1,
    ),
  ),
  child: Center(
    child: Icon(
isExpanded ? Icons.remove : Icons.add,      size: 18.w,
      color: AppColors.blueColor
    ),
  ),
)

                              
                            ],
                          ),
                        ),
                      ),

                      // ANSWER SECTION
                      if (isExpanded)
                        AppText(
                          text: faqList[index]["answer"],
                          style: textStyle14Regular.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.textcolor.withOpacity(0.6)
                          ),
                        ),

                      Divider(
                        color: Colors.black12,
                        thickness: 1,
                      ),
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
