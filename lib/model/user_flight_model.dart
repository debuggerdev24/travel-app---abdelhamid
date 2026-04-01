class FlightDetailsModel {
  final TripInfoModel trip;
  final List<FlightInfoModel> flights;

  FlightDetailsModel({
    required this.trip,
    required this.flights,
  });

  factory FlightDetailsModel.fromJson(Map<String, dynamic> json) {
    return FlightDetailsModel(
      trip: TripInfoModel.fromJson(json['trip']),
      flights: (json['flights'] as List)
          .map((f) => FlightInfoModel.fromJson(f))
          .toList(),
    );
  }
}

class TripInfoModel {
  final String tripName;
  final String location;
  final String bannerImage;
  final String startDate;
  final String endDate;

  TripInfoModel({
    required this.tripName,
    required this.location,
    required this.bannerImage,
    required this.startDate,
    required this.endDate,
  });

  factory TripInfoModel.fromJson(Map<String, dynamic> json) {
    return TripInfoModel(
      tripName: json['tripName'] ?? '',
      location: json['location'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }
}

class FlightInfoModel {
  final String assignmentId;
  final String flightId;
  final String seatNumber;
  final String deskNumber;
  final String status;
  final String flightName;
  final String route;
  final String date;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String baggage;
  final String airlineContact;
  final String supportEmail;
  final String flightType;

  FlightInfoModel({
    required this.assignmentId,
    required this.flightId,
    required this.seatNumber,
    required this.deskNumber,
    required this.status,
    required this.flightName,
    required this.route,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.baggage,
    required this.airlineContact,
    required this.supportEmail,
    required this.flightType,
  });

  factory FlightInfoModel.fromJson(Map<String, dynamic> json) {
    return FlightInfoModel(
      assignmentId: json['assignmentId'] ?? '',
      flightId: json['flightId'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      deskNumber: json['deskNumber'] ?? '',
      status: json['status'] ?? '',
      flightName: json['flightName'] ?? '',
      route: json['route'] ?? '',
      date: json['date'] ?? '',
      departureTime: json['departureTime'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      duration: json['duration'] ?? '',
      baggage: json['baggage'] ?? '',
      airlineContact: json['airlineContact'] ?? '',
      supportEmail: json['supportEmail'] ?? '',
      flightType: json['flightType'] ?? '',
    );
  }

  // Helper to map fields for TripDetialsCard infoMap
  Map<String, String> get infoMap => {
    "Flight": flightName,
    "Route": route,
    "Date": date,
    "Departure": departureTime,
    "Arrival": arrivalTime,
    "Duration": duration,
    "Seat": seatNumber,
    "Baggage": baggage,
    "Airline Contact": airlineContact,
    "Desk No": deskNumber,
    "Email": supportEmail,
    "Status": status,
  };
}