import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/essential/exchange_rate_model.dart';
import 'package:travel_app_abdelhamid/provider/trip/currency_converter_provider.dart';

class CurrencyMoneyScreen extends StatefulWidget {
  const CurrencyMoneyScreen({super.key});

  @override
  State<CurrencyMoneyScreen> createState() => _CurrencyMoneyScreenState();
}

class _CurrencyMoneyScreenState extends State<CurrencyMoneyScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    // Backend API doesn't return currency data, so skip loading from backend
    // Currency converter works entirely with frontend implementation
    final provider = Provider.of<CurrencyConverterProvider>(
      context,
      listen: false,
    );
    provider.fetchExchangeRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xff1a1a1a)
          : const Color(0xffF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient decoration
            Positioned(
              top: -100.h,
              right: -100.w,
              child: Container(
                width: 300.w,
                height: 300.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.15),
                      AppColors.skyblueColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50.h,
              left: -100.w,
              child: Container(
                width: 250.w,
                height: 250.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueColor.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _body(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    // Backend API doesn't return currency data, so only show converter
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_converterSection()],
      ),
    );
  }

  Widget _converterSection() {
    return Consumer<CurrencyConverterProvider>(
      builder: (context, provider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xff2A2522).withValues(alpha: 0.95),
                      const Color(0xff1a1a1a).withValues(alpha: 0.9),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.85),
                    ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary,
                          AppColors.lightYellowColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.currency_exchange_rounded,
                      color: Colors.white,
                      size: 24.w,
                    ),
                  ),
                  16.w.horizontalSpace,
                  AppText(
                    text: "Currency Converter".tr(),
                    style: textStyle18Bold.copyWith(
                      color: isDark ? Colors.white : AppColors.primaryColor,
                      fontSize: 22.sp,
                    ),
                  ),
                ],
              ),
              28.h.verticalSpace,
              _amountInput(provider),
              24.h.verticalSpace,
              _currencySelector(provider),
              24.h.verticalSpace,
              _conversionResult(provider),
              if (provider.error != null) ...[
                12.h.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange,
                        size: 18.w,
                      ),
                      8.w.horizontalSpace,
                      Expanded(
                        child: AppText(
                          text: provider.error!,
                          style: textStyle12Regular.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              24.h.verticalSpace,
              _refreshButton(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _amountInput(CurrencyConverterProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Amount".tr(),
          style: textStyle14Medium.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.primaryColor.withValues(alpha: 0.7),
            fontSize: 13.sp,
          ),
        ),
        10.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xff3a3532).withValues(alpha: 0.8),
                      const Color(0xff2a2522).withValues(alpha: 0.6),
                    ]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: textStyle18Bold.copyWith(
              color: isDark ? Colors.white : AppColors.primaryColor,
              fontSize: 20.sp,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: textStyle18Bold.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : AppColors.primaryColor.withValues(alpha: 0.3),
                fontSize: 20.sp,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(left: 16.w, right: 8.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.2),
                      AppColors.lightYellowColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: AppColors.secondary,
                  size: 20.w,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 16.h,
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null) {
                provider.setAmount(amount);
              } else if (value.isEmpty) {
                provider.setAmount(0);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _currencySelector(CurrencyConverterProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _currencyDropdown(
            label: "From".tr(),
            selectedCurrency: provider.fromCurrency,
            currencies: CurrencyData.commonCurrencies,
            onChanged: (currency) {
              provider.setFromCurrency(currency);
            },
          ),
        ),
        12.w.horizontalSpace,
        GestureDetector(
          onTap: provider.swapCurrencies,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.lightYellowColor],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 26.w,
            ),
          ),
        ),
        12.w.horizontalSpace,
        Expanded(
          child: _currencyDropdown(
            label: "To".tr(),
            selectedCurrency: provider.toCurrency,
            currencies: CurrencyData.commonCurrencies,
            onChanged: (currency) {
              provider.setToCurrency(currency);
            },
          ),
        ),
      ],
    );
  }

  Widget _currencyDropdown({
    required String label,
    required CurrencyData selectedCurrency,
    required List<CurrencyData> currencies,
    required Function(CurrencyData) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          style: textStyle14Medium.copyWith(
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.primaryColor.withValues(alpha: 0.7),
            fontSize: 13.sp,
          ),
        ),
        10.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xff3a3532).withValues(alpha: 0.8),
                      const Color(0xff2a2522).withValues(alpha: 0.6),
                    ]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency.code,
              isExpanded: true,
              style: textStyle16SemiBold.copyWith(
                color: isDark ? Colors.white : AppColors.primaryColor,
                fontSize: 15.sp,
              ),
              dropdownColor: isDark ? const Color(0xff2A2522) : Colors.white,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.secondary,
                size: 24.w,
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          currency.flag,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                      12.w.horizontalSpace,
                      Expanded(
                        child: AppText(
                          text: '${currency.code} - ${currency.name}',
                          style: textStyle16SemiBold.copyWith(
                            color: isDark
                                ? Colors.white
                                : AppColors.primaryColor,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final currency = currencies.firstWhere(
                    (c) => c.code == value,
                  );
                  onChanged(currency);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _conversionResult(CurrencyConverterProvider provider) {
    final convertedAmount = provider.convertedAmount;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondary.withValues(alpha: 0.15),
            AppColors.lightYellowColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (convertedAmount != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      text:
                          "${provider.amount.toStringAsFixed(2)} ${provider.fromCurrency.code}",
                      style: textStyle14Medium.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.primaryColor.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                12.w.horizontalSpace,
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.lightYellowColor],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    color: Colors.white,
                    size: 18.w,
                  ),
                ),
                12.w.horizontalSpace,
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: AppText(
                      text: provider.toCurrency.code,
                      style: textStyle14Medium.copyWith(
                        color: AppColors.secondary,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            20.h.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.lightYellowColor],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.white,
                    size: 24.w,
                  ),
                  8.w.horizontalSpace,
                  Flexible(
                    child: AppText(
                      text:
                          "${convertedAmount.toStringAsFixed(2)} ${provider.toCurrency.code}",
                      style: textStyle32Bold.copyWith(
                        color: Colors.white,
                        fontSize: 28.sp,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.primaryColor.withValues(alpha: 0.5),
                    size: 20.w,
                  ),
                  8.w.horizontalSpace,
                  AppText(
                    text: "Exchange rate not available".tr(),
                    style: textStyle14Medium.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.primaryColor.withValues(alpha: 0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _refreshButton(CurrencyConverterProvider provider) {
    return GestureDetector(
      onTap: () {
        provider.fetchExchangeRates(forceRefresh: true);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: provider.isLoading
              ? LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.6),
                    AppColors.primaryColor.withValues(alpha: 0.4),
                  ],
                )
              : LinearGradient(
                  colors: [AppColors.secondary, AppColors.lightYellowColor],
                ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color:
                  (provider.isLoading
                          ? AppColors.primaryColor
                          : AppColors.secondary)
                      .withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (provider.isLoading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(Icons.refresh_rounded, color: Colors.white, size: 20.w),
            12.w.horizontalSpace,
            AppText(
              text: provider.isLoading ? "Updating..." : "Refresh Rates",
              style: textStyle16SemiBold.copyWith(
                color: Colors.white,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [Colors.white, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : AppColors.primaryColor,
                  size: 20.w,
                ),
              ),
            ),
          ),
          16.w.horizontalSpace,
          AppText(
            text: "Currency & Money".tr(),
            style: textStyle32Bold.copyWith(
              fontSize: 28.sp,
              color: isDark ? Colors.white : AppColors.primaryColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
