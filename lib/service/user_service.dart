import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pemo/repository/user_repository.dart';
import 'package:pemo/service/auth_service.dart';
import 'package:pemo/service/internet_service.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../model/pemo_user.dart';
import '../utils/navigation.dart';

class UserService extends ChangeNotifier {
  final BuildContext _context;
  final AuthService _authService;
  final InternetService _internetService;
  final S _intl;
  final UserRepository _userRepository = UserRepository();

  UserService(this._context)
      : _authService = _context.read<AuthService>(),
        _internetService = _context.read<InternetService>(),
        _intl = S.of(_context);

  Future handleRegisterWithEmailAndPassword(String email, String password) async {
    if (!await _internetActive()) {
      return;
    }
    await _authService.registerWithEmailAndPassword(email, password).then((_) => _handleResponse());
  }

  Future handleSignInWithEmailAndPassword(String email, String password) async {
    if (!await _internetActive()) {
      return;
    }
    await _authService.signInWithEmailAndPassword(email, password).then((_) => _handleResponse());
  }

  Future handleGoogleSignIn() async {
    if (!await _internetActive()) {
      return;
    }
    await _authService.signInWithGoogle().then((_) => _handleResponse());
  }

  Future handleFacebookSignIn() async {
    if (!await _internetActive()) {
      return;
    }
    await _authService.signInWithFacebook().then((_) => _handleResponse());
  }

  Future handleSignOut() async {
    await _signOut(false);
  }

  Future handleAddUserRole(String role) async {
    if (!await _internetActive() || _authService.user == null) {
      return;
    }
    _authService.user!.role = role;
    //TODO rest api call
    await _userRepository.updateUser(_authService.user!);
  }

  Future handleAdditionalUserData(String name, String gender, String dateOfBirth, String phoneNumber, File? imageFile) async {
    if (!await _internetActive() || _authService.user == null) {
      return;
    }
    _authService.user!.name = name;
    _authService.user!.gender = gender;
    _authService.user!.dateOfBirth = dateOfBirth;
    _authService.user!.phoneNumber = phoneNumber;
    await _userRepository.updateUser(_authService.user!);
    if (imageFile != null) {
      await _userRepository.uploadAndUpdateUserImage(_authService.user!, imageFile);
    }
  }

  Future handleDeleteUser() async {
    await _userRepository.deleteUser(_authService.user!).then((value) => _signOut(true));
  }

  PemoUser getSignedInUser() {
    return _authService.user!;
  }

  Future _signOut(bool afterDelete) async {
    await _authService.signOut(afterDelete);
  }

  Future _handleResponse() async {
    if (_authService.error != null) {
      _showErrorMessage(_getErrorMessage(_authService.error!));
      return;
    }
    await _authService.setSignedIn().then((value) => _handleRedirect());
  }

  Future _handleRedirect() async {
    final redirectInfo = await _authService.getRedirect();
    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => {if (redirectInfo.left) nextScreenReplace(_context, redirectInfo.right) else nextScreen(_context, redirectInfo.right)});
  }

  void _showErrorMessage(String message) {
    Flushbar(
      duration: const Duration(seconds: 3),
      message: message,
      backgroundColor: Colors.red,
      messageSize: 18,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
    ).show(_context);
  }

  String _getErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return _intl.user_not_found;
      case 'wrong-password':
        return _intl.incorrect_password;
      case 'weak-password':
        return _intl.weak_password;
      case 'email-already-in-use':
        return _intl.email_in_use;
      case 'account-exists-with-different-credential':
        return _intl.provider_error;
      case 'null':
        return _intl.unexpected_error;
    }
    return error.toString();
  }

  Future<bool> _internetActive() async {
    await _internetService.checkInternetConnection();
    if (!_internetService.hasInternet) {
      _showErrorMessage(_intl.internet_error);
    }
    return _internetService.hasInternet;
  }
}
