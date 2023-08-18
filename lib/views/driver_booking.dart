import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabist_carpool/config/constants.dart';
import 'package:szabist_carpool/controllers/database_controller.dart';
import 'package:szabist_carpool/models/attenders.dart';
import 'package:szabist_carpool/models/booking.dart';
import 'package:szabist_carpool/models/request.dart';
import 'package:szabist_carpool/views/chat_screen.dart';
import 'package:szabist_carpool/views/report_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverBookingScreen extends StatefulWidget {
  final bookingID;

  const DriverBookingScreen({Key? key, required this.bookingID})
      : super(key: key);

  @override
  State<DriverBookingScreen> createState() => _DriverBookingScreenState();
}

class _DriverBookingScreenState extends State<DriverBookingScreen> {
  DatabaseController databaseController = DatabaseController();

  acceptUser(BookingRequest req, String reqID) {
    FirebaseFirestore.instance.collection("requests").doc(reqID).delete();
    Attender newAtt = Attender(
      name: req.student.name,
      email: req.studentEmail,
      fare: calculateFare(req),
      status: "Accepted",
      pickupAddress: req.pickupAddress,
      pickupLat: req.pickupLat,
      pickupLon: req.pickupLon,
    );
    databaseController.addAttender(widget.bookingID, newAtt);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  double calculateFare(BookingRequest _req) {
    double _fare = 0;
    _fare = perKmFare *
        calculateDistance(
          _req.pickupLat,
          _req.pickupLon,
          szabistCoords.latitude,
          szabistCoords.longitude,
        );
    return _fare.ceilToDouble();
  }

  renderBottomActionButton() {
    return StreamBuilder(
      stream: databaseController.getBooking(widget.bookingID),
      builder: (context, snapshot) {
        Booking? thisBooking;
        if (snapshot.hasData) {
          thisBooking = Booking.fromJson(snapshot.data!.data()!);
        }

        if (thisBooking!.status == "AWAITING") {
          return Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (thisBooking!.attenders.length > 0) {
                  databaseController.updateBookingStatus(
                      widget.bookingID, "STARTED");
                } else {
                  Fluttertoast.showToast(
                    msg: "Please accept an attender first.",
                  );
                }
              },
              child: Text("Start Booking"),
            ),
          );
        } else if (thisBooking.status == "STARTED") {
          return Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                databaseController.updateBookingStatus(
                    widget.bookingID, "PICKED #1");
              },
              child: Text("Pick Attender #1"),
            ),
          );
        } else if (thisBooking.status.startsWith("PICKED")) {
          int alreadyPicked = int.parse(thisBooking.status.split("#").last);
          if (alreadyPicked == thisBooking.attenders.length) {
            return Container(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  databaseController.updateBookingStatus(
                      widget.bookingID, "COMPLETED");
                },
                child: Text("Complete Booking"),
              ),
            );
          }
          return Container(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                databaseController.updateBookingStatus(widget.bookingID,
                    "PICKED #" + (alreadyPicked + 1).toString());
              },
              child: Text("Pick Attender #" + (alreadyPicked + 1).toString()),
            ),
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Fluttertoast.showToast(
            msg: "You can't leave this screen during an active booking.");
        return false;
      },
      child: StreamBuilder(
          stream: databaseController.getBooking(widget.bookingID),
          builder: (context, snapshot) {
            Booking? thisBooking;
            if (snapshot.hasData) {
              thisBooking = Booking.fromJson(snapshot.data!.data()!);
            }
            return !snapshot.hasData
                ? Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Scaffold(
                    bottomNavigationBar: renderBottomActionButton(),
                    appBar: AppBar(
                      title: Text(
                        "Booking #${widget.bookingID}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      actions: [
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String attenderName = prefs.getString("name")!;
                            String attenderEmail = prefs.getString("email")!;
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => ReportScreen(
                                  bookingID: widget.bookingID,
                                  attenderEmail: attenderEmail,
                                  attenderName: attenderName,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.flag,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String attenderName = prefs.getString("name")!;
                            String attenderEmail = prefs.getString("email")!;
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => ChatScreen(
                                  bookingID: widget.bookingID,
                                  attenderEmail: attenderEmail,
                                  attenderName: attenderName,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Status: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    thisBooking!.status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              if (thisBooking.status == "AWAITING")
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Student Requests",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "You have ${(thisBooking.seatsAvailable) - (thisBooking.attenders.length)} seats available.",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              if (thisBooking.status == "AWAITING")
                                StreamBuilder(
                                  stream: databaseController
                                      .getDriversBookingsStream(
                                    thisBooking.driverEmail,
                                    DateFormat("yyyy-MM-dd")
                                        .format(DateTime.now()),
                                  ),
                                  builder: (context, snapshot) {
                                    return !snapshot.hasData
                                        ? CircularProgressIndicator()
                                        : snapshot.data!.docs.length < 1
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.book,
                                                    size: 100,
                                                    color: Colors.teal,
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      "No new requests yet.",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    snapshot.data!.docs.length,
                                                itemBuilder: (context, index) {
                                                  BookingRequest _req =
                                                      BookingRequest.fromJson(
                                                    snapshot.data!.docs[index]
                                                        .data(),
                                                  );
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Card(
                                                      elevation: 5,
                                                      child: Column(
                                                        children: [
                                                          ListTile(
                                                            title: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                _req.student
                                                                    .name,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                            subtitle: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                _req.pickupAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "requests")
                                                                        .doc(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id)
                                                                        .delete();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .red,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          12.0),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "DENY",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    acceptUser(
                                                                      _req,
                                                                      snapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                          .id,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    color: Colors
                                                                        .green,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          12.0),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "ACCEPT",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                  },
                                ),
                              if (thisBooking.status == "AWAITING")
                                SizedBox(
                                  height: 20,
                                ),
                              if (thisBooking.status == "AWAITING")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Divider(
                                    thickness: 2,
                                    color: Colors.teal,
                                  ),
                                ),
                              if (thisBooking.status == "AWAITING")
                                SizedBox(
                                  height: 20,
                                ),
                              if (thisBooking.status != "AWAITING" &&
                                  thisBooking.status != "COMPLETED")
                                ListTile(
                                  onTap: () {
                                    String url =
                                        "https://www.google.com/maps/dir/";
                                    url = url +
                                        thisBooking!.driverLat.toString() +
                                        "," +
                                        thisBooking!.driverLon.toString() +
                                        "/";
                                    thisBooking.attenders.forEach((element) {
                                      url = url +
                                          element["pickupLat"].toString() +
                                          "," +
                                          element["pickupLon"].toString() +
                                          "/";
                                    });
                                    url = url +
                                        szabistCoords.latitude.toString() +
                                        "," +
                                        szabistCoords.longitude.toString() +
                                        "/";
                                    print(url);
                                    launch(url);
                                  },
                                  title: Text(
                                    "Route",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Click to see your route in google maps",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.map,
                                    color: Colors.teal,
                                  ),
                                ),
                              Text(
                                "Accepted Attenders",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: thisBooking.attenders.length,
                                itemBuilder: (context, index) {
                                  Attender thisAttender = Attender.fromJson(
                                    thisBooking!.attenders[index],
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      elevation: 5,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            title: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    thisAttender.name,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    "Rs. ${thisAttender.fare.ceil()}",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                thisAttender.pickupAddress,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          }),
    );
  }
}
