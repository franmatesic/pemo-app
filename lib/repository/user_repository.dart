import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/pemo_user.dart';

class UserRepository {
  static const collection = 'users';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future createUser(PemoUser user) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(user.id);
    await documentReference.set({
      PemoUser.keyId: user.id,
      PemoUser.keyEmail: user.email,
      PemoUser.keyProvider: user.provider,
      PemoUser.keyName: user.name,
      PemoUser.keyGender: user.gender,
      PemoUser.keyDateOfBirth: user.dateOfBirth,
      PemoUser.keyPhoneNumber: user.phoneNumber,
      PemoUser.keyImageUrl: user.imageUrl,
      PemoUser.keyRole: user.role
    });
  }

  Future updateUser(PemoUser user) async {
    final documentReference = _firebaseFirestore.collection(collection).doc(user.id);
    await documentReference.update({
      PemoUser.keyId: user.id,
      PemoUser.keyEmail: user.email,
      PemoUser.keyProvider: user.provider,
      PemoUser.keyName: user.name,
      PemoUser.keyGender: user.gender,
      PemoUser.keyDateOfBirth: user.dateOfBirth,
      PemoUser.keyPhoneNumber: user.phoneNumber,
      PemoUser.keyImageUrl: user.imageUrl,
      PemoUser.keyRole: user.role
    });
  }

  Future<PemoUser?> getUser(String id) async {
    PemoUser? user;
    await _firebaseFirestore.collection(collection).doc(id).get().then((DocumentSnapshot snapshot) => user = PemoUser.all(
        snapshot[PemoUser.keyId],
        snapshot[PemoUser.keyEmail],
        snapshot[PemoUser.keyProvider],
        snapshot[PemoUser.keyName],
        snapshot[PemoUser.keyGender],
        snapshot[PemoUser.keyDateOfBirth],
        snapshot[PemoUser.keyPhoneNumber],
        snapshot[PemoUser.keyImageUrl],
        snapshot[PemoUser.keyRole]));
    return user;
  }

  Future deleteUser(PemoUser user) async {
    _firebaseFirestore.collection(collection).doc(user.id).delete().then((value) => user.imageUrl != null
        ? _firebaseStorage.ref().child('$collection/${user.id}/profile-picture').delete().then((value) => _firebaseAuth.currentUser?.delete())
        : _firebaseAuth.currentUser?.delete());
  }

  Future<bool> userExists(String id) async {
    return (await _firebaseFirestore.collection(collection).doc(id).get()).exists;
  }

  Future uploadAndUpdateUserImage(PemoUser user, File file) async {
    final snapshot = await _firebaseStorage.ref().child('$collection/${user.id}/profile-picture').putFile(file);
    user.imageUrl = await snapshot.ref.getDownloadURL();
    user.updateImage();
    final documentReference = _firebaseFirestore.collection(collection).doc(user.id);
    await documentReference.update({PemoUser.keyImageUrl: user.imageUrl});
  }
}
