import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabist_carpool/firebase_options.dart';
import 'package:szabist_carpool/views/driver_dashboard.dart';
import 'package:szabist_carpool/views/login.dart';
import 'package:szabist_carpool/views/student_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(
    MyApp(
      homeScreen: preferences.getString("email") == null
          ? Login()
          : preferences.getBool("isDriver")!
              ? DriverDashboard()
              : StudentDashboard(),
    ),
  );
}

class MyApp extends StatelessWidget {
  Widget? homeScreen;

  MyApp({required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: homeScreen,
    );
  }
}
