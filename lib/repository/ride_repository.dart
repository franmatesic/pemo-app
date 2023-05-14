import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pemo/model/pemo_ride.dart';

import '../utils/parsers.dart';
import '../utils/places.dart';

class RideRepository {
  static const collection = 'rides';

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  RideRepository();

  Future create(PemoRide ride) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(ride.id);
    await documentReference.set({
      PemoRide.keyId: ride.id,
      PemoRide.keyVehicleId: ride.vehicleId,
      PemoRide.keyUserId: ride.userId,
      PemoRide.keyCreatedAt: formatDateTime(ride.createdAt),
      PemoRide.keyStart: formatLocation(ride.start),
      PemoRide.keyEnd: formatLocation(ride.end),
      PemoRide.keyPrice: ride.price,
      PemoRide.keyStartsAt: formatDateTime(ride.startsAt),
      PemoRide.keyPreferredPaymentMethods: ride.preferredPaymentMethods.reduce((a, b) => "$a,$b"),
      PemoRide.keyUpdatedAt: formatDateTime(ride.updatedAt),
      PemoRide.keyCancelledAt: formatDateTime(ride.cancelledAt)
    });
  }

  Future update(PemoRide ride) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(ride.id);
    await documentReference.update({
      PemoRide.keyId: ride.id,
      PemoRide.keyVehicleId: ride.vehicleId,
      PemoRide.keyUserId: ride.userId,
      PemoRide.keyCreatedAt: formatDateTime(ride.createdAt),
      PemoRide.keyStart: formatLocation(ride.start),
      PemoRide.keyEnd: formatLocation(ride.end),
      PemoRide.keyPrice: ride.price,
      PemoRide.keyStartsAt: formatDateTime(ride.startsAt),
      PemoRide.keyPreferredPaymentMethods: ride.preferredPaymentMethods.reduce((a, b) => "$a,$b"),
      PemoRide.keyUpdatedAt: formatDateTime(ride.updatedAt),
      PemoRide.keyCancelledAt: formatDateTime(ride.cancelledAt)
    });
  }

  Future<PemoRide?> get(String id) async {
    PemoRide? ride;
    await _firebaseFirestore.collection(collection).doc(id).get().then((DocumentSnapshot snapshot) => ride = PemoRide.all(
        snapshot[PemoRide.keyId],
        snapshot[PemoRide.keyUserId],
        snapshot[PemoRide.keyVehicleId],
        parseLocation(snapshot[PemoRide.keyStart]),
        parseLocation(snapshot[PemoRide.keyEnd]),
        snapshot[PemoRide.keyPrice],
        (snapshot[PemoRide.keyPreferredPaymentMethods] as String).split(","),
        DateTime.parse(snapshot[PemoRide.keyStartsAt]),
        DateTime.parse(snapshot[PemoRide.keyCreatedAt]),
        parseDateTime(snapshot[PemoRide.keyUpdatedAt]),
        parseDateTime(snapshot[PemoRide.keyCancelledAt])));
    return ride;
  }

  Future<List<PemoRide>> getByUser(String userId, bool active, bool asc) async {
    List<PemoRide> rides = [];
    final query = await _firebaseFirestore.collection(collection).where(PemoRide.keyUserId, isEqualTo: userId).get();

    for (var snapshot in query.docs) {
      if (active && snapshot[PemoRide.keyCancelledAt] != null) {
        continue;
      }
      final startsAt = DateTime.parse(snapshot[PemoRide.keyStartsAt]);
      if (active && startsAt.isBefore(DateTime.now())) {
        continue;
      }
      rides.add(PemoRide.all(
          snapshot[PemoRide.keyId],
          snapshot[PemoRide.keyUserId],
          snapshot[PemoRide.keyVehicleId],
          parseLocation(snapshot[PemoRide.keyStart]),
          parseLocation(snapshot[PemoRide.keyEnd]),
          snapshot[PemoRide.keyPrice],
          (snapshot[PemoRide.keyPreferredPaymentMethods] as String).split(","),
          startsAt,
          DateTime.parse(snapshot[PemoRide.keyCreatedAt]),
          parseDateTime(snapshot[PemoRide.keyUpdatedAt]),
          parseDateTime(snapshot[PemoRide.keyCancelledAt])));
    }
    if (asc) {
      rides.sort((a, b) => b.startsAt.compareTo(a.startsAt));
    } else {
      rides.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }
    return rides;
  }

  Future<List<PemoRide>> getClosest(LatLng? location, String userId, int count, double maxDistance) async {
    if (location == null) {
      return [];
    }
    List<PemoRide> rides = [];
    final minTime = DateTime.now().add(const Duration(minutes: 5));
    final maxTime = minTime.add(const Duration(days: 31));

    final query = await _firebaseFirestore.collection(collection).where(PemoRide.keyCancelledAt, isNull: true).get();

    for (var snapshot in query.docs) {
      if (snapshot[PemoRide.keyUserId] == userId) {
        continue;
      }
      final startsAt = DateTime.parse(snapshot[PemoRide.keyStartsAt]);
      if (startsAt.isBefore(minTime) || startsAt.isAfter(maxTime)) {
        continue;
      }
      final start = parseLocation(snapshot[PemoRide.keyStart]);
      final distance = coordinateDistance(start.latitude, start.longitude, location.latitude, location.longitude);
      if (distance > maxDistance) {
        continue;
      }
      rides.add(PemoRide.all(
          snapshot[PemoRide.keyId],
          snapshot[PemoRide.keyUserId],
          snapshot[PemoRide.keyVehicleId],
          start,
          parseLocation(snapshot[PemoRide.keyEnd]),
          snapshot[PemoRide.keyPrice],
          (snapshot[PemoRide.keyPreferredPaymentMethods] as String).split(","),
          startsAt,
          DateTime.parse(snapshot[PemoRide.keyCreatedAt]),
          parseDateTime(snapshot[PemoRide.keyUpdatedAt]),
          parseDateTime(snapshot[PemoRide.keyCancelledAt])));
    }
    rides.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return rides.sublist(0, min(rides.length, count));
  }

  Future<bool> exists(String id) async {
    return (await _firebaseFirestore.collection(collection).doc(id).get()).exists;
  }
}
