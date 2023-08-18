import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
import 'package:szabist_carpool/views/edit_schedule.dart';
import 'package:szabist_carpool/views/login.dart';
import 'package:szabist_carpool/views/student_booking.dart';

import '../models/driver.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  Completer<GoogleMapController> _controller = Completer();

  DatabaseController databaseController = DatabaseController();

  List<Driver> drivers = [];
  List<String> driversBookedEmails = [];

  String studentEmail = "...";
  Student? currentStudent;

  String formattedPickup = "Fetching Location...";

  CameraPosition position = CameraPosition(
    target: LatLng(24.8818, 67.0268),
    zoom: 14,
  );

  static final CameraPosition _karachi = CameraPosition(
    target: LatLng(24.8818, 67.0268),
    zoom: 14,
  );

  bookNow(String driverEmail) async {
    Student student = currentStudent!;
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    BookingRequest request = BookingRequest(
      student: student,
      pickupAddress: formattedPickup,
      pickupLat: position.target.latitude,
      pickupLon: position.target.longitude,
      status: "PENDING",
      studentEmail: student.email,
      driverEmail: driverEmail,
      date: date,
    );
    bool booked = await databaseController.createBookingRequest(request);
    if (booked) {
      Fluttertoast.showToast(
        msg: "Booking Request Sent",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        drivers.removeWhere((element) => element.email == driverEmail);
      });
    } else {
      Fluttertoast.showToast(
        msg: "Booking Request Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void initState() {
    super.initState();
    getPageData();
  }

  getTodaysRequests() {
    List<String> _bookedDrivers = [];
    databaseController
        .getStudentsBookingRequestsToday(
      studentEmail,
      DateFormat("yyyy-MM-dd").format(DateTime.now()),
    )
        .then((value) {
      value.forEach((element) {
        _bookedDrivers.add(element.driverEmail);
      });
      setState(() {
        driversBookedEmails = _bookedDrivers;
      });
    });
  }

  getPageData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      studentEmail = preferences.getString("email")!;
    });
    checkActiveBooking();
  }

  checkActiveBooking() async {
    List<Booking> activeBookings =
        await databaseController.hasTodayBookingStudent(studentEmail);
    print("FOUND BOOKINGS");
    print(activeBookings.length);
    if (activeBookings.length > 0) {
      activeBookings.forEach((element) {
        if (element.status == "AWAITING" ||
            element.status == "STARTED" ||
            element.status.startsWith("PICKED")) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentBookingScreen(
                bookingID: element.id,
              ),
            ),
          );
        }
      });
    } else {
      getStudentData();
      getCurrentLocation();
    }
  }

  getStudentData() async {
    print("getting $studentEmail");
    Student student = await databaseController.getStudent(studentEmail);
    setState(() {
      currentStudent = student;
    });

    getCurrentLocation();
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
      },
    );

    final CameraPosition _currentLocation = CameraPosition(
      target: LatLng(_locationData.latitude!, _locationData.longitude!),
      zoom: 15,
    );
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        _currentLocation,
      ),
    );
    Future.delayed(
      Duration(
        seconds: 1,
      ),
      () {
        loadAllDrivers();
        setState(
          () {
            controller.showMarkerInfoWindow(
              MarkerId(
                "currentLocation",
              ),
            );
          },
        );
      },
    );
  }

  loadAllDrivers() async {
    List<Driver> allDrivers = await databaseController.getAllDrivers();
    setState(() {
      drivers = [];
    });
    allDrivers.forEach((element) {
      print(element.name);
      double distanceBetween = calculateDistance(
        position.target.latitude,
        position.target.longitude,
        double.parse(
          element.latitude.toString(),
        ),
        double.parse(
          element.longitude.toString(),
        ),
      );
      if (distanceBetween < 1.0) {
        String dayToday =
            DateFormat('EEEE').format(DateTime.now()).toLowerCase();
        if (element.toJson()[dayToday] != "") {
          drivers.add(element);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
              "Student Panel",
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
                      isDriver: false,
                      userEmail: studentEmail,
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
      body: currentStudent == null
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Positioned(
                        child: GoogleMap(
                          initialCameraPosition: _karachi,
                          onMapCreated: (GoogleMapController controller) async {
                            _controller.complete(controller);
                          },
                          onCameraMove: (_position) async {
                            setState(() {
                              formattedPickup = "Fetching Location...";
                            });
                            setState(() {
                              position = _position;
                            });
                          },
                          onCameraIdle: () async {
                            print("CAMERA HAS STOPPED MOVINGGGGG");
                            String _formattedPickupAddress =
                                await convertCoordsToAddress(
                              position.target.latitude.toString() +
                                  "," +
                                  position.target.longitude.toString(),
                            );
                            setState(() {
                              formattedPickup = _formattedPickupAddress;
                            });
                            loadAllDrivers();
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (formattedPickup != "Fetching Location...")
                              GestureDetector(
                                onTap: () async {},
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                      color: Colors.teal,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        formattedPickup,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                "images/pin.png",
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
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
                                "Welcome, ${currentStudent!.name}",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  getCurrentLocation();
                                },
                                child: Icon(
                                  Icons.location_searching,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (formattedPickup != "Fetching Location...")
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: drivers.length,
                              itemBuilder: (context, index) {
                                String dayToday = DateFormat('EEEE')
                                    .format(DateTime.now())
                                    .toLowerCase();
                                Map<String, dynamic> driverJson =
                                    drivers[index].toJson();
                                String leavesAt = driverJson[dayToday];
                                print(driverJson);
                                print(dayToday);
                                print(leavesAt);
                                return Visibility(
                                  visible: driversBookedEmails
                                          .contains(drivers[index].email)
                                      ? false
                                      : true,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final CameraPosition _currentLocation =
                                          CameraPosition(
                                        target: LatLng(
                                          double.parse(drivers[index].latitude),
                                          double.parse(
                                            drivers[index].longitude,
                                          ),
                                        ),
                                        zoom: 15,
                                      );
                                      final GoogleMapController controller =
                                          await _controller.future;

                                      controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          _currentLocation,
                                        ),
                                      );
                                      Future.delayed(
                                        Duration(
                                          seconds: 1,
                                        ),
                                        () {
                                          setState(
                                            () {
                                              controller.showMarkerInfoWindow(
                                                MarkerId(
                                                  "currentLocation",
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.location_searching,
                                        color: Colors.teal,
                                      ),
                                      title: Text(drivers[index].name),
                                      subtitle: Text(
                                        "Leaves at: " + leavesAt,
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text("Book Driver"),
                                                content: Text(
                                                  "Are you sure you want to book a seat with this driver? Your selected location on map will be set as pickup point.",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Cancel",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      bookNow(
                                                        drivers[index].email,
                                                      );
                                                    },
                                                    child: Text("Book"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Book Now",
                                            style: TextStyle(
                                              color: Colors.teal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
