import 'package:google_maps_flutter/google_maps_flutter.dart';

String googleSearchAPI =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?sessionroken=123456&components=country:in&key=$googleAPIKey&input=";

String googleGeometryAPI =
    "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&address=";

String googleReverseGeometryAPI =
    "https://maps.googleapis.com/maps/api/geocode/json?key=$googleAPIKey&latlng=";

// static const String googleAPIKey = "AIzaSyAjCz6Q4eB-pQGK7toCsfps8PrqAmgSQK8";
String googleAPIKey = "AIzaSyAjCz6Q4eB-pQGK7toCsfps8PrqAmgSQK8";

double perKmFare = 30.0;

LatLng szabistCoords = LatLng(24.819902, 67.030435);
