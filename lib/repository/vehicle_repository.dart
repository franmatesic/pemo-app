import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pemo/model/pemo_vehicle.dart';

class VehicleRepository {
  static const collection = 'vehicles';

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  VehicleRepository();

  Future create(PemoVehicle vehicle) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(vehicle.id);
    await documentReference.set({
      PemoVehicle.keyId: vehicle.id,
      PemoVehicle.keyUserId: vehicle.userId,
      PemoVehicle.keyBrand: vehicle.brand,
      PemoVehicle.keyModel: vehicle.model,
      PemoVehicle.keyColor: vehicle.color,
      PemoVehicle.keyMaxPassengers: vehicle.maxPassengers
    });
  }

  Future update(PemoVehicle vehicle) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(vehicle.id);
    await documentReference.update({
      PemoVehicle.keyId: vehicle.id,
      PemoVehicle.keyUserId: vehicle.userId,
      PemoVehicle.keyBrand: vehicle.brand,
      PemoVehicle.keyModel: vehicle.model,
      PemoVehicle.keyColor: vehicle.color,
      PemoVehicle.keyMaxPassengers: vehicle.maxPassengers
    });
  }

  Future<PemoVehicle?> get(String id) async {
    PemoVehicle? vehicle;
    await _firebaseFirestore.collection(collection).doc(id).get().then((DocumentSnapshot snapshot) => vehicle = PemoVehicle.all(
          snapshot[PemoVehicle.keyId],
          snapshot[PemoVehicle.keyUserId],
          snapshot[PemoVehicle.keyBrand],
          snapshot[PemoVehicle.keyModel],
          snapshot[PemoVehicle.keyColor],
          snapshot[PemoVehicle.keyMaxPassengers],
        ));
    return vehicle;
  }

  Future<List<PemoVehicle>> getAllFromUser(String id) async {
    List<PemoVehicle> vehicles = [];
    final query = await _firebaseFirestore.collection(collection).where(PemoVehicle.keyUserId, isEqualTo: id).get();
    for (var snapshot in query.docs) {
      vehicles.add(PemoVehicle.all(
        snapshot[PemoVehicle.keyId],
        snapshot[PemoVehicle.keyUserId],
        snapshot[PemoVehicle.keyBrand],
        snapshot[PemoVehicle.keyModel],
        snapshot[PemoVehicle.keyColor],
        snapshot[PemoVehicle.keyMaxPassengers],
      ));
    }
    return vehicles;
  }

  Future delete(String id) async {
    await _firebaseFirestore.collection(collection).doc(id).delete();
  }

  Future<bool> exists(String id) async {
    return (await _firebaseFirestore.collection(collection).doc(id).get()).exists;
  }
}
