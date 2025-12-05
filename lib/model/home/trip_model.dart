import 'dart:io';

class TripModel {
  final String image;
  final String title;
  final String location;
  final String date;
  final String status;
  final String description;

  TripModel({
    required this.image,
    required this.title,
    required this.location,
    required this.date,
     required this.status,
    required this.description,
  });
}
class PackageDetails {
  final String title;
  final List<String> roomOptions;
  final List<String> childPrices;
  final List<String> inclusions;
  final List<String> exclusions;

  PackageDetails({
    required this.title,
    required this.roomOptions,
    required this.childPrices,
    required this.inclusions,
    required this.exclusions,
  });
}
class PaymentModel {
  final String id;
  final String amount;
  final String date;

  PaymentModel({
    required this.id,
    required this.amount,
    required this.date,
  });
}
class FlightModel {
  final String title;
  final String flightNumber;
  final String route;
  final String date;
  final String departure;
  final String arrival;
  final String duration;
  final String seat;
  final String baggage;
  final String airlineContact;
  final String deskNo;
  final String email;
  final String status;

  FlightModel({
    required this.title,
    required this.flightNumber,
    required this.route,
    required this.date,
    required this.departure,
    required this.arrival,
    required this.duration,
    required this.seat,
    required this.baggage,
    required this.airlineContact,
    required this.deskNo,
    required this.email,
    required this.status,
  });

  /// 🔥 Return all fields in a map to generate buildRow dynamically
  Map<String, String> get infoMap => {
        "Flight": flightNumber,
        "Route": route,
        "Date": date,
        "Departure": departure,
        "Arrival": arrival,
        "Duration": duration,
        "Seat": seat,
        "Baggage": baggage,
        "Airline Contact": airlineContact,
        "Desk No": deskNo,
        "Email": email,
        "Status": status,
      };
}
class HotelModel {
  final String title;
  final String name;
  final String address;
  final String phone;
  final String checkIn;
  final String checkOut;
  final String roomType;
  final String roomNo;
  final String facilities;
  final String status;

  HotelModel({
    required this.title,
    required this.name,
    required this.address,
    required this.phone,
    required this.checkIn,
    required this.checkOut,
    required this.roomType,
    required this.roomNo,
    required this.facilities,
    required this.status,
  });

  Map<String, String> get infoMap => {
        "Name": name,
        "Address": address,
        "Phone": phone,
        "Check-in": checkIn,
        "Check-out": checkOut,
        "Room Type": roomType,
        "Room No": roomNo,
        "Facilities": facilities,
        "Status": status,
      };
}

class UserDocument {
  String? name;
  String? filePath;

  UserDocument({this.name, this.filePath});
}
class DocumentModel {
  final String image;               
  final String title;            
  final File? fileImage;           
  final String? subtitle;           
  final Map<String, String>? info;  
  final String button1;            
  final String button2;            
  final String icon;                

  DocumentModel({
    required this.image,
    required this.title,
    this.fileImage,
    this.subtitle,
    this.info,
    required this.button1,
    required this.button2,
    required this.icon, 
  });
}
