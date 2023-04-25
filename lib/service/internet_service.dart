import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetService extends ChangeNotifier {
  bool _hasInternet = false;

  bool get hasInternet => _hasInternet;

  InternetService() {
    checkInternetConnection();
  }

  Future checkInternetConnection() async {
    var result = await Connectivity().checkConnectivity();
    _hasInternet = result != ConnectivityResult.none;
    notifyListeners();
  }
}
