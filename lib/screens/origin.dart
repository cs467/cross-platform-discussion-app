import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

import 'package:disc/singleton/app_connectivity.dart';

import 'package:disc/screens/signup_page.dart';
import 'package:disc/screens/login_page.dart';

import 'package:disc/Widgets/no_internet_access.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class OriginPage extends StatefulWidget {
  static const routeName = 'originpage';
  @override
  State<StatefulWidget> createState() => _OriginPageState();
}

class _OriginPageState extends State<OriginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  String string, timedString;
  var timer;
  var previousResult;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  Timer startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    timer = Timer(duration, handleTimeout);
    return timer;
  }

  void handleTimeout() async {
    ConnectivityResult result = await (Connectivity().checkConnectivity());

    switch (result) {
      case ConnectivityResult.none:
        timedString = "Offline";
        break;
      case ConnectivityResult.mobile:
        timedString = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        timedString = "WiFi: Online";
    }

    if ((previousResult != result) && mounted) {
      setState(() {});
    }

    previousResult = result;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      setState(() {});
    });
    passwordController.addListener(() {
      setState(() {});
    });

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() {
        _source = source;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        string = "WiFi: Online";
    }

    startTimeout();
    if (string != timedString) {
      string = timedString;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(""),
      ),
      body: (string == "Offline")
          ? NoInternetAccess()
          : Align(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 60.0),
                          _logo(context),
                          SizedBox(height: 60.0),

                          SizedBox(height: 20.0),
                          _loginButton(context),

                          //_continue(context),
                          SizedBox(height: 30.0),
                          _signupButton(context)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "btn3",
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      },
      label: Text('SIGN IN'),
      icon: Icon(Icons.login),
    );
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/day-origin.png', width: 300.0),
    );
  }
}

Widget _signupButton(BuildContext context) {
  return FloatingActionButton.extended(
    heroTag: "btn2",
    onPressed: () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
        (Route<dynamic> route) => false,
      );
    },
    label: Text('SIGN UP'),
    icon: Icon(Icons.app_registration),
  );
}

//Function to check if email exists
Future<bool> emailCheck(String email) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();
  return result.docs.isEmpty;
}

Future<String> usernameCheck(String username) async {
  var email;
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  if (result.docs.isNotEmpty) {
    email = result.docs.last['email'];
  } else {
    if (username.contains('@')) {
      email = username;
    } else {
      email = "None";
    }
  }
  return email;
}
