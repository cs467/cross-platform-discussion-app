// Screen where the user provides their email address to receive the password reset link 
// source: https://stackoverflow.com/questions/55060998/how-to-continuously-check-internet-connect-or-not-on-flutter

import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/no_internet_access.dart';
import 'package:disc/singleton/app_connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disc/screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class PasswordPage extends StatefulWidget {
  static const routeName = 'passwordpage';
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _emailExist = true;
  String email;

  TextEditingController emailController = new TextEditingController();

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
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      setState(() {});
    });

    _connectivity.initialise();
    if (mounted) {
      _connectivity.myStream.listen((source) {
        setState(() {
          _source = source;
        });
      });
    }
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
          leading:
          (string == "Offline")
          ? null
          : 
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage()
                ),
                (Route<dynamic> route) => false,
              );
            },
            child: Container(
              child: Icon(
                Icons.keyboard_arrow_left,
              ),
            ),
          ),
          centerTitle: true,
          title: Text("Reset Password"),
        ),
        body: (string == "Offline")
            ? NoInternetAccess()
            : Align(
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              _logo(context),
                              SizedBox(height: 20.0),
                              _emailField("Email"),
                              SizedBox(height: 20.0),
                              _resetButton(context),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  Widget _emailField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              //autofocus: true,
              controller: emailController,
              obscureText: isPassword,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorText: !_emailExist ? "Email does not exist" : null,
                  suffixIcon: emailController.text.length > 0
                      ? IconButton(
                          onPressed: () => emailController.clear(),
                          icon: Icon(Icons.clear, color: Colors.grey))
                      : null,
                  border: InputBorder.none,
                  hintText: 'Enter Email',
                  //fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _resetButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
          if (emailController.text.isEmpty) {
            _buildErrorDialog(context, "Email is empty", "Error Message");
          } else {
            try {
            await Provider.of<AuthService>(context, listen: false)
                .resetPassword(emailController.text);

            setState(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
              email = emailController.text;
              _buildErrorDialog(
                  context, "A password reset link has been sent to $email", "Email Sent!");
            });
          
          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message, "Error Message");
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString(), "Error Message");
          }
        }
      },
      label: Text('RESET'),
      icon: Icon(Icons.lock),

    );
  }

  Future _buildErrorDialog(BuildContext context, _message, _header) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text(_header),
          content: SingleChildScrollView(child: Text(_message)),
          actions: <Widget>[
            FlatButton(
                child: Text('Proceed'),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
      barrierColor: Colors.black54,
    );
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/day-origin.png', width: 200.0),
    );
  }
}

Future<bool> emailCheck(String email) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .get();
  return result.docs.isEmpty;
}
