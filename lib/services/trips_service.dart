import 'dart:io';

import 'package:trael_app_abdelhamid/core/constants/app_constants.dart';
import 'package:trael_app_abdelhamid/core/network/base_api_service.dart';
import 'package:trael_app_abdelhamid/core/network/endpoints.dart';
import 'package:trael_app_abdelhamid/core/utils/payment_flow_log.dart';
import 'package:trael_app_abdelhamid/core/network/network_errors.dart';
import 'package:trael_app_abdelhamid/model/home/hotel_voucher_model.dart';
import 'package:trael_app_abdelhamid/model/home/payment_receipt_detail.dart';
import 'package:trael_app_abdelhamid/model/home/trip_model.dart';
import 'package:trael_app_abdelhamid/model/home/user_payment_history_item.dart';
import 'package:trael_app_abdelhamid/model/home/user_itinerary_model.dart';
import 'package:trael_app_abdelhamid/model/trip/trip_documents_bundle_model.dart';
import 'package:trael_app_abdelhamid/model/user_flight_model.dart';

enum TripsType { upcoming, past }

class TripsService {
  TripsService._internal();
  static final TripsService instance = TripsService._internal();

  /// Backend: `GET /api/user/trips/list?type=upcoming` → `data` is a JSON array.
  Future<List<TripModel>> getUpcomingTrips({
    bool showErrorToast = false,
  }) async {
    try {
      return await _getTrips(
        TripsType.upcoming,
        showErrorToast: showErrorToast,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Backend: `GET /api/user/trips/list?type=past` → `data` is a JSON array.
  Future<List<TripModel>> getPastTrips({bool showErrorToast = false}) async {
    try {
      return await _getTrips(TripsType.past, showErrorToast: showErrorToast);
    } catch (e) {
      rethrow;
    }
  }

  Future<TripModel> getTripDetails(
    String id, {
    bool showErrorToast = true,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.getTripDetails,
        queryParameters: {'tripId': id},
        showErrorToast: showErrorToast,
      );

      if (response['data'] != null) {
        return TripModel.fromJson(response['data']);
      } else {
        throw Exception('Trip details not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TripModel>> _getTrips(
    TripsType type, {
    bool showErrorToast = false,
  }) async {
    try {
      final typeStr = type == TripsType.upcoming ? 'upcoming' : 'past';
      final response = await BaseApiService.instance.get(
        Endpoints.getTrips,
        queryParameters: {'type': typeStr},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      // Backend: with ?type=upcoming|past, `data` is a plain array of trips.
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => TripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      // Without `type`, `data` is { upcoming: [...], past: [...] }.
      if (data is Map) {
        final key = type == TripsType.upcoming ? 'upcoming' : 'past';
        final list = data[key] as List<dynamic>? ?? [];
        return list
            .whereType<Map>()
            .map((e) => TripModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Backend: `GET /api/user-payment/my-trip` (optional `?bookingId=`) then enriches trip via
  /// `GET .../booking/get-package-details` + [getTripDetails] when possible; falls back to the
  /// nested `trip` object from my-trip (`name`, `location`, `bannerImage`, dates).
  Future<EnrolledTripContext?> fetchEnrolledTripContext({
    String? bookingId,
  }) async {
    final myTripUrl =
        '${AppConstants.apiPublicRoot}${Endpoints.userPaymentMyTripPath}';
    final query = <String, dynamic>{};
    if (bookingId != null && bookingId.isNotEmpty) {
      query['bookingId'] = bookingId;
    }
    try {
      final response = await BaseApiService.instance.get(
        myTripUrl,
        queryParameters: query.isEmpty ? null : query,
        showErrorToast: false,
      );
      if (response['status'] != 1 || response['data'] == null) {
        PaymentFlowLog.log('fetchEnrolledTripContext: my-trip no data', {
          'status': response['status'],
        });
        return null;
      }
      final data = Map<String, dynamic>.from(response['data'] as Map);
      final bookingId = data['bookingId']?.toString();
      if (bookingId == null || bookingId.isEmpty) {
        PaymentFlowLog.log('fetchEnrolledTripContext: missing bookingId in my-trip');
        return null;
      }

      PaymentFlowLog.log('fetchEnrolledTripContext: my-trip raw paymentSummary', {
        'bookingId': bookingId,
        'paymentSummary': data['paymentSummary']?.toString() ?? 'null',
      });

      var paymentDetails = TripPaymentDetails.fromJson(data);
      PaymentFlowLog.log('fetchEnrolledTripContext: parsed TripPaymentDetails', {
        'bookingId': bookingId,
        'packageName': paymentDetails.packageName,
        'totalAmount': paymentDetails.totalAmount,
        'paidAmount': paymentDetails.paidAmount,
        'pendingAmount': paymentDetails.pendingAmount,
        'isFullyPaid': paymentDetails.isFullyPaid,
      });

      // If my-trip totals lag behind Stripe but history already lists succeeded charges, align UI.
      try {
        final history = await fetchUserPaymentHistory(
          bookingId: bookingId,
          showErrorToast: false,
        );
        final succeededSum = history
            .where((e) => e.isSucceeded)
            .fold<double>(0, (a, e) => a + e.amount);
        const eps = 0.01;
        if (succeededSum > paymentDetails.paidAmount + eps) {
          PaymentFlowLog.log(
            'fetchEnrolledTripContext: reconciling paid/pending from payment history',
            {
              'myTripPaid': paymentDetails.paidAmount,
              'historySucceededSum': succeededSum,
            },
          );
          paymentDetails =
              paymentDetails.withReconciledPaid(succeededSum);
        }
      } catch (_) {
        // Keep my-trip-only totals on history errors.
      }

      final trip = await _resolveEnrolledTripModel(data);
      if (trip == null) {
        PaymentFlowLog.log(
          'fetchEnrolledTripContext: could not build TripModel (no trip in response)',
        );
        return null;
      }
      return EnrolledTripContext(
        trip: trip,
        bookingId: bookingId,
        paymentDetails: paymentDetails,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Prefer full `/trips/details` when package details include a trip `_id`; otherwise use the
  /// nested `trip` object from my-trip (`name`, `bannerImage`, …).
  Future<TripModel?> _resolveEnrolledTripModel(
    Map<String, dynamic> myTripData,
  ) async {
    TripModel? snippetFromMyTrip() {
      final raw = myTripData['trip'];
      if (raw is! Map) return null;
      final m = Map<String, dynamic>.from(raw);
      if (m['_id'] == null &&
          m['tripId'] == null &&
          myTripData['tripId'] != null) {
        m['_id'] = myTripData['tripId'];
      }
      return TripModel.fromUserPaymentMyTripJson(m);
    }

    final bid = myTripData['bookingId']?.toString();
    if (bid == null || bid.isEmpty) {
      return snippetFromMyTrip();
    }

    try {
      final pkgResponse = await BaseApiService.instance.get(
        Endpoints.bookingGetPackageDetails,
        queryParameters: {'bookingId': bid},
        showErrorToast: false,
      );
      if (pkgResponse['status'] == 1 && pkgResponse['data'] != null) {
        final pkgData = Map<String, dynamic>.from(pkgResponse['data'] as Map);
        final tripRaw = pkgData['trip'];
        if (tripRaw is Map) {
          final tripMap = Map<String, dynamic>.from(tripRaw);
          final tripId = tripMap['_id']?.toString();
          if (tripId != null && tripId.isNotEmpty) {
            try {
              return await getTripDetails(tripId, showErrorToast: false);
            } catch (e) {
              PaymentFlowLog.log(
                'fetchEnrolledTripContext: getTripDetails failed, using snippet',
                {'tripId': tripId, 'error': e.toString()},
              );
              final fall = snippetFromMyTrip() ??
                  TripModel.fromUserPaymentMyTripJson(tripMap);
              if (fall.id == null || fall.id!.isEmpty) {
                return TripModel(
                  id: tripId,
                  image: fall.image,
                  title: fall.title,
                  location: fall.location,
                  date: fall.date,
                  status: fall.status,
                  description: fall.description,
                  packages: fall.packages,
                );
              }
              return fall;
            }
          }
          final fromPkg = TripModel.fromUserPaymentMyTripJson(tripMap);
          if (fromPkg.title.isNotEmpty || fromPkg.location.isNotEmpty) {
            return fromPkg;
          }
        }
      }
    } catch (e) {
      PaymentFlowLog.log(
        'fetchEnrolledTripContext: get-package-details failed',
        {'error': e.toString()},
      );
    }

    return snippetFromMyTrip();
  }

  /// Backend: `GET /api/user-payment/history` (optional `bookingId`).
  Future<List<UserPaymentHistoryItem>> fetchUserPaymentHistory({
    String? bookingId,
    bool showErrorToast = false,
  }) async {
    final url =
        '${AppConstants.apiPublicRoot}${Endpoints.userPaymentHistoryPath}';
    final query = <String, dynamic>{};
    if (bookingId != null && bookingId.isNotEmpty) {
      query['bookingId'] = bookingId;
    }
    final response = await BaseApiService.instance.get(
      url,
      queryParameters: query.isEmpty ? null : query,
      showErrorToast: showErrorToast,
    );
    if (response['status'] != 1 || response['data'] == null) return [];
    final data = response['data'];
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map(
          (e) => UserPaymentHistoryItem.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  /// Backend: `GET /api/user-payment/receipt?paymentId=`
  Future<PaymentReceiptDetail?> fetchPaymentReceipt(
    String paymentId, {
    bool showErrorToast = true,
  }) async {
    final url =
        '${AppConstants.apiPublicRoot}${Endpoints.userPaymentReceiptPath}';
    final response = await BaseApiService.instance.get(
      url,
      queryParameters: {'paymentId': paymentId},
      showErrorToast: showErrorToast,
    );
    if (response['status'] != 1 || response['data'] == null) return null;
    final data = Map<String, dynamic>.from(response['data'] as Map);
    return PaymentReceiptDetail.fromJson(data);
  }

  Future<Map<String, dynamic>> savePersonDetail(
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.savePersonDetail,
        body: body,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addBookingPackage(
    String tripId,
    String packageId,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.addBookingPackage,
        queryParameters: {'tripId': tripId},
        body: {'packageId': packageId},
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPackageOptions(String tripId) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.getPackageOptions,
        queryParameters: {'tripId': tripId},
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveFamilyDetails({
    required String bookingId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.saveFamilyDetails,
        queryParameters: {'bookingId': bookingId},
        body: body,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<FlightDetailsModel> getMyFlights(String tripId) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.myFlights,
        queryParameters: {'tripId': tripId},
        showErrorToast: true,
      );

      if (response['data'] != null) {
        return FlightDetailsModel.fromJson(response['data']);
      } else {
        throw Exception('Flight details not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HotelVoucherModel>> getHotelVoucherDetails(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.hotelVoucherDetails,
        queryParameters: {'tripId': tripId},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => HotelVoucherModel.fromJson(e.cast<String, dynamic>()))
            .toList();
      }

      return [];
    } on ApiException catch (e) {
      // Backend uses 404 when there are no allocations yet.
      // Treat it as an empty state, not an error.
      if (e.statusCode == 404) {
        return [];
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Trip d ocuments bundle: `memberDocuments` + `tripDocuments` (hotel, insurance, checklist).
  /// Backend: `GET /api/user/trip-documents?tripId=`.
  Future<TripDocumentsBundle> getTripDocuments(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    final response = await BaseApiService.instance.get(
      Endpoints.tripDocuments,
      queryParameters: {'tripId': tripId},
      showErrorToast: showErrorToast,
    );

    if (response is! Map) {
      throw Exception('Invalid trip documents response');
    }
    final root = Map<String, dynamic>.from(response);
    final data = root['data'];
    if (data is! Map) {
      throw Exception('Trip documents payload missing');
    }
    return TripDocumentsBundle.fromJson(Map<String, dynamic>.from(data));
  }

  /// `POST /documents/add-document?tripId=` — multipart field `photo` + body fields.
  /// [documentType] must be `passport`, `visa`, or `medical certificate` (backend).
  Future<Map<String, dynamic>> addUserDocument({
    required String tripId,
    required String documentType,
    required String documentName,
    required File photoFile,
    String? memberId,
    bool showErrorToast = true,
  }) async {
    final fields = <String, String>{
      'documentType': documentType,
      'documentName': documentName,
      if (memberId != null && memberId.isNotEmpty) 'memberId': memberId,
    };
    final response = await BaseApiService.instance.postMultipart(
      Endpoints.addUserDocument,
      fields: fields,
      fileFieldName: 'photo',
      filePath: photoFile.path,
      queryParameters: {'tripId': tripId},
      showErrorToast: showErrorToast,
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    throw Exception('Invalid add-document response');
  }

  Future<UserItineraryResponseModel> getTodayItinerary(
    String tripId, {
    bool showErrorToast = false,
  }) async {
    try {
      final response = await BaseApiService.instance.get(
        Endpoints.todayItinerary,
        queryParameters: {'tripId': tripId},
        showErrorToast: showErrorToast,
      );

      final data = response['data'];
      if (data is Map) {
        return UserItineraryResponseModel.fromJson(
          data.cast<String, dynamic>(),
        );
      }

      throw Exception('Itinerary not found');
    } on ApiException catch (e) {
      // Backend uses 404 when there is no itinerary for the day.
      // Treat it as an empty state.
      if (e.statusCode == 404) {
        return UserItineraryResponseModel.empty();
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  //   Future<TripPaymentDetails> getPaymentDetails(
  //   String tripId, {
  //   bool showErrorToast = true,
  // }) async {
  //   try {
  //     final response = await BaseApiService.instance.get(
  //       Endpoints.getPaymentDetails, // add this in endpoints.dart manually
  //       queryParameters: {'tripId': tripId},
  //       showErrorToast: showErrorToast,
  //     );

  //     if (response['data'] != null) {
  //       return TripPaymentDetails.fromJson(response['data']);
  //     } else {
  //       throw Exception('Payment details not found');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }  
  // }

  Future<Map<String, dynamic>> saveRoomPreference(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await BaseApiService.instance.post(
        Endpoints.saveRoomPreference,
        body: data,
        showErrorToast: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Backend: `PATCH /api/user/booking/booking-status?bookingId=` — sets booking
  /// `active` and adds the user to the official trip chat group.
  ///
  /// If the booking is already active, the API returns an error; that case is
  /// treated as success so this stays safe to call after every payment.
  Future<void> markBookingActive({
    required String bookingId,
    bool showErrorToast = false,
  }) async {
    if (bookingId.isEmpty) return;
    try {
      await BaseApiService.instance.patch(
        Endpoints.bookingBookingStatus,
        queryParameters: {'bookingId': bookingId},
        showErrorToast: showErrorToast,
      );
      PaymentFlowLog.log('markBookingActive: ok', {'bookingId': bookingId});
    } on ApiException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already booked') || msg.contains('already')) {
        PaymentFlowLog.log('markBookingActive: already active', {
          'bookingId': bookingId,
        });
        return;
      }
      PaymentFlowLog.log('markBookingActive: failed', {
        'bookingId': bookingId,
        'message': e.message,
      });
      if (showErrorToast) rethrow;
    } catch (e) {
      PaymentFlowLog.log('markBookingActive: failed', {
        'bookingId': bookingId,
        'error': e.toString(),
      });
      if (showErrorToast) rethrow;
    }
  }
}
