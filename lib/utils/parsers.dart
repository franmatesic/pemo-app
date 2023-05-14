import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

final timeFormatter = DateFormat.Hm();
final dateFormatter = DateFormat.yMMMd();

String? formatLocation(LatLng? location) {
  if (location == null) {
    return null;
  }
  return "${location.latitude},${location.longitude}";
}

LatLng parseLocation(String location) {
  final parts = location.split(",");
  return LatLng(double.parse(parts[0]), double.parse(parts[1]));
}

String? formatDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }
  return dateTime.toString();
}

String formatDate(DateTime dateTime) {
  return "${dateFormatter.format(dateTime)} ${formatTime(dateTime)}";
}

String formatTime(DateTime dateTime) {
  return timeFormatter.format(dateTime);
}

DateTime? parseDateTime(String? dateTime) {
  if (dateTime == null) {
    return null;
  }
  return DateTime.parse(dateTime);
}
