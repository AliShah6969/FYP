import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  String bookingID;
  String attenderEmail;
  String attenderName;

  ReportScreen({
    required this.bookingID,
    required this.attenderEmail,
    required this.attenderName,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController reporteeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report Behaviour",
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                ),
                Text(
                  "If you have spotted or suffered an ethical misconduct from a passenger or driver student, or if you want to report an unusual app behaviour, please fill the form below. ",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.teal,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Report Form",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    labelText: "Enter Reportee",
                  ),
                  controller: reporteeController,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "If you are reporting a student, please mention their names or emails (comma separated if more than 1). Leave empty if you are reporting an app bug.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    labelText: "Describe misbehaviour",
                    hintText:
                        "Please enter a detailed description of the situation",
                  ),
                  validator: (value) {
                    if (value!.length < 10) {
                      return "Please enter atleast 10 characters";
                    }
                  },
                  maxLines: 5,
                  maxLength: 500,
                  controller: descriptionController,
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    bool isValid = formKey.currentState!.validate();
                    if (isValid) {
                      String subject = "";
                      String body = descriptionController.text;
                      if (reporteeController.text.trim() == "") {
                        subject = "Bug Report - by ${widget.attenderName}";
                      } else {
                        subject =
                            "Misconduct Report - by ${widget.attenderName}";
                        body =
                            "I am reporting ${reporteeController.text}. Description below: " +
                                descriptionController.text;
                      }

                      launch(
                        "mailto:complaints@szabistcarpool.pk?subject=$subject&body=$body",
                      );
                    }
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
                            "Send Report",
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
          ),
        ),
      ),
    );
  }
}
