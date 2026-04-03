import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';

/// Response from `GET /api/user/trip-documents?tripId=` (see backend [tripDocumentsController]).
class TripDocumentsBundle {
  final List<MemberTripDocuments> memberDocuments;
  final TripLevelDocuments tripDocuments;

  TripDocumentsBundle({
    required this.memberDocuments,
    required this.tripDocuments,
  });

  factory TripDocumentsBundle.empty() {
    return TripDocumentsBundle(
      memberDocuments: const [],
      tripDocuments: TripLevelDocuments.empty(),
    );
  }

  factory TripDocumentsBundle.fromJson(Map<String, dynamic> json) {
    final raw = json['memberDocuments'];
    final members = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => MemberTripDocuments.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <MemberTripDocuments>[];

    final td = json['tripDocuments'];
    final tripLevel = td is Map
        ? TripLevelDocuments.fromJson(td.cast<String, dynamic>())
        : TripLevelDocuments.empty();

    return TripDocumentsBundle(
      memberDocuments: members,
      tripDocuments: tripLevel,
    );
  }

  bool get hasAnyRemoteContent {
    if (tripDocuments.hotel != null ||
        tripDocuments.insurance != null ||
        tripDocuments.checklist != null) {
      return true;
    }
    for (final m in memberDocuments) {
      final d = m.documents;
      if (d.visa != null ||
          d.passport != null ||
          d.medicalCertificate != null ||
          d.flightTickets.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}

class MemberTripDocuments {
  final String memberId;
  final String name;
  final String? relationship;
  final MemberDocsPayload documents;

  MemberTripDocuments({
    required this.memberId,
    required this.name,
    this.relationship,
    required this.documents,
  });

  factory MemberTripDocuments.fromJson(Map<String, dynamic> json) {
    final docs = json['documents'];
    return MemberTripDocuments(
      memberId: (json['memberId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      relationship: json['relationship']?.toString(),
      documents: docs is Map
          ? MemberDocsPayload.fromJson(docs.cast<String, dynamic>())
          : MemberDocsPayload.empty(),
    );
  }
}

class MemberDocsPayload {
  final PersonalDoc? visa;
  final PersonalDoc? passport;
  final PersonalDoc? medicalCertificate;
  final List<FlightTicketDoc> flightTickets;

  MemberDocsPayload({
    this.visa,
    this.passport,
    this.medicalCertificate,
    this.flightTickets = const [],
  });

  factory MemberDocsPayload.empty() {
    return MemberDocsPayload();
  }

  factory MemberDocsPayload.fromJson(Map<String, dynamic> json) {
    List<FlightTicketDoc> tickets = const [];
    final ft = json['flightTickets'];
    if (ft is List) {
      tickets = ft
          .whereType<Map>()
          .map((e) => FlightTicketDoc.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return MemberDocsPayload(
      visa: _parsePersonal(json['visa']),
      passport: _parsePersonal(json['passport']),
      medicalCertificate: _parsePersonal(json['medicalCertificate']),
      flightTickets: tickets,
    );
  }

  static PersonalDoc? _parsePersonal(dynamic v) {
    if (v == null) return null;
    if (v is! Map) return null;
    return PersonalDoc.fromJson(v.cast<String, dynamic>());
  }
}

class PersonalDoc {
  final String? id;
  final String documentName;
  final String? photo;
  final String? fileType;
  final String? uploadedDate;

  PersonalDoc({
    this.id,
    required this.documentName,
    this.photo,
    this.fileType,
    this.uploadedDate,
  });

  factory PersonalDoc.fromJson(Map<String, dynamic> json) {
    return PersonalDoc(
      id: json['_id']?.toString(),
      documentName: (json['documentName'] ?? '-').toString(),
      photo: json['photo']?.toString(),
      fileType: json['fileType']?.toString(),
      uploadedDate: json['uploadedDate']?.toString(),
    );
  }

  String? get resolvedViewUrl {
    final u = serverMediaUrl(photo);
    return u;
  }
}

class FlightTicketDoc {
  final String? assignmentId;
  final String? ticketImage;
  final String? fileType;
  final String? uploadedDate;
  final String? flightName;
  final String? date;
  final String? flightType;

  FlightTicketDoc({
    this.assignmentId,
    this.ticketImage,
    this.fileType,
    this.uploadedDate,
    this.flightName,
    this.date,
    this.flightType,
  });

  factory FlightTicketDoc.fromJson(Map<String, dynamic> json) {
    return FlightTicketDoc(
      assignmentId: json['assignmentId']?.toString(),
      ticketImage: json['ticketImage']?.toString(),
      fileType: json['fileType']?.toString(),
      uploadedDate: json['uploadedDate']?.toString(),
      flightName: json['flightName']?.toString(),
      date: json['date']?.toString(),
      flightType: json['flightType']?.toString(),
    );
  }

  String? get resolvedTicketUrl => serverMediaUrl(ticketImage);
}

class TripLevelDocuments {
  final BundleHotelDoc? hotel;
  final BundleInsuranceDoc? insurance;
  final BundleChecklistDoc? checklist;

  TripLevelDocuments({
    this.hotel,
    this.insurance,
    this.checklist,
  });

  factory TripLevelDocuments.empty() => TripLevelDocuments();

  factory TripLevelDocuments.fromJson(Map<String, dynamic> json) {
    return TripLevelDocuments(
      hotel: json['hotel'] is Map
          ? BundleHotelDoc.fromJson(
              (json['hotel'] as Map).cast<String, dynamic>(),
            )
          : null,
      insurance: json['insurance'] is Map
          ? BundleInsuranceDoc.fromJson(
              (json['insurance'] as Map).cast<String, dynamic>(),
            )
          : null,
      checklist: json['checklist'] is Map
          ? BundleChecklistDoc.fromJson(
              (json['checklist'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}

class BundleHotelDoc {
  final String? id;
  final String hotelName;
  final String? checkIn;
  final String? checkOut;
  final String? hotelImage;
  final String? fileType;
  final String? uploadedDate;

  BundleHotelDoc({
    this.id,
    required this.hotelName,
    this.checkIn,
    this.checkOut,
    this.hotelImage,
    this.fileType,
    this.uploadedDate,
  });

  factory BundleHotelDoc.fromJson(Map<String, dynamic> json) {
    return BundleHotelDoc(
      id: json['_id']?.toString(),
      hotelName: (json['hotelName'] ?? '-').toString(),
      checkIn: json['checkIn']?.toString(),
      checkOut: json['checkOut']?.toString(),
      hotelImage: json['hotelImage']?.toString(),
      fileType: json['fileType']?.toString(),
      uploadedDate: json['uploadedDate']?.toString(),
    );
  }

  String? get resolvedImageUrl => serverMediaUrl(hotelImage);
}

class BundleInsuranceDoc {
  final String? policyName;
  final String? coverage;
  final String? emergencyDetails;
  final String? image;
  final String? document;
  final String? fileType;
  final String? uploadedDate;

  BundleInsuranceDoc({
    this.policyName,
    this.coverage,
    this.emergencyDetails,
    this.image,
    this.document,
    this.fileType,
    this.uploadedDate,
  });

  factory BundleInsuranceDoc.fromJson(Map<String, dynamic> json) {
    return BundleInsuranceDoc(
      policyName: json['policyName']?.toString(),
      coverage: json['coverage']?.toString(),
      emergencyDetails: json['emergencyDetails']?.toString(),
      image: json['image']?.toString(),
      document: json['document']?.toString(),
      fileType: json['fileType']?.toString(),
      uploadedDate: json['uploadedDate']?.toString(),
    );
  }

  /// Prefer image for thumbnail; [document] is often PDF path.
  String? get resolvedThumbnailUrl => serverMediaUrl(image) ?? serverMediaUrl(document);

  String? get resolvedPrimaryFileUrl =>
      serverMediaUrl(document) ?? serverMediaUrl(image);
}

class BundleChecklistDoc {
  final String? image;
  final String? document;
  final String? fileType;
  final String? uploadedDate;

  BundleChecklistDoc({
    this.image,
    this.document,
    this.fileType,
    this.uploadedDate,
  });

  factory BundleChecklistDoc.fromJson(Map<String, dynamic> json) {
    return BundleChecklistDoc(
      image: json['image']?.toString(),
      document: json['document']?.toString(),
      fileType: json['fileType']?.toString(),
      uploadedDate: json['uploadedDate']?.toString(),
    );
  }

  String? get resolvedThumbnailUrl => serverMediaUrl(image) ?? serverMediaUrl(document);

  String? get resolvedPrimaryFileUrl =>
      serverMediaUrl(document) ?? serverMediaUrl(image);
}
