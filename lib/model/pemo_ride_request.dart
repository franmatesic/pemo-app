import 'package:google_maps_flutter/google_maps_flutter.dart';

class PemoRideRequest {
  static const keyId = "id";
  static const keyUserId = "userId";
  static const keyRideId = "rideId";
  static const keyPickup = "pickup";
  static const keyStop = "stop";
  static const keyPaymentMethod = "paymentMethod";
  static const keyPassengerCount = "passengerCount";
  static const keyCreatedAt = "createdAt";
  static const keyAcceptedAt = "acceptedAt";
  static const keyDeniedAt = "deniedAt";
  static const keyCancelledAt = "cancelledAt";

  final String id;
  final String userId;
  final String rideId;
  final DateTime createdAt;
  LatLng pickup;
  LatLng stop;
  String paymentMethod;
  int passengerCount;
  DateTime? acceptedAt;
  DateTime? deniedAt;
  DateTime? cancelledAt;

  PemoRideRequest(this.id, this.userId, this.rideId, this.pickup, this.stop, this.paymentMethod, this.passengerCount, this.createdAt);

  PemoRideRequest.all(this.id, this.userId, this.rideId, this.createdAt, this.pickup, this.stop, this.paymentMethod, this.passengerCount,
      this.acceptedAt, this.deniedAt, this.cancelledAt);
}
