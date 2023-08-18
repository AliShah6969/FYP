import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabist_carpool/controllers/database_controller.dart';
import 'package:szabist_carpool/models/attenders.dart';
import 'package:szabist_carpool/models/booking.dart';
import 'package:szabist_carpool/views/chat_screen.dart';
import 'package:szabist_carpool/views/report_screen.dart';
import 'package:szabist_carpool/views/student_dashboard.dart';

class StudentBookingScreen extends StatefulWidget {
  final bookingID;

  const StudentBookingScreen({Key? key, required this.bookingID})
      : super(key: key);

  @override
  State<StudentBookingScreen> createState() => _StudentBookingScreenState();
}

class _StudentBookingScreenState extends State<StudentBookingScreen> {
  DatabaseController databaseController = DatabaseController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
              : WillPopScope(
                  onWillPop: () async {
                    if (thisBooking!.status == "COMPLETED") {
                      Fluttertoast.showToast(
                          msg:
                              "You can't leave this screen during an active booking.");
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDashboard(),
                        ),
                        (route) => false,
                      );
                    }
                    return false;
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                        "Booking #${widget.bookingID}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      automaticallyImplyLeading: false,
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
                      leading: thisBooking!.status == "COMPLETED"
                          ? IconButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentDashboard(),
                                  ),
                                  (route) => false,
                                );
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            )
                          : null,
                      elevation: 0,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Fellow Attenders",
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
                  ),
                );
        });
  }
}
