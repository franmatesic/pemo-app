import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pemo/model/pemo_ride_request.dart';
import 'package:pemo/repository/ride_repository.dart';

import '../utils/parsers.dart';

class RideRequestRepository {
  static const collection = 'ride-requests';

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final rideRepository = RideRepository();

  RideRequestRepository();

  Future create(PemoRideRequest request) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(request.id);
    await documentReference.set({
      PemoRideRequest.keyId: request.id,
      PemoRideRequest.keyRideId: request.rideId,
      PemoRideRequest.keyUserId: request.userId,
      PemoRideRequest.keyCreatedAt: formatDateTime(request.createdAt),
      PemoRideRequest.keyPaymentMethod: request.paymentMethod,
      PemoRideRequest.keyPassengerCount: request.passengerCount,
      PemoRideRequest.keyPickup: formatLocation(request.pickup),
      PemoRideRequest.keyStop: formatLocation(request.stop),
      PemoRideRequest.keyAcceptedAt: formatDateTime(request.acceptedAt),
      PemoRideRequest.keyDeniedAt: formatDateTime(request.deniedAt),
      PemoRideRequest.keyCancelledAt: formatDateTime(request.cancelledAt)
    });
  }

  Future update(PemoRideRequest request) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(request.id);
    await documentReference.update({
      PemoRideRequest.keyId: request.id,
      PemoRideRequest.keyRideId: request.rideId,
      PemoRideRequest.keyUserId: request.userId,
      PemoRideRequest.keyCreatedAt: formatDateTime(request.createdAt),
      PemoRideRequest.keyPaymentMethod: request.paymentMethod,
      PemoRideRequest.keyPassengerCount: request.passengerCount,
      PemoRideRequest.keyPickup: formatLocation(request.pickup),
      PemoRideRequest.keyStop: formatLocation(request.stop),
      PemoRideRequest.keyAcceptedAt: formatDateTime(request.acceptedAt),
      PemoRideRequest.keyDeniedAt: formatDateTime(request.deniedAt),
      PemoRideRequest.keyCancelledAt: formatDateTime(request.cancelledAt)
    });
  }

  Future<List<PemoRideRequest>> getByRide(String rideId) async {
    List<PemoRideRequest> requests = [];
    final query = await _firebaseFirestore.collection(collection).where(PemoRideRequest.keyRideId, isEqualTo: rideId).get();

    for (var snapshot in query.docs) {
      if (snapshot[PemoRideRequest.keyCancelledAt] != null || snapshot[PemoRideRequest.keyDeniedAt] != null) {
        continue;
      }
      requests.add(PemoRideRequest.all(
        snapshot[PemoRideRequest.keyId],
        snapshot[PemoRideRequest.keyUserId],
        snapshot[PemoRideRequest.keyRideId],
        DateTime.parse(snapshot[PemoRideRequest.keyCreatedAt]),
        parseLocation(snapshot[PemoRideRequest.keyPickup]),
        parseLocation(snapshot[PemoRideRequest.keyStop]),
        snapshot[PemoRideRequest.keyPaymentMethod],
        snapshot[PemoRideRequest.keyPassengerCount],
        parseDateTime(snapshot[PemoRideRequest.keyAcceptedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyDeniedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyCancelledAt]),
      ));
    }
    return requests;
  }

  Future<List<PemoRideRequest>> getByUser(String userId) async {
    List<PemoRideRequest> requests = [];
    final query = await _firebaseFirestore.collection(collection).where(PemoRideRequest.keyUserId, isEqualTo: userId).get();

    for (var snapshot in query.docs) {
      if (snapshot[PemoRideRequest.keyAcceptedAt] == null) {
        continue;
      }
      requests.add(PemoRideRequest.all(
        snapshot[PemoRideRequest.keyId],
        snapshot[PemoRideRequest.keyUserId],
        snapshot[PemoRideRequest.keyRideId],
        DateTime.parse(snapshot[PemoRideRequest.keyCreatedAt]),
        parseLocation(snapshot[PemoRideRequest.keyPickup]),
        parseLocation(snapshot[PemoRideRequest.keyStop]),
        snapshot[PemoRideRequest.keyPaymentMethod],
        snapshot[PemoRideRequest.keyPassengerCount],
        parseDateTime(snapshot[PemoRideRequest.keyAcceptedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyDeniedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyCancelledAt]),
      ));
    }
    return requests;
  }

  Future<List<PemoRideRequest>> getByUserActive(String userId) async {
    List<PemoRideRequest> requests = [];
    final query = await _firebaseFirestore.collection(collection).where(PemoRideRequest.keyUserId, isEqualTo: userId).get();

    for (var snapshot in query.docs) {
      if (snapshot[PemoRideRequest.keyCancelledAt] != null) {
        continue;
      }
      final ride = await rideRepository.get(snapshot[PemoRideRequest.keyRideId]);
      if (ride!.startsAt.isBefore(DateTime.now())) {
        continue;
      }
      final deniedAt = parseDateTime(snapshot[PemoRideRequest.keyDeniedAt]);
      if (deniedAt != null && deniedAt.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        continue;
      }
      requests.add(PemoRideRequest.all(
        snapshot[PemoRideRequest.keyId],
        snapshot[PemoRideRequest.keyUserId],
        snapshot[PemoRideRequest.keyRideId],
        DateTime.parse(snapshot[PemoRideRequest.keyCreatedAt]),
        parseLocation(snapshot[PemoRideRequest.keyPickup]),
        parseLocation(snapshot[PemoRideRequest.keyStop]),
        snapshot[PemoRideRequest.keyPaymentMethod],
        snapshot[PemoRideRequest.keyPassengerCount],
        parseDateTime(snapshot[PemoRideRequest.keyAcceptedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyDeniedAt]),
        parseDateTime(snapshot[PemoRideRequest.keyCancelledAt]),
      ));
    }
    return requests;
  }

  Future<bool> exists(String id) async {
    return (await _firebaseFirestore.collection(collection).doc(id).get()).exists;
  }
}
