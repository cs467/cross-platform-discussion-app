import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

class AppConnectivity {
  AppConnectivity._internal();

  static final AppConnectivity _instance = AppConnectivity._internal();

  static AppConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller;

  Stream get myStream => controller.stream;

  void initialise() async {
    controller = StreamController.broadcast();
    ConnectivityResult result = await connectivity.checkConnectivity();
    _checkStatus(result);
    connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline = true;
      } else
        isOnline = false;
    } on SocketException catch (_) {
      isOnline = false;
    }

    controller.sink.add({result: isOnline});
  }

  void disposeStream() => controller.close();
}
