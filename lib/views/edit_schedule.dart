import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:szabist_carpool/controllers/database_controller.dart';
import 'package:szabist_carpool/views/driver_dashboard.dart';
import 'package:szabist_carpool/views/student_dashboard.dart';

class EditSchedule extends StatefulWidget {
  bool isDriver;
  String userEmail;

  EditSchedule({
    required this.isDriver,
    required this.userEmail,
  });

  @override
  State<EditSchedule> createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  String monday = "";
  String tuesday = "";
  String wednesday = "";
  String thursday = "";
  String friday = "";
  String saturday = "";
  String sunday = "";

  bool isLoading = false;

  DatabaseController databaseController = DatabaseController();

  @override
  void initState() {
    super.initState();
    getUserSchedule();
  }

  TimeOfDay convertStringToTime(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  getUserSchedule() async {
    Map<String, dynamic> json = await databaseController.getDaySchedule(
      widget.isDriver,
      widget.userEmail,
    );
    setState(() {
      monday = json['monday'];
      tuesday = json['tuesday'];
      wednesday = json['wednesday'];
      thursday = json['thursday'];
      friday = json['friday'];
      saturday = json['saturday'];
      sunday = json['sunday'];
    });
  }

  updateUserSchedule() async {
    setState(() {
      isLoading = true;
    });
    bool hasUpdated = await databaseController
        .setDaySchedule(widget.isDriver, widget.userEmail, {
      "monday": monday,
      "tuesday": tuesday,
      "wednesday": wednesday,
      "thursday": thursday,
      "friday": friday,
      "saturday": saturday,
      "sunday": sunday,
    });

    if (hasUpdated) {
      Fluttertoast.showToast(
          msg: "Schedule successfully updated. Manage your rides now!");
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) =>
              widget.isDriver ? DriverDashboard() : StudentDashboard(),
        ),
        (route) => false,
      );
    } else {
      Fluttertoast.showToast(
          msg:
              "There was a problem updating your schedule. Please try again later.");
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) =>
              widget.isDriver ? DriverDashboard() : StudentDashboard(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.teal,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Edit Schedule",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                monday == "" ? "No Class" : monday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Monday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: monday != ""
                        ? convertStringToTime(monday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    monday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                tuesday == "" ? "No Class" : tuesday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Tuesday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: tuesday != ""
                        ? convertStringToTime(tuesday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    tuesday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                wednesday == "" ? "No Class" : wednesday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Wednesday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: wednesday != ""
                        ? convertStringToTime(wednesday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    wednesday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                thursday == "" ? "No Class" : thursday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Thursday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: thursday != ""
                        ? convertStringToTime(thursday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    thursday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                friday == "" ? "No Class" : friday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Friday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: friday != ""
                        ? convertStringToTime(friday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    friday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                saturday == "" ? "No Class" : saturday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Saturday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: saturday != ""
                        ? convertStringToTime(saturday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    saturday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            ListTile(
              title: Text(
                sunday == "" ? "No Class" : sunday,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              subtitle: Text(
                "Sunday",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () async {
                  TimeOfDay? timePicked = await showTimePicker(
                    initialEntryMode: TimePickerEntryMode.input,
                    context: context,
                    initialTime: sunday != ""
                        ? convertStringToTime(sunday)
                        : TimeOfDay(
                            hour: 00,
                            minute: 00,
                          ),
                  );
                  setState(() {
                    sunday = timePicked!.format(context);
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: Colors.teal,
                  size: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: updateUserSchedule,
        child: Container(
          color: Colors.teal,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: isLoading
                ? Center(
                    child: Container(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  )
                : Text(
                    "Save Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}
