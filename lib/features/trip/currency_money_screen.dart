import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/essential/currency_info_model.dart';
import 'package:travel_app_abdelhamid/model/essential/exchange_rate_model.dart';
import 'package:travel_app_abdelhamid/provider/trip/currency_converter_provider.dart';
import 'package:travel_app_abdelhamid/services/essential_service.dart';

class CurrencyMoneyScreen extends StatefulWidget {
  const CurrencyMoneyScreen({super.key});

  @override
  State<CurrencyMoneyScreen> createState() => _CurrencyMoneyScreenState();
}

class _CurrencyMoneyScreenState extends State<CurrencyMoneyScreen> {
  bool _loading = true;
  String? _error;
  CurrencyInfoData? _data;
  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _load();
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await EssentialService.instance.getCurrencyInfo(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: _body(),
              ),
            ),
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: "Couldn't load currency information",
            textAlign: TextAlign.center,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.85),
            ),
          ),
          10.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
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
              text: "Retry",
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      );
    }
    final data = _data;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _converterSection(),
            if (data != null) ...[
              32.h.verticalSpace,
              _contentSection(data),
              24.h.verticalSpace,
              _tipsSection(data),
              24.h.verticalSpace,
              _bannerSection(data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _converterSection() {
    return Consumer<CurrencyConverterProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xff2A2522)
                : AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Currency Converter",
                style: textStyle18Bold.copyWith(
                  color: AppColors.secondary,
                  fontSize: 20.sp,
                ),
              ),
              16.h.verticalSpace,
              _amountInput(provider),
              16.h.verticalSpace,
              _currencySelector(provider),
              16.h.verticalSpace,
              _conversionResult(provider),
              if (provider.error != null) ...[
                12.h.verticalSpace,
                AppText(
                  text: provider.error!,
                  style: textStyle12Regular.copyWith(color: Colors.orange),
                ),
              ],
              16.h.verticalSpace,
              _refreshButton(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _amountInput(CurrencyConverterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Amount",
          style: textStyle14Medium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : AppColors.primaryColor.setOpacity(0.8),
          ),
        ),
        8.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xff2A2522)
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: textStyle14Medium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.primaryColor,
            ),
            decoration: InputDecoration(
              hintText: 'Enter amount',
              hintStyle: textStyle14Regular.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.4)
                    : AppColors.primaryColor.setOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value);
              if (amount != null) {
                provider.setAmount(amount);
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
            label: "From",
            selectedCurrency: provider.fromCurrency,
            currencies: CurrencyData.commonCurrencies,
            onChanged: (currency) {
              provider.setFromCurrency(currency);
            },
          ),
        ),
        16.w.horizontalSpace,
        GestureDetector(
          onTap: provider.swapCurrencies,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.swap_horiz, color: Colors.white, size: 24.w),
          ),
        ),
        16.w.horizontalSpace,
        Expanded(
          child: _currencyDropdown(
            label: "To",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          style: textStyle14Medium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : AppColors.primaryColor.setOpacity(0.8),
          ),
        ),
        8.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xff2A2522)
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency.code,
              isExpanded: true,
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primaryColor,
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff2A2522)
                  : Colors.white,
              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Row(
                    children: [
                      Text(currency.flag, style: TextStyle(fontSize: 20.sp)),
                      8.w.horizontalSpace,
                      Expanded(
                        child: AppText(
                          text: '${currency.code} - ${currency.name}',
                          style: textStyle14Medium.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.transparent
            : AppColors.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          if (convertedAmount != null) ...[
            AppText(
              text:
                  "${provider.amount.toStringAsFixed(2)} ${provider.fromCurrency.code}",
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.primaryColor.setOpacity(0.8),
              ),
            ),
            8.h.verticalSpace,
            Icon(Icons.arrow_downward, color: AppColors.secondary, size: 20.w),
            8.h.verticalSpace,
            AppText(
              text:
                  "${convertedAmount.toStringAsFixed(2)} ${provider.toCurrency.code}",
              style: textStyle18Bold.copyWith(
                color: AppColors.secondary,
                fontSize: 28.sp,
              ),
            ),
          ] else ...[
            AppText(
              text: "Exchange rate not available",
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xffffffff)
                    : AppColors.primaryColor,
                fontSize: 16.sp,
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: provider.isLoading
              ? AppColors.primaryColor.setOpacity(0.5)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.isLoading)
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(Icons.refresh, color: Colors.white, size: 18.w),
            8.w.horizontalSpace,
            AppText(
              text: provider.isLoading ? "Updating..." : "Refresh Rates",
              style: textStyle14Medium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 27.h),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
            ),
          ),
          9.w.horizontalSpace,
          AppText(
            text: "Currency & Money",
            style: textStyle32Bold.copyWith(
              fontSize: 26.sp,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(CurrencyInfoData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _priceRow("Recommended", data.recommendedLabel),
        _priceRow("Exchange Rate", data.exchangeRate),
        28.h.verticalSpace,
        AppText(
          text: "Payment Options",
          style: textStyle14Medium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : AppColors.primaryColor.setOpacity(0.8),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (data.paymentOptions.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 14.h, left: 10.w),
            child: AppText(
              text: "—",
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.paymentOptions.map((o) => _bullet(o, 0)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _tipsSection(CurrencyInfoData data) {
    final tips = data.tips?.trim();
    if (tips == null || tips.isEmpty) return const SizedBox.shrink();

    final lines = tips
        .split(RegExp(r'\r?\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Tips",
          style: textStyle14Medium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.8)
                : AppColors.primaryColor.setOpacity(0.8),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h.verticalSpace,
        ...lines.map((line) => _bullet(line, 0)),
      ],
    );
  }

  Widget _bannerSection(CurrencyInfoData data) {
    final url = serverMediaUrl(data.bannerImagePath);
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(AppAssets.currency),
        ),
      );
    }
    return Image.asset(AppAssets.currency);
  }

  Widget _bullet(String text, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "•  ",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.6)
                  : AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            style: textStyle14Medium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.primaryColor.setOpacity(0.8),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: ":",
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.8)
                  : AppColors.primaryColor.setOpacity(0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          24.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.7)
                    : AppColors.primaryColor.setOpacity(0.7),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
