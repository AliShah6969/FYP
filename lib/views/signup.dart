import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:szabist_carpool/models/driver.dart';
import 'package:szabist_carpool/models/student.dart';
import 'package:szabist_carpool/views/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController studentIDController = TextEditingController();
  TextEditingController admissionYearController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController vehModelController = TextEditingController();
  TextEditingController vehNumberController = TextEditingController();

  bool isLoading = false;

  bool isDriver = false;

  int? selectedVehicleCapacity;

  List<int> vehicleCapacity = [1, 2, 3, 4];

  final _formKey = GlobalKey<FormState>();

  selectSeatsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            // physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: vehicleCapacity.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVehicleCapacity = vehicleCapacity[index];
                  });
                  Navigator.pop(context);
                },
                child: ListTile(
                  title: Text(
                    vehicleCapacity[index].toString() + " Seats",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
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
      Student student = Student(
        email: emailController.text,
        password: passwordController.text,
        mobile: mobileController.text,
        studentID: studentIDController.text,
        admissionYear: admissionYearController.text,
        dob: dobController.text,
        name: nameController.text,
        monday: '',
        tuesday: '',
        wednesday: '',
        thursday: '',
        friday: '',
        saturday: '',
        sunday: '',
        latitude: _locationData.latitude.toString(),
        longitude: _locationData.longitude.toString(),
      );
      final docStudent = FirebaseFirestore.instance
          .collection('students')
          .doc(emailController.text);
      await docStudent.set(student.toJson()).onError((error, stackTrace) {
        Fluttertoast.showToast(
            msg: "There is something wrong, please try again later!");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Login(),
          ),
        );
      });
      Fluttertoast.showToast(msg: "Account registered! Please log in now!");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Login(),
        ),
      );
    }
  }

  signupAsDriver() async {
    if (_formKey.currentState!.validate()) {
      if (selectedVehicleCapacity != null) {
        setState(() {
          isLoading = true;
        });
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
        Driver student = Driver(
          email: emailController.text,
          password: passwordController.text,
          mobile: mobileController.text,
          studentID: studentIDController.text,
          admissionYear: admissionYearController.text,
          dob: dobController.text,
          name: nameController.text,
          vehicleModel: vehModelController.text,
          vehicleNumber: vehNumberController.text,
          vehicleCapacity: selectedVehicleCapacity!,
          monday: '',
          tuesday: '',
          wednesday: '',
          thursday: '',
          friday: '',
          saturday: '',
          sunday: '',
          latitude: _locationData.latitude.toString(),
          longitude: _locationData.longitude.toString(),
        );
        final docStudent = FirebaseFirestore.instance
            .collection('drivers')
            .doc(emailController.text);
        await docStudent.set(student.toJson()).onError((error, stackTrace) {
          Fluttertoast.showToast(
              msg: "There is something wrong, please try again later!");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Login(),
            ),
          );
        });
        Fluttertoast.showToast(msg: "Account registered! Please log in now!");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Login(),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Please select vehicle capacity!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.teal,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),

              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Carpool User Signup",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value!.length < 3) {
                      return "Please enter atleast 3 characters";
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
                    hintText: "eg: Ali",
                    labelText: "Full Name",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
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
                  ),
                ),
              ),
              // SizedBox(
              //   height: 40,
              // ),
              Padding(
                padding: const EdgeInsets.all(10.0),
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: mobileController,
                  validator: (value) {
                    if (value!.length != 11) {
                      return "Please enter 11 digits starting with 0 eg: 0321*******";
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
                    hintText: "0321XXXXXXX",
                    labelText: "Mobile Number",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: studentIDController,
                  validator: (value) {
                    if (value!.length != 7) {
                      return "Please enter atleast 7 characters";
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
                    hintText: "XXXXXXXXXXX",
                    labelText: "SZABIST Student ID",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: admissionYearController,
                  validator: (value) {
                    if (value!.length != 4) {
                      return "Please enter a correct year";
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
                    hintText: "2020",
                    labelText: "SZABIST Admission Year",
                    alignLabelWithHint: true,
                    // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: dobController,
                  validator: (value) {
                    if (value!.length != 10) {
                      return "Please enter a valid date";
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
                    hintText: "12/04/2000",
                    labelText: "Date of Birth",
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
              if (isDriver)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: vehModelController,
                    validator: (value) {
                      if (value!.length < 3) {
                        return "Please enter a valid vehicle model";
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
                      hintText: "Suzuki Alto",
                      labelText: "Vehicle Model",
                      alignLabelWithHint: true,
                      // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                    ),
                  ),
                ),
              if (isDriver)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: vehNumberController,
                    validator: (value) {
                      if (value!.length < 5) {
                        return "Please enter a valid vehicle number";
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
                      hintText: "ake628",
                      labelText: "Vehicle Number Plate",
                      alignLabelWithHint: true,
                      // hintStyle: TextStyle(color: AppColors.primaryColorLight),
                    ),
                  ),
                ),
              if (isDriver) SizedBox(height: 15),
              if (isDriver)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      "Select Capacity",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isDriver)
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {
                            selectSeatsMenu(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                50,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                selectedVehicleCapacity == null
                                    ? "Select available seats daily."
                                    : selectedVehicleCapacity!.toString() +
                                        " Seats",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                                size: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(
                height: 10,
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.teal,
                  ),
                ),
              if (!isLoading)
                InkWell(
                  onTap: () {
                    isDriver ? signupAsDriver() : signup();
                  },
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
                            "Sign Up",
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
            ],
          ),
        ),
      ),
    );
  }
}
