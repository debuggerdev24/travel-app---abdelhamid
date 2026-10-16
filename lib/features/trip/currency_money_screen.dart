import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/essential/exchange_rate_model.dart';
import 'package:travel_app_abdelhamid/provider/trip/currency_converter_provider.dart';

class CurrencyMoneyScreen extends StatefulWidget {
  const CurrencyMoneyScreen({super.key});

  @override
  State<CurrencyMoneyScreen> createState() => _CurrencyMoneyScreenState();
}

class _CurrencyMoneyScreenState extends State<CurrencyMoneyScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    // Keep the amount that is already in the provider when returning to this screen.
    final provider = Provider.of<CurrencyConverterProvider>(
      context,
      listen: false,
    );
    _amountController = TextEditingController(
      text: _amountText(provider.amount),
    );
    provider.fetchExchangeRates();
  }

  String _amountText(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                child: _body(),
              ),
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
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: "Currency Converter".tr(),
                style: textStyle16SemiBold.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              16.h.verticalSpace,
              _amountInput(provider),
              24.h.verticalSpace,
              _currencySelector(provider),
              24.h.verticalSpace,
              _conversionResult(provider),
              if (provider.error != null) ...[
                12.h.verticalSpace,
                AppText(
                  text: provider.error!,
                  style: textStyle12Regular.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
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

  Widget _fieldLabel(String text) {
    return AppText(
      text: text,
      style: textStyle14Medium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    );
  }

  Widget _amountInput(CurrencyConverterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel("Amount".tr()),
        8.h.verticalSpace,
        Container(
          decoration: _fieldDecoration(),
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textStyle16SemiBold.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: textStyle16SemiBold.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 12.w, right: 4.w),
                child: Text(
                  provider.fromCurrency.flag,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 40.w),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            onChanged: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty || trimmed == '.' || trimmed == '-') {
                provider.setAmount(0);
                return;
              }
              final amount = double.tryParse(trimmed);
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
      crossAxisAlignment: CrossAxisAlignment.end,
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
        8.w.horizontalSpace,
        GestureDetector(
          onTap: provider.swapCurrencies,
          child: Container(
            height: 48.h,
            width: 48.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.swap_horiz,
              color: AppColors.whiteColor,
              size: 22.w,
            ),
          ),
        ),
        8.w.horizontalSpace,
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        8.h.verticalSpace,
        Container(
          decoration: _fieldDecoration(),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency.code,
              isExpanded: true,
              style: textStyle14Medium.copyWith(color: onSurface),
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: onSurface,
                size: 22.w,
              ),
              selectedItemBuilder: (context) {
                return currencies.map((currency) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      children: [
                        Text(
                          currency.flag,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        8.w.horizontalSpace,
                        Expanded(
                          child: AppText(
                            text: currency.code,
                            style: textStyle14Medium.copyWith(color: onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              items: currencies.map((currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Row(
                    children: [
                      Text(currency.flag, style: TextStyle(fontSize: 18.sp)),
                      8.w.horizontalSpace,
                      Expanded(
                        child: AppText(
                          text: '${currency.code} - ${currency.name}',
                          style: textStyle14Medium.copyWith(color: onSurface),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (convertedAmount == null) {
      return AppText(
        text: "Exchange rate not available".tr(),
        textAlign: TextAlign.center,
        style: textStyle14Regular.copyWith(
          color: onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AppText(
                text:
                    "${provider.amount.toStringAsFixed(2)} ${provider.fromCurrency.code}",
                style: textStyle14Medium.copyWith(color: onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            8.w.horizontalSpace,
            Icon(Icons.arrow_forward, size: 16.w, color: AppColors.secondary),
            8.w.horizontalSpace,
            AppText(
              text: provider.toCurrency.code,
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ],
        ),
        12.h.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.blueColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: AppText(
            text:
                "${convertedAmount.toStringAsFixed(2)} ${provider.toCurrency.code}",
            style: textStyle18Bold.copyWith(color: AppColors.whiteColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _refreshButton(CurrencyConverterProvider provider) {
    return AppButton(
      title: "Refresh Rates".tr(),
      isLoading: provider.isLoading,
      onTap: provider.isLoading
          ? null
          : () => provider.fetchExchangeRates(forceRefresh: true),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgIcon(
                AppAssets.backIcon,
                size: 28.5.w,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: AppText(
              text: "Currency & Money".tr(),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyle32Bold.copyWith(
                fontSize: 26.sp,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
