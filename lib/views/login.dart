import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabist_carpool/views/driver_dashboard.dart';
import 'package:szabist_carpool/views/signup.dart';
import 'package:szabist_carpool/views/student_dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isDriver = false;

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  login() async {
    if (_formKey.currentState!.validate()) {
      var collection = FirebaseFirestore.instance
          .collection(isDriver ? 'drivers' : 'students');
      var docSnapshot = await collection
          .where("email", isEqualTo: emailController.text)
          .limit(1)
          .get();
      if (docSnapshot.size == 1) {
        if (docSnapshot.docs.first.data()['password'] ==
            passwordController.text) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString("email", emailController.text);
          preferences.setBool("isDriver", isDriver);
          preferences.setString("name", docSnapshot.docs.first.data()['name']);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => isDriver ? DriverDashboard() : StudentDashboard(),
            ),
            (route) => false,
          );
          Fluttertoast.showToast(msg: "Logged in... Navigating to home!");
        } else {
          Fluttertoast.showToast(msg: "Invalid password!");
        }
      } else {
        Fluttertoast.showToast(msg: "Invalid user!");
      }
    }
  }

  testDriver() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("email", "alikarim@szabist.pk");
    preferences.setBool("isDriver", true);
    preferences.setString("name", "Ali Mohammad Karim");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DriverDashboard(),
      ),
      (route) => false,
    );
  }

  testStudent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("email", "cs1912176@szabist.pk");
    preferences.setBool("isDriver", false);
    preferences.setString("name", "Alishah Bachlani");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDashboard(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: GestureDetector(
                  onTap: testDriver,
                  child: Image.asset(
                    "images/login.png",
                    height: 200,
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Center(
                child: GestureDetector(
                  onTap: testStudent,
                  child: Text(
                    "Szabist Carpool",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: emailController,
                  validator: (value) {
                    if (!value!.contains(
                      "@szabist.pk",
                    )) {
                      return "Please enter a valid student email";
                    }
                    if (value.length < 12) {
                      return "Please enter a valid student email";
                    }
                  },
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2.0),
                    ),
                    hintText: "Enter SZABIST email address",
                    labelText: "Email",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              // SizedBox(
              //   height: 40,
              // ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: TextFormField(
                  controller: passwordController,
                  validator: (value) {
                    if (value!.length < 6) {
                      return "Please enter atleast 6 characters";
                    }
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.teal, width: 2.0),
                    ),
                    hintText: "Enter account password",
                    labelText: "Password",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    checkColor: Colors.white,
                    value: isDriver,
                    shape: CircleBorder(),
                    onChanged: (bool? value) {
                      setState(() {
                        isDriver = value!;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDriver = !isDriver;
                      });
                    },
                    child: Text(
                      "Are you a driver?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: login,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
