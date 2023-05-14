import 'package:google_maps_flutter/google_maps_flutter.dart';

class PemoRide {
  static const keyId = "id";
  static const keyUserId = "userId";
  static const keyVehicleId = "vehicleId";
  static const keyCreatedAt = "createdAt";
  static const keyStart = "start";
  static const keyEnd = "end";
  static const keyPrice = "price";
  static const keyPreferredPaymentMethods = "preferredPaymentMethods";
  static const keyStartsAt = "startsAt";
  static const keyUpdatedAt = "updatedAt";
  static const keyCancelledAt = "cancelledAt";

  final String id;
  final String userId;
  final DateTime createdAt;
  String vehicleId;
  LatLng start;
  LatLng end;
  double price;
  List<String> preferredPaymentMethods;
  DateTime startsAt;
  DateTime? updatedAt;
  DateTime? cancelledAt;

  PemoRide(this.id, this.userId, this.vehicleId, this.start, this.end, this.price, this.preferredPaymentMethods, this.startsAt, this.createdAt);

  PemoRide.all(this.id, this.userId, this.vehicleId, this.start, this.end, this.price, this.preferredPaymentMethods, this.startsAt, this.createdAt,
      this.updatedAt, this.cancelledAt);
}
