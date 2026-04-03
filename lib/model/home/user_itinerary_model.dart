class UserItineraryResponseModel {
  final UserItineraryTripInfo trip;
  final UserItineraryDay itinerary;

  UserItineraryResponseModel({
    required this.trip,
    required this.itinerary,
  });

  factory UserItineraryResponseModel.fromJson(Map<String, dynamic> json) {
    return UserItineraryResponseModel(
      trip: UserItineraryTripInfo.fromJson(
        (json['trip'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      itinerary: UserItineraryDay.fromJson(
        (json['itinerary'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  factory UserItineraryResponseModel.empty() {
    return UserItineraryResponseModel(
      trip: UserItineraryTripInfo(
        tripName: '',
        location: '',
        bannerImage: '',
        startDate: null,
        endDate: null,
      ),
      itinerary: UserItineraryDay(
        id: '',
        dayTitle: '',
        dayNumber: 0,
        notes: null,
        date: null,
        status: '',
        activities: const [],
      ),
    );
  }
}

class UserItineraryTripInfo {
  final String tripName;
  final String location;
  final String bannerImage;
  final String? startDate;
  final String? endDate;

  UserItineraryTripInfo({
    required this.tripName,
    required this.location,
    required this.bannerImage,
    required this.startDate,
    required this.endDate,
  });

  factory UserItineraryTripInfo.fromJson(Map<String, dynamic> json) {
    return UserItineraryTripInfo(
      tripName: (json['tripName'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      bannerImage: (json['bannerImage'] ?? '').toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
    );
  }
}

class UserItineraryDay {
  final String id;
  final String dayTitle;
  final int dayNumber;
  final String? notes;
  final String? date;
  final String status;
  final List<UserItineraryActivity> activities;

  UserItineraryDay({
    required this.id,
    required this.dayTitle,
    required this.dayNumber,
    required this.notes,
    required this.date,
    required this.status,
    required this.activities,
  });

  factory UserItineraryDay.fromJson(Map<String, dynamic> json) {
    return UserItineraryDay(
      id: (json['_id'] ?? '').toString(),
      dayTitle: (json['dayTitle'] ?? '').toString(),
      dayNumber: (json['dayNumber'] ?? 0) is int
          ? (json['dayNumber'] as int)
          : int.tryParse((json['dayNumber'] ?? '0').toString()) ?? 0,
      notes: json['notes']?.toString(),
      date: json['date']?.toString(),
      status: (json['status'] ?? '').toString(),
      activities:
          (json['activities'] as List?)
              ?.map(
                (e) => UserItineraryActivity.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList() ??
          const [],
    );
  }
}

class UserItineraryActivity {
  final String icon;
  final String times;
  final String activityTitle;
  final int? order;

  UserItineraryActivity({
    required this.icon,
    required this.times,
    required this.activityTitle,
    required this.order,
  });

  factory UserItineraryActivity.fromJson(Map<String, dynamic> json) {
    return UserItineraryActivity(
      icon: (json['icon'] ?? '').toString(),
      times: (json['times'] ?? '').toString(),
      activityTitle: (json['activityTitle'] ?? '').toString(),
      order: (json['order'] is int) ? json['order'] as int : int.tryParse('${json['order']}'),
    );
  }
}

