class Student {
  String name;
  String email;
  String password;
  String mobile;
  String dob;
  String admissionYear;
  String studentID;
  String monday;
  String tuesday;
  String wednesday;
  String thursday;
  String friday;
  String saturday;
  String sunday;
  String latitude;
  String longitude;

  Student({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    required this.dob,
    required this.admissionYear,
    required this.studentID,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.latitude,
    required this.longitude,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      mobile: json['mobile'],
      dob: json['dob'],
      admissionYear: json['admissionYear'],
      studentID: json['studentID'],
      monday: json['monday'],
      tuesday: json['tuesday'],
      wednesday: json['wednesday'],
      thursday: json['thursday'],
      friday: json['friday'],
      saturday: json['saturday'],
      sunday: json['sunday'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "mobile": mobile,
      "dob": dob,
      "admissionYear": admissionYear,
      "studentID": studentID,
      "monday": monday,
      "tuesday": tuesday,
      "wednesday": wednesday,
      "thursday": thursday,
      "friday": friday,
      "saturday": saturday,
      "sunday": sunday,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
