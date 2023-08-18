import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:szabist_carpool/models/attenders.dart';
import 'package:szabist_carpool/models/booking.dart';
import 'package:szabist_carpool/models/driver.dart';
import 'package:szabist_carpool/models/request.dart';
import 'package:szabist_carpool/models/student.dart';

class DatabaseController {
  Future<bool> setDaySchedule(
      bool isDriver, String email, Map<String, dynamic> daysSchedule) async {
    var collection = FirebaseFirestore.instance
        .collection(isDriver ? "drivers" : "students");
    var currentUserDocument =
        await collection.where("email", isEqualTo: email).get();
    await collection
        .doc(currentUserDocument.docs.first.id)
        .update(daysSchedule)
        .onError((error, stackTrace) {
      return false;
    });
    return true;
  }

  Future<Map<String, dynamic>> getDaySchedule(
      bool isDriver, String email) async {
    var collection = FirebaseFirestore.instance
        .collection(isDriver ? "drivers" : "students");
    var currentUserDocument =
        await collection.where("email", isEqualTo: email).get();
    return currentUserDocument.docs.first.data();
  }

  Future<List<Student>> getAllStudents() async {
    List<Student> students = [];
    var studentDocs =
        await FirebaseFirestore.instance.collection("students").get();
    studentDocs.docs.forEach((element) {
      Student newStudent = Student.fromJson(element.data());
      if (newStudent.latitude != "" && newStudent.longitude != "") {
        students.add(newStudent);
      }
    });
    return students;
  }

  Future<List<Driver>> getAllDrivers() async {
    List<Driver> drivers = [];
    var driverDocs =
        await FirebaseFirestore.instance.collection("drivers").get();
    driverDocs.docs.forEach((element) {
      Driver newDriver = Driver.fromJson(element.data());
      if (newDriver.latitude != "" && newDriver.longitude != "") {
        drivers.add(newDriver);
      }
    });
    return drivers;
  }

  Future<Driver> getDriver(String email) async {
    var driverDocs = await FirebaseFirestore.instance
        .collection("drivers")
        .where("email", isEqualTo: email)
        .get();
    Driver newDriver = Driver.fromJson(driverDocs.docs.first.data());
    return newDriver;
  }

  Future<Student> getStudent(String email) async {
    var studentDocs = await FirebaseFirestore.instance
        .collection("students")
        .where("email", isEqualTo: email)
        .get();
    Student newStudent = Student.fromJson(studentDocs.docs.first.data());
    return newStudent;
  }

  Future<bool> setLocation(
      bool isDriver, String email, String latitude, String longitude) async {
    var collection = FirebaseFirestore.instance
        .collection(isDriver ? "drivers" : "students");
    var userDoc = await collection.where("email", isEqualTo: email).get();
    await collection.doc(userDoc.docs.first.id).update({
      "latitude": latitude,
      "longitude": longitude,
    }).onError((error, stackTrace) {
      return false;
    });
    return true;
  }

  Future<bool> createBookingRequest(BookingRequest request) {
    return FirebaseFirestore.instance
        .collection("requests")
        .add(request.toJson())
        .then((value) => true)
        .catchError(
          (error) => false,
        );
  }

  Future<List<BookingRequest>> getStudentsBookingRequestsToday(
      String email, String date) async {
    List<BookingRequest> requests = [];
    var requestDocs = await FirebaseFirestore.instance
        .collection("requests")
        .where("studentEmail", isEqualTo: email)
        .where("date", isEqualTo: date)
        .where("status", isEqualTo: "PENDING")
        .get();
    requestDocs.docs.forEach((element) {
      requests.add(BookingRequest.fromJson(element.data()));
    });
    return requests;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getDriversBookingsStream(
      String email, String date) {
    var requestDocs = FirebaseFirestore.instance
        .collection("requests")
        .where("driverEmail", isEqualTo: email)
        .where("date", isEqualTo: date)
        .where("status", isEqualTo: "PENDING")
        .snapshots();

    return requestDocs;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getBooking(String id) {
    var bookingDocs =
        FirebaseFirestore.instance.collection("bookings").doc(id).snapshots();
    return bookingDocs;
  }

  Future<List<Booking>> hasTodayBookingStudent(String email) async {
    List<Booking> bookings = [];
    var requestDocs = await FirebaseFirestore.instance
        .collection("bookings")
        .where("date",
            isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .where("attenderEmails", arrayContains: email)
        .get();
    requestDocs.docs.forEach((element) {
      bookings.add(Booking.fromJson(element.data()));
    });
    return bookings;
  }

  Future<String> hasTodayBooking(String email) {
    return FirebaseFirestore.instance
        .collection("bookings")
        .where("date",
            isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .where("driverEmail", isEqualTo: email)
        .where(
          "status",
          whereNotIn: [
            "COMPLETED",
            "CANCELLED",
          ],
        )
        .get()
        .then((value) {
          if (value.docs.length > 0) {
            return value.docs.first.id;
          } else {
            return "none";
          }
        });
  }

  Future<bool> hasCompletedBooking(String email) {
    return FirebaseFirestore.instance
        .collection("bookings")
        .where("date",
            isEqualTo: DateFormat("yyyy-MM-dd").format(DateTime.now()))
        .where("driverEmail", isEqualTo: email)
        .where(
          "status",
          isEqualTo: "COMPLETED",
        )
        .get()
        .then((value) {
      if (value.docs.length == 1) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> addAttender(String bookingID, Attender newAtt) {
    return FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingID)
        .update({
          "attenders": FieldValue.arrayUnion(
            [
              newAtt.toJson(),
            ],
          ),
          "attenderEmails": FieldValue.arrayUnion([
            newAtt.email,
          ]),
        })
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> updateBookingStatus(String bookingID, String status) {
    return FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingID)
        .update({"status": status})
        .then((value) => true)
        .catchError((error) => false);
  }
}
