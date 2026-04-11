class Endpoints {
  Endpoints._();

  static const String signIn = '/auth/login';
  static const String signUp = '/auth/register';
  static const String forgetPassword = '/auth/forget-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';

  static const String getTrips = '/trips/list';
  static const String getTripDetails = '/trips/details';
  static const String addBookingPackage = '/booking/add-package';
  static const String getPackageOptions = '/booking/get-package-options';
  static const String saveRoomPreference = '/booking/save-room-preference';
  static const String savePersonDetail = '/booking/save-person-details';
  static const String saveFamilyDetails = '/booking/add-family-member';

  /// `GET ?bookingId=` — booking + populated trip (used to resolve `tripId` after `/user-payment/my-trip`).
  static const String bookingGetPackageDetails = '/booking/get-package-details';
  static const String bookingGetUserDetails = '/booking/get-user-details';
  static const String bookingEditProfile = '/booking/edit-profile';
  static const String bookingChangeProfileImage = '/booking/change-profile-image';

  /// `PATCH ?bookingId=` — sets booking `active` and adds user to trip chat group.
  static const String bookingBookingStatus = '/booking/booking-status';

  static const String myFlights = '/flights/my-flights';
  static const String hotelVoucherDetails = '/hotel/voucher';
  static const String todayItinerary = '/itinerary/today';

  /// `GET ?tripId=` — member docs + trip hotel / insurance / checklist (backend bundle).
  static const String tripDocuments = '/trip-documents';

  /// `POST ?tripId=` — multipart: `documentType`, `documentName`, optional `memberId`, file `photo`.
  static const String addUserDocument = '/documents/add-document';

  /// `GET` — Bearer auth; latest active/pending booking + payment summary. Base: [AppConstants.apiPublicRoot].
  static const String userPaymentMyTripPath = '/user-payment/my-trip';

  /// `GET ?bookingId=` — optional; payment rows for user. Base: [AppConstants.apiPublicRoot].
  static const String userPaymentHistoryPath = '/user-payment/history';

  /// `GET ?paymentId=` — receipt detail. Base: [AppConstants.apiPublicRoot].
  static const String userPaymentReceiptPath = '/user-payment/receipt';

  static const String essentialPackingList = '/api/essential/get-packing-list';
  static const String essentialCurrencyInfo = '/api/essential/get-currency-info';
  static const String essentialEmergencyContacts =
      '/api/essential/get-emergency-contacts';
  static const String essentialLocalInfo = '/api/essential/get-local-info';
  static const String essentialHealthTips = '/api/essential/get-health-tips';

  static const String duaFetchDetails = '/api/dua/fetch-dua-details';

  static const String tourGuideFetchDetails =
      '/api/tour-guide/fetch-guide-details';

  // --- CMS (`/api/...`, use with [AppConstants.apiPublicRoot]) ---
  static const String faqList = '/faq/get-faqs';
  static const String socialList = '/social/get-socials';
  static const String rulesGet = '/rules/get-rules';

  /// `GET` — Bearer auth; response `data` is map of country → list of locations.
  static const String locationGetList = '/location/get-locations';

  /// `GET` — Bearer auth; list of team members with photos.
  static const String teamGetMembers = '/team/get-members';

  /// `POST` — body: `purpose`, `rating`, `review`; optional query `tripId` for trip reviews.
  static const String reviewsNewReview = '/reviews/new-review';

  /// `GET` — Bearer auth; list of `{ name, time }` prayer rows.
  static const String prayerDetails = '/prayer/prayer-details';
}
