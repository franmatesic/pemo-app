import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static LatLng? location;

  LocationService._();

  static loadLocation() async {
    await Geolocator.requestPermission();

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    location = LatLng(position.latitude, position.longitude);
    return location;
  }
}
