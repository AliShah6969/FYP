class Driver {
  String name;
  String email;
  String password;
  String mobile;
  String dob;
  String admissionYear;
  String studentID;
  String vehicleModel;
  String vehicleNumber;
  int vehicleCapacity;
  String monday;
  String tuesday;
  String wednesday;
  String thursday;
  String friday;
  String saturday;
  String sunday;
  String latitude;
  String longitude;

  Driver({
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    required this.dob,
    required this.admissionYear,
    required this.studentID,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.vehicleCapacity,
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

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      name: json['name'],
      email: json['email'],
      password: json['password'],
      mobile: json['mobile'],
      dob: json['dob'],
      admissionYear: json['admissionYear'],
      studentID: json['studentID'],
      vehicleModel: json['vehicleModel'],
      vehicleNumber: json['vehicleNumber'],
      vehicleCapacity: json['vehicleCapacity'],
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
      "vehicleModel": vehicleModel,
      "vehicleNumber": vehicleNumber,
      "vehicleCapacity": vehicleCapacity,
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
