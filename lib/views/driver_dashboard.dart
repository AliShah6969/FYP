import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabist_carpool/config/constants.dart';
import 'package:szabist_carpool/controllers/database_controller.dart';
import 'package:szabist_carpool/models/booking.dart';
import 'package:szabist_carpool/models/request.dart';
import 'package:szabist_carpool/models/student.dart';
import 'package:szabist_carpool/views/driver_booking.dart';
import 'package:szabist_carpool/views/edit_schedule.dart';
import 'package:szabist_carpool/views/login.dart';

import '../models/driver.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({Key? key}) : super(key: key);

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  DatabaseController databaseController = DatabaseController();

  List<Student> students = [];

  Driver? currentDriver;

  String driverEmail = "...";

  String formattedPickup = "Fetching Location...";
  double driverLat = 0.0;
  double driverLon = 0.0;

  bool isLoading = false;

  bool hasCompletedBooking = false;

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  createBooking() {
    setState(() {
      isLoading = true;
    });
    String bookingID = DateTime.now().millisecondsSinceEpoch.toString();
    var collectionDoc =
        FirebaseFirestore.instance.collection('bookings').doc(bookingID);
    Booking booking = Booking(
      id: bookingID,
      date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
      driverEmail: driverEmail,
      driverName: currentDriver!.name,
      driverPhone: currentDriver!.mobile,
      seatsAvailable: currentDriver!.vehicleCapacity,
      attenders: [],
      driverAddress: formattedPickup,
      driverLat: driverLat,
      driverLon: driverLon,
      attenderEmails: [],
      status: "AWAITING",
    );
    collectionDoc.set(booking.toJson()).then((value) {
      Fluttertoast.showToast(
        msg: "Booking created successfully",
      );
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) => DriverBookingScreen(
            bookingID: bookingID,
          ),
        ),
        (route) => false,
      );
    }).onError(
      (error, stackTrace) {
        print(error);
        Fluttertoast.showToast(
          msg:
              "Couldn't create your booking, please contact admin if this issue persists",
        );
      },
    );
  }

  String classMessage() {
    String dayToday = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    if (currentDriver!.toJson()[dayToday] != "") {
      return "You have a class today at " +
          currentDriver!.toJson()[dayToday] +
          "";
    }
    return "You don't have any class today";
  }

  getPageData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      driverEmail = preferences.getString("email")!;
    });
    getCompletedBooking();
  }

  getCompletedBooking() async {
    bool _hasCompletedBooking = await databaseController.hasCompletedBooking(
      driverEmail,
    );
    setState(() {
      hasCompletedBooking = _hasCompletedBooking;
    });
    getActiveBooking();
  }

  getActiveBooking() async {
    String bookingToday = await databaseController.hasTodayBooking(driverEmail);
    if (bookingToday != "none") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverBookingScreen(
            bookingID: bookingToday,
          ),
        ),
      );
    } else {
      getDriverData();
      getCurrentLocation();
    }
  }

  getDriverData() async {
    Driver driver = await databaseController.getDriver(driverEmail);
    setState(() {
      currentDriver = driver;
    });
  }

  Future<LatLng> convertAddressToCoords(String address) async {
    var responsePick = await http.get(
      Uri.parse(
        "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&address=" +
            address,
      ),
    );
    var jsonResponsePick = json.decode(responsePick.body);
    print(jsonResponsePick);
    String _lat = jsonResponsePick['results'][0]['geometry']['location']['lat']
        .toString();
    String _lng = jsonResponsePick['results'][0]['geometry']['location']['lng']
        .toString();
    return LatLng(
      double.parse(
        _lat,
      ),
      double.parse(
        _lng,
      ),
    );
  }

  Future<String> convertCoordsToAddress(String latLng) async {
    var responseAddress = await http.get(
      Uri.parse(
        googleReverseGeometryAPI + latLng,
      ),
    );
    var jsonResponseAddress = json.decode(responseAddress.body);
    print(jsonResponseAddress['results'][0]['formatted_address']);
    String currentLocation =
        jsonResponseAddress['results'][0]['formatted_address'];
    return currentLocation;
  }

  getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    String _formattedPickupAddress = await convertCoordsToAddress(
      _locationData.latitude.toString() +
          "," +
          _locationData.longitude.toString(),
    );
    SharedPreferences preferences = await SharedPreferences.getInstance();
    DatabaseController databaseController = new DatabaseController();
    print(preferences.getString("email")!);
    await databaseController.setLocation(
      preferences.getBool("isDriver")!,
      preferences.getString("email")!,
      _locationData.latitude.toString(),
      _locationData.longitude.toString(),
    );

    setState(
      () {
        formattedPickup = _formattedPickupAddress;
        driverLat = _locationData.latitude!;
        driverLon = _locationData.longitude!;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  preferences.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Login(),
                    ),
                    (route) => false,
                  );
                },
                icon: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Row(
                children: [
                  Spacer(),
                  Text(
                    "Driver Panel",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditSchedule(
                            isDriver: true,
                            userEmail: driverEmail,
                          ),
                        ),
                      );
                    },
                    child: Wrap(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.teal,
                          size: 15,
                        ),
                        Text(
                          "Schedule",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: currentDriver == null
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal,
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Welcome, ${currentDriver!.name}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.location_pin,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    formattedPickup,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (!hasCompletedBooking)
                        Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              classMessage(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      if (hasCompletedBooking)
                        Text("You have completed a booking today"),
                      if (!hasCompletedBooking)
                        GestureDetector(
                          onTap: () {
                            createBooking();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Create Booking",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          );
  }
}
