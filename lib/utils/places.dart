import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Placemark?> getPlaceFromLocation(LatLng? location) async {
  if (location == null) {
    return null;
  }
  var places = await placemarkFromCoordinates(location.latitude, location.longitude);
  return places[0];
}

String formatPlace(Placemark? place) {
  if (place == null) {
    return "";
  }
  return "${place.street}, ${place.locality}";
}

double coordinateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
