import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/past_payment_item.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';


class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyTripProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,

      body: Column(
        children: [
          60.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 27.w,vertical: 12.h
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgIcon(AppAssets.backIcon, size: 26.w),
                  ),
                ),
                AppText(
                  text: "Payment History",
                  style: textStyle32Bold.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // PAYMENT LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 10.h),
              itemCount: provider.payments.length,
              itemBuilder: (context, index) {
                final item = provider.payments[index];

                return PastPaymentItem(
                  id: item.id,
                  amount: item.amount,
                  date: item.date,
                  onViewReceiptTap: () {
context.pushNamed(UserAppRoutes.viewPaymentReceiptScreen.name);                  },
                );
              },
            ),
          ),
        ],
      ),

     
    );
  }
}
