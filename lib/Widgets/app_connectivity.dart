import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';

class AppConnectivity {
  AppConnectivity._internal();

  static final AppConnectivity _instance = AppConnectivity._internal();

  static AppConnectivity get instance => _instance;

  Connectivity connectivity = Connectivity();

  StreamController controller;// = StreamController.broadcast();

  Stream get myStream => controller.stream;

  void initialise() async {
//    connectivity = Connectivity();
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
        print("connected!");
      } else
        isOnline = false;
        print("no connection...");
    } on SocketException catch (_) {
      isOnline = false;
      print("socket exception...");
    }
    // if (!controller.isClosed) {
    controller.sink.add({result: isOnline});
    // }
  }

  void disposeStream() => controller.close();
}
