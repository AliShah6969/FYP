import 'package:szabist_carpool/models/attenders.dart';
import 'package:szabist_carpool/models/student.dart';

class Booking {
  String id;
  String date;
  String driverEmail;
  String driverName;
  String driverPhone;
  int seatsAvailable;
  List<dynamic> attenderEmails;
  String driverAddress;
  double driverLat;
  double driverLon;
  List<dynamic> attenders;
  String status;

  Booking({
    required this.id,
    required this.date,
    required this.driverEmail,
    required this.driverName,
    required this.driverPhone,
    required this.seatsAvailable,
    required this.attenderEmails,
    required this.driverAddress,
    required this.driverLat,
    required this.driverLon,
    required this.attenders,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      date: json['date'],
      driverEmail: json['driverEmail'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      seatsAvailable: json['seatsAvailable'],
      attenders: json['attenders'],
      attenderEmails: json['attenderEmails'],
      driverAddress: json['driverAddress'],
      driverLat: json['driverLat'],
      driverLon: json['driverLon'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'driverEmail': driverEmail,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'seatsAvailable': seatsAvailable,
      'attenders': attenders,
      'attenderEmails': attenderEmails,
      'driverAddress': driverAddress,
      'driverLat': driverLat,
      'driverLon': driverLon,
      'status': status,
    };
  }
}
