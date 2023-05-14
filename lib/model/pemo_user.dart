import 'package:flutter/material.dart';

class PemoUser {
  static const imageLocalUrl = "/profile/";

  static const keyId = "id";
  static const keyEmail = "email";
  static const keyProvider = "provider";
  static const keyName = "name";
  static const keyGender = "gender";
  static const keyDateOfBirth = "dateOfBirth";
  static const keyPhoneNumber = "phoneNumber";
  static const keyImageUrl = "imageUrl";
  static const keyRole = "role";

  final String? _id;
  final String? _email;
  final String? _provider;
  String? name;
  String? gender;
  String? dateOfBirth;
  String? phoneNumber;
  String? imageUrl;
  String? role;
  Image? image;

  PemoUser(this._id, this._email, this._provider);

  PemoUser.fromProvider(this._id, this._email, this._provider, this.name, this.imageUrl) {
    updateImage();
  }

  PemoUser.all(this._id, this._email, this._provider, this.name, this.gender, this.dateOfBirth, this.phoneNumber, this.imageUrl, this.role) {
    updateImage();
  }

  String? get id => _id;

  String? get email => _email;

  String? get provider => _provider;

  updateImage() {
    if (imageUrl != null) {
      image = Image.network(imageUrl!, fit: BoxFit.cover);
    }
  }
}
