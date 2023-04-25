import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pemo/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/pemo_user.dart';
import '../repository/user_repository.dart';
import '../screens/auth/additional_info_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home_screen.dart';

enum AuthProvider {
  email('EMAIL'),
  google('GOOGLE'),
  facebook('FACEBOOK');

  final String value;

  const AuthProvider(this.value);
}

class AuthService extends ChangeNotifier {
  static const _signedInPreference = 'signed_in';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookAuth = FacebookAuth.instance;
  final UserRepository _userRepository = UserRepository();

  bool _signedIn = false;

  bool get isSignedIn => _signedIn;

  FirebaseAuthException? _error;

  FirebaseAuthException? get error => _error;

  PemoUser? _user;

  PemoUser? get user => _user;

  String? _accessToken;

  String? get accessToken => _accessToken;

  AuthService() {
    checkIfUserIsSignedIn();
  }

  Future checkIfUserIsSignedIn() async {
    _signedIn = await _getSignedInPreference();
    notifyListeners();
  }

  Future setSignedIn() async {
    _signedIn = true;
    await _setSignedInPreference(true);
    await _setUserPreferences(_user!, _accessToken);
    notifyListeners();
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredentials = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      _accessToken = userCredentials.credential?.accessToken;

      _user = PemoUser(userCredentials.user?.uid, userCredentials.user?.email, AuthProvider.email.value);
      await _userRepository.createUser(_user!);
      _error = null;

      await userCredentials.user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredentials = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      _accessToken = userCredentials.credential?.accessToken;

      _user = await _userRepository.getUser(userCredentials.user!.uid);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount == null) {
      return;
    }
    try {
      final googleSignInAuthentication = await googleSignInAccount.authentication;
      final credential =
          GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);

      final userCredentials = await _firebaseAuth.signInWithCredential(credential);
      _accessToken = userCredentials.credential?.accessToken;
      final uid = userCredentials.user!.uid;

      if (await _userRepository.userExists(uid)) {
        _user = await _userRepository.getUser(uid);
      } else {
        _user = PemoUser.fromProvider(
            uid, userCredentials.user?.email, AuthProvider.google.value, userCredentials.user?.displayName, userCredentials.user?.photoURL);
        await _userRepository.createUser(_user!);
      }
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  Future signInWithFacebook() async {
    final facebookLogin = await _facebookAuth.login();
    final facebookToken = facebookLogin.accessToken;

    if (facebookLogin.status != LoginStatus.success) {
      return;
    }
    try {
      final credential = FacebookAuthProvider.credential(facebookToken!.token);
      final userCredentials = await _firebaseAuth.signInWithCredential(credential);
      _accessToken = userCredentials.credential?.accessToken;
      final uid = userCredentials.user!.uid;

      if (await _userRepository.userExists(uid)) {
        _user = await _userRepository.getUser(uid);
      } else {
        _user = PemoUser.fromProvider(
            uid, userCredentials.user?.email, AuthProvider.facebook.value, userCredentials.user?.displayName, userCredentials.user?.photoURL);
        await _userRepository.createUser(_user!);
      }
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e;
    }
    notifyListeners();
  }

  Future signOut(bool afterDelete) async {
    if (!afterDelete) {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    }
    _user = null;
    _accessToken = null;
    _signedIn = false;
    await _setSignedInPreference(false);
    await _removeUserPreferences();
    notifyListeners();
  }

  Future<Tuple<bool, Widget>> getRedirect() async {
    if (!isSignedIn) {
      return Tuple(false, const AuthScreen());
    }
    final userPrefs = await _getUserPreferences();
    _accessToken = userPrefs.right;
    _user ??= userPrefs.left;
    _user?.updateImage();

    if (_user == null) {
      return Tuple(false, const AuthScreen());
    }

    if (_user!.role == null || _user!.name == null || _user!.gender == null || _user!.dateOfBirth == null || _user!.phoneNumber == null) {
      return Tuple(true, const AdditionalInfoScreen());
    }
    return Tuple(true, const HomeScreen());
  }

  Future<bool> _getSignedInPreference() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_signedInPreference) ?? false;
  }

  Future _setSignedInPreference(bool signedIn) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_signedInPreference, signedIn);
  }

  Future<Tuple<PemoUser, String?>> _getUserPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return Tuple(
        PemoUser.all(
            sharedPreferences.getString(PemoUser.keyUid),
            sharedPreferences.getString(PemoUser.keyEmail),
            sharedPreferences.getString(PemoUser.keyProvider),
            sharedPreferences.getString(PemoUser.keyName),
            sharedPreferences.getString(PemoUser.keyGender),
            sharedPreferences.getString(PemoUser.keyDateOfBirth),
            sharedPreferences.getString(PemoUser.keyPhoneNumber),
            sharedPreferences.getString(PemoUser.keyImageUrl),
            sharedPreferences.getString(PemoUser.keyRole)),
        sharedPreferences.getString("token"));
  }

  Future _setUserPreferences(PemoUser user, String? token) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PemoUser.keyUid, user.id!);
    sharedPreferences.setString(PemoUser.keyEmail, user.email!);
    sharedPreferences.setString(PemoUser.keyProvider, user.provider!);
    if (user.role != null) {
      sharedPreferences.setString(PemoUser.keyRole, user.role!);
    }
    if (user.name != null) {
      sharedPreferences.setString(PemoUser.keyName, user.name!);
    }
    if (user.gender != null) {
      sharedPreferences.setString(PemoUser.keyGender, user.gender!);
    }
    if (user.dateOfBirth != null) {
      sharedPreferences.setString(PemoUser.keyDateOfBirth, user.dateOfBirth!);
    }
    if (user.phoneNumber != null) {
      sharedPreferences.setString(PemoUser.keyPhoneNumber, user.phoneNumber!);
    }
    if (user.imageUrl != null) {
      sharedPreferences.setString(PemoUser.keyImageUrl, user.imageUrl!);
    }
    if (token != null) {
      sharedPreferences.setString("token", token);
    }
  }

  Future _removeUserPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove(PemoUser.keyUid);
    sharedPreferences.remove(PemoUser.keyEmail);
    sharedPreferences.remove(PemoUser.keyProvider);
    sharedPreferences.remove(PemoUser.keyRole);
    sharedPreferences.remove(PemoUser.keyName);
    sharedPreferences.remove(PemoUser.keyGender);
    sharedPreferences.remove(PemoUser.keyDateOfBirth);
    sharedPreferences.remove(PemoUser.keyPhoneNumber);
    sharedPreferences.remove(PemoUser.keyImageUrl);
    sharedPreferences.remove("token");
  }
}
