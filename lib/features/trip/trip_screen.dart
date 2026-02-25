import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/enums/payment_option_enum.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_chip.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/details_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/document_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/itinerarystep_card.dart';
import 'package:trael_app_abdelhamid/core/widgets/past_payment_item.dart';
import 'package:trael_app_abdelhamid/core/widgets/payment_option_card.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String selectedMethod = "Credit/Debit Card";
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final trip = tripProvider.selectedTrip;

    return Consumer<MyTripProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  10.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 27.w,
                      vertical: 10.h,
                    ),
                    child: Center(
                      child: AppText(
                        text: "Makkah skyline",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  if (trip != null)
                    trip.image.startsWith('assets')
                        ? Image.asset(
                            trip.image,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            trip.imageUrl,
                            height: 250.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 250.h,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),

                  // Trip title and location
                  12.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27.w),
                    child: AppText(
                      text: trip?.title ?? "-",
                      style: textStyle16SemiBold,
                    ),
                  ),
                  14.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 27.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        SvgIcon(AppAssets.pin, size: 22.w),
                        14.w.horizontalSpace,
                        Expanded(
                          child: AppText(
                            text: trip?.location ?? "-",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        12.w.horizontalSpace,
                        SvgIcon(AppAssets.calendar, size: 22.w),
                        14.w.horizontalSpace,
                        AppText(
                          text: trip?.date ?? "-",
                          style: textStyle14Regular.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  10.h.verticalSpace,

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 19.w,
                        vertical: 10.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTab("Payment", AppAssets.payment, 0),
                          _buildTab("Flights", AppAssets.flight, 1),
                          _buildTab("Hotels", AppAssets.hotel, 2),
                          _buildTab("Itinerary", AppAssets.itinerary, 3),
                          _buildTab("Essentials", AppAssets.essential, 4),
                          _buildTab("Documents", AppAssets.document, 5),
                        ],
                      ),
                    ),
                  ),

                  // Show section based on selected tab
                  _getSelectedSection(provider),

                  // Proceed Button (optional, only for Payment maybe)
                  if (selectedIndex == 0)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 27.w,
                        vertical: 20.h,
                      ),
                      child: AppButton(title: "Proceed to Pay"),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, String icon, int index) {
    return AppChip(
      isSelected: selectedIndex == index,
      title: title,
      icon: icon,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }

  Widget _getSelectedSection(MyTripProvider provider) {
    switch (selectedIndex) {
      case 0:
        return _paymentSection(provider);
      case 1:
        return _flightsSection();
      case 2:
        return _hotelsSection();
      case 3:
        return _itinerarySection();
      case 4:
        return _essentialsSection();
      case 5:
        return _documentsSection();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _paymentSection(MyTripProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.setOpacity(0.2),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: "Premium Package",
                  style: textStyle14Regular.copyWith(
                    color: AppColors.primaryColor.setOpacity(0.8),
                    fontSize: 14.sp,
                  ),
                ),
                12.h.verticalSpace,
                _priceRow("Total", "€10,000"),
                4.h.verticalSpace,
                _priceRow("Paid", "€5,000"),
                4.h.verticalSpace,
                _priceRow("Pending", "€5,000"),
              ],
            ),
          ),
        ),

        if (!provider.hidePaymentMethods)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 27.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(text: "Payment Method", style: textStyle16SemiBold),
                16.h.verticalSpace,
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.googlePay,
                  selectedValue: provider.selectedMethod,
                ),
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.applepay,
                  selectedValue: provider.selectedMethod,
                ),
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.idealpay,
                  selectedValue: provider.selectedMethod,
                ),
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.cash,
                  selectedValue: provider.selectedMethod,
                ),
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.creditCard,
                  selectedValue: provider.selectedMethod,
                ),
                if (provider.selectedMethod == PaymentMethosEnum.creditCard)
                  _cardDetailsSection(),
                PaymentOption(
                  onSelect: (value) => provider.changeSelectedMethod(value),
                  value: PaymentMethosEnum.paypal,
                  selectedValue: provider.selectedMethod,
                ),
              ],
            ),
          ),

        // Past Payments
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 10.h),
          child: Row(
            children: [
              AppText(text: "Past Payment", style: textStyle16SemiBold),
              Spacer(),
              GestureDetector(
                onTap: () =>
                    context.pushNamed(UserAppRoutes.paymentHistoryScreen.name),
                child: AppText(
                  text: "View All",
                  style: textStyle16SemiBold.copyWith(
                    color: AppColors.blueColor,
                    fontSize: 14.sp,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        PastPaymentItem(
          id: "#TRX001",
          amount: "250,000",
          date: "02 Jan 2024",
          onViewReceiptTap: () {},
        ),
        PastPaymentItem(
          id: "#TRX002",
          amount: "250,000",
          date: "22 Dec 2024",
          onViewReceiptTap: () {},
        ),
        PastPaymentItem(
          id: "#TRX003",
          amount: "250,000",
          date: "31 May 2023",
          onViewReceiptTap: () {},
        ),
      ],
    );
  }

  Widget _flightsSection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 10.h),
        child: Column(
          children: [
            TripDetialsCard(
              title: "Outbound Flight",
              infoMap: {
                "Flight": "SV772 (Saudi Airlines)",
                "Route": "Mumbai (BOM - T2) → Jeddah (JED)",
                "Date": "10 Feb 2025",
                "Departure": "02:30 AM",
                "Arrival": "05:45 AM",
                "Duration": "5h 15m",
                "Seat": "24A (Window)",
                "Baggage": "2 Bags (23kg each)",
                "Airline Contact": "+966 9200 22222",
                "Desk No": "A18",
                "Email": "support@saudia.com",
                "Status": "Confirmed",
              },
            ),

            SizedBox(height: 20.h),
            TripDetialsCard(
              title: "Outbound Flight",
              infoMap: {
                "Flight": "SV772 (Saudi Airlines)",
                "Route": "Mumbai (BOM - T2) → Jeddah (JED)",
                "Date": "10 Feb 2025",
                "Departure": "02:30 AM",
                "Arrival": "05:45 AM",
                "Duration": "5h 15m",
                "Seat": "24A (Window)",
                "Baggage": "2 Bags (23kg each)",
                "Airline Contact": "+966 9200 22222",
                "Desk No": "A18",
                "Email": "support@saudia.com",
                "Status": "Confirmed",
              },
            ),
            // TripDetialsCard(
            //   flight: FlightModel(title: "Return Flight",
            //   flightNumber: "SV773 (Saudi Airlines)",
            //   route: "Jeddah (JED) → Mumbai (BOM - Terminal 2)",
            //   date: "20 Feb 2025",
            //   departure: "09:30 AM",
            //   arrival: "04:15 PM",
            //   duration: "5h 45m",
            //   seat: "24B (Aisle)",
            //   baggage: "2 Bags (23kg each)",
            //   airlineContact: "+966 9200 22222",
            //   deskNo: "A18",
            //   email: "support@saudia.com",
            //   status: "Awaiting Confirmation",),

            // ),
          ],
        ),
      ),
    );
  }

  Widget _hotelsSection() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 10.h),
        child: Column(
          children: [
            Column(
              children: [
                EscortContactCard(
                  name: "Ahmed Khan",
                  phone: "+966 55 123 4567",
                ),
                SizedBox(height: 16.h),
              ],
            ),
            TripDetialsCard(
              labelWidth: 90.w, // wider

              title: "Hotel 1",
              infoMap: {
                "Name": "Swissotel Makkah",
                "Address": "Ajyad St, Makkah",
                "Phone": "+966 12 571 8000",
                "Check-in": "10 Feb 2025, 2:00 PM",
                "Check-out": "15 Feb 2025, 11:00 AM",
                "Room Type": "Double Deluxe",
                "Room No": "302 (With roommate: Ali Khan)",
                "Facilities": "Free WiFi, Breakfast Included",
                "Status": "Confirmed",
              },
            ),

            SizedBox(height: 20.h),

            TripDetialsCard(
              labelWidth: 90.w, // wider

              title: "Hotel 2",
              infoMap: {
                "Name": "Anwar Al Madinah Mövenpick",
                "Address": "Central Area, Madinah",
                "Phone": "+966 14 818 1000",
                "Check-in": "15 Feb 2025, 3:00 PM",
                "Check-out": "20 Feb 2025, 12:00 PM",
                "Room Type": "Triple Standard",
                "Room No": "514 (With roommates: Ahmed, Sameer)",
                "Facilities": "WiFi, Dinner Buffet, Close to Haram",
                "Status": "Pending Confirmation",
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _itinerarySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Column(
                children: [
                  ItineraryStep(
                    icon: AppAssets.plane,
                    title: "Arrival at Jeddah Airport",
                    time: "05:45 AM",
                    isCompleted: true,
                  ),
                  ItineraryStep(
                    icon: AppAssets.truck,
                    title: "Transfer to Makkah Hotel",
                    time: "07:00 AM",
                    isCompleted: true,
                  ),
                  ItineraryStep(
                    icon: AppAssets.location,
                    title: "Umrah Ritual – Tawaf & Sa’i",
                    time: "08:30 – 11:30 AM",
                    isCompleted: false,
                  ),
                ],
              ),

              ItineraryStep(
                icon: AppAssets.truck,
                title: "Departure from Makkah",
                time: "11:00 AM",
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _essentialsSection() {
    final List<String> essentialsItems = [
      "Packing List",
      "Currency & Money",
      "Emergency Contacts",
      "Local Info/Haramain Train",
      "Health & Safety Tips",
      "Umrah Guide (Step-by-Step)",
      "Dua List",
    ];

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 23.h),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: essentialsItems.length,
      separatorBuilder: (_, __) => SizedBox(height: 23.h),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              context.pushNamed(UserAppRoutes.packageListScreen.name);
            }
            if (index == 1) {
              context.pushNamed(UserAppRoutes.currencyMoneyScreen.name);
            }
            if (index == 2) {
              context.pushNamed(UserAppRoutes.emergencyContactScreen.name);
            }
            if (index == 3) {
              context.pushNamed(UserAppRoutes.localInformationScreen.name);
            }
            if (index == 4) {
              context.pushNamed(UserAppRoutes.healthSafteyScreen.name);
            }
            if (index == 5) {
              context.pushNamed(UserAppRoutes.umrahGuideScreen.name);
            }
            if (index == 6) {
              context.pushNamed(UserAppRoutes.duaListScreen.name);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: essentialsItems[index],
                style: textStyle14Regular.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.primaryColor,
                ),
              ),
              SvgIcon(
                AppAssets.arrow,
                size: 16.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _documentsSection() {
    return Consumer<MyTripProvider>(
      builder: (context, provider, child) {
        final docs = provider.uploadedDocs;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!docs.isNotEmpty) _emptyDocumentCard(),
                if (docs.isNotEmpty)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.pushNamed(
                        UserAppRoutes.addDocumentScreen.name,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.setOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgIcon(
                              AppAssets.addmore,
                              size: 18.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            AppText(
                              text: "Add More",
                              style: textPopinnsMeidium.copyWith(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (docs.isNotEmpty) SizedBox(height: 20.h),

                // === Passport & Visa ===
                if (docs.any(
                  (d) => d["type"] == "Passport" || d["type"] == "Visa",
                )) ...[
                  AppText(text: "Passport & Visa", style: textStyle16SemiBold),
                  12.h.verticalSpace,
                  ...docs
                      .where(
                        (d) => d["type"] == "Passport" || d["type"] == "Visa",
                      )
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              image: AppAssets.hotel4,
                              title: doc["name"],
                              fileImage: doc["file"],
                              info: {
                                "File Type": "PDF",
                                "Uploaded": doc["date"] ?? "02 Jun 2025",
                              },
                              button1: "View",
                              button2: "Download",

                              icon: AppAssets.save,
                            ),
                            ontap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumetScreen.name,
                                extra: {
                                  'file': doc["file"],
                                  'assetImage': AppAssets.hotel4,
                                  'title': "${doc["name"]} copy",
                                },
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                  20.h.verticalSpace,
                ],

                // === Round Trip Tickets ===
                if (docs.any((d) => d["type"] == "Flight Ticket")) ...[
                  AppText(
                    text: "Round Trip Tickets",
                    style: textStyle16SemiBold,
                  ),
                  SizedBox(height: 12.h),
                  ...docs
                      .where((d) => d["type"] == "Flight Ticket")
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              subtitle: "Return Ticket",
                              image: AppAssets.hotel,
                              title: doc["name"],
                              fileImage: doc["file"],
                              info: {
                                "Airline": " Saudia SV773",
                                "File Type": "PDF",
                                "Date": "20 Feb 2025",
                              },
                              button1: "View",
                              button2: "Download",
                              icon: AppAssets.save,
                            ),
                            ontap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumetScreen.name,
                                extra: {
                                  'file': doc["file"], // File
                                  'assetImage': AppAssets.hotel4, // String only
                                  'title': "E-ticket",
                                },
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                  20.h.verticalSpace,
                ],

                // === Medical Certificate ===
                if (docs.any((d) => d["type"] == "Medical Certificate")) ...[
                  AppText(
                    text: "Medical Certificate",
                    style: textStyle16SemiBold,
                  ),
                  SizedBox(height: 12.h),
                  ...docs
                      .where((d) => d["type"] == "Medical Certificate")
                      .map(
                        (doc) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: DocumentCard(
                            doc: DocumentModel(
                              image: AppAssets.hotel2,
                              title: "Medical Certificate",
                              fileImage: doc["file"],
                              info: {"File Type": "JPG"},
                              button1: "View",
                              button2: "Download",
                              icon: AppAssets.call,
                            ),
                            ontap: () {
                              context.pushNamed(
                                UserAppRoutes.viewDocumetScreen.name,
                                extra: {
                                  'file': doc["file"], // File
                                  'assetImage': AppAssets.hotel4, // String only
                                  'title': doc["name"],
                                },
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                  20.h.verticalSpace,
                ],

                // === Hotel Vouchers ===
                AppText(text: "Hotel Vouchers", style: textStyle16SemiBold),
                SizedBox(height: 12.h),
                DocumentCard(
                  doc: DocumentModel(
                    image: AppAssets.hotel1,
                    title: "Swissotel Makkah",
                    info: {
                      "Check-in": "10 Feb",
                      "Check-out": "15 Feb",
                      "File Type": "Image (JPG)",
                    },
                    button1: "View",
                    button2: "Open in Map",
                    icon: AppAssets.map,
                  ),
                  ontap: () {
                    context.pushNamed(
                      UserAppRoutes.hotelVoucherScreen.name,
                      extra: {
                        "imageFile": AppAssets.hotelvoucher,
                        "hotelName": "Swissotel Makkah",
                        "address": "Ajyad St, Makkah",
                      },
                    );
                  },
                ),
                12.h.verticalSpace,
                DocumentCard(
                  doc: DocumentModel(
                    image: AppAssets.hotel2,
                    title: "Pullman Zamzam Madinah",
                    info: {
                      "Check-in": "15 Feb",
                      "Check-out": "20 Feb",
                      "File Type": "Image (JPG)",
                    },
                    button1: "View",
                    button2: "Open in Map",
                    icon: AppAssets.map,
                  ),
                  ontap: () {
                    context.pushNamed(
                      UserAppRoutes.hotelVoucherScreen.name,
                      extra: {
                        "imageFile": AppAssets.hotelvoucher1,
                        "hotelName": "Pullman Zamzam Madinah",
                        "address": "Central Area North, Madinah",
                      },
                    );
                  },
                ),

                SizedBox(height: 20.h),

                // === Travel Insurance & Checklist ===
                AppText(text: "Travel Document", style: textStyle16SemiBold),
                SizedBox(height: 12.h),
                DocumentCard(
                  doc: DocumentModel(
                    image: AppAssets.hotel3,
                    title: "ICICI Lombard",
                    subtitle: "Travel Insurance",
                    info: {"Coverage": "10 Feb – 20 Feb"},
                    button1: "View",
                    button2: "Helpline",
                    icon: AppAssets.call,
                  ),
                  ontap: () {
                    context.pushNamed(
                      UserAppRoutes.travelInsuranceScreen.name,
                      extra: {
                        "imageFile": AppAssets.travelinsurance,
                        "hotelName": "Pullman Zamzam Madinah",
                        "address": "Central Area North, Madinah",
                      },
                    );
                  },
                ),
                12.h.verticalSpace,
                DocumentCard(
                  doc: DocumentModel(
                    image: AppAssets.hotel3,
                    title: "Checklist Umrah",
                    subtitle: "Travel Document",
                    button1: "View",
                    button2: "Download",
                    icon: AppAssets.save,
                  ),
                  ontap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyDocumentCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.setOpacity(0.1)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.setOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(AppAssets.upload, width: 60.w, height: 60.h),
          SizedBox(height: 10.h),
          AppText(
            text: "No documents uploaded yet",
            style: textStyle16SemiBold.copyWith(
              fontSize: 21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          10.h.verticalSpace,
          AppText(
            text: "Add your Passport, Visa, Tickets here.",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          40.h.verticalSpace,
          AppButton(
            title: "Add New Document",
            onTap: () {
              context.pushNamed(UserAppRoutes.addDocumentScreen.name);
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    Color textColor;

    if (title == "Paid") {
      textColor = AppColors.primaryColor.setOpacity(0.6);
    } else if (title == "Pending") {
      textColor = AppColors.primaryColor.setOpacity(0.6);
    } else {
      textColor = AppColors.primaryColor;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          AppText(
            text: ":",
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.6),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: value,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(13.0),
            child: SvgIcon(
              AppAssets.creditcard,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          labelText: "Card number",
          hintText: "0000 0000 0000",
        ),

        15.h.verticalSpace,

        Row(
          children: [
            Expanded(
              child: AppTextField(labelText: "CVC", hintText: "CVV"),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: AppTextField(labelText: "Expiry date", hintText: "MM/YY"),
            ),
          ],
        ),
        16.h.verticalSpace,
      ],
    );
  }
}
