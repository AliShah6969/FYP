class Attender {
  String name;
  String email;
  double fare;
  String status;
  String pickupAddress;
  double pickupLat;
  double pickupLon;

  Attender({
    required this.name,
    required this.email,
    required this.fare,
    required this.status,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLon,
  });

  factory Attender.fromJson(Map<String, dynamic> json) {
    return Attender(
      name: json['name'],
      email: json['email'],
      fare: json['fare'],
      status: json['status'],
      pickupAddress: json['pickupAddress'],
      pickupLat: json['pickupLat'],
      pickupLon: json['pickupLon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'fare': fare,
      'status': status,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLon': pickupLon,
    };
  }
}
