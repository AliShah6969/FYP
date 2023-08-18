import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:szabist_carpool/models/student.dart';

class BookingRequest {
  Student student;
  String studentEmail;
  String driverEmail;
  String pickupAddress;
  double pickupLat;
  double pickupLon;
  String status;
  String date;

  BookingRequest({
    required this.student,
    required this.studentEmail,
    required this.driverEmail,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLon,
    required this.status,
    required this.date,
  });

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      student: Student.fromJson(json['student']),
      studentEmail: json['studentEmail'],
      driverEmail: json['driverEmail'],
      pickupAddress: json['pickupAddress'],
      pickupLat: json['pickupLat'],
      pickupLon: json['pickupLon'],
      status: json['status'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'studentEmail': studentEmail,
      'driverEmail': driverEmail,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLon': pickupLon,
      'status': status,
      'date': date,
    };
  }
}
