// Screen for the user registration page
// source: https://stackoverflow.com/questions/55060998/how-to-continuously-check-internet-connect-or-not-on-flutter

import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/no_internet_access.dart';
import 'package:disc/singleton/app_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/screens/origin.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class SignUpPage extends StatefulWidget {
  static const routeName = 'signuppage';
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool submit;
  bool _usernameExist = false;

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController usernameController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

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
    usernameController.dispose();
    confirmPasswordController.dispose();
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
    usernameController.addListener(() {
      setState(() {});
    });
    confirmPasswordController.addListener(() {
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
          leading: (string == "Offline")
              ? null
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => OriginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    height: 25,
                    width: 25,
                    child: Icon(
                      Icons.keyboard_arrow_left,
                    ),
                  ),
                ),
        ),
        body: (string == "Offline")
            ? NoInternetAccess()
            : Align(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * .05),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .02),
                            _logo(context),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .02),
                            _textFieldWidget(),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * .02),
                            _signupButton(context),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/day-origin.png',
          height: (MediaQuery.of(context).size.height) * .25),
    );
  }

  Widget _textFieldWidget() {
    return Column(
      children: <Widget>[
        _usernameField("Username"),
        _emailField("Email"),
        _passwordField("Password", isPassword: true),
        _confirmPasswordField("Confirm Password", isPassword: true)
      ],
    );
  }

  Widget _usernameField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * .01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * .005),
          TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9\-//._]")),
              ],
              textInputAction: TextInputAction.next,
              controller: usernameController,
              obscureText: isPassword,
              keyboardType: TextInputType.text,
              maxLength: usernameController.text.length > 8 ? 12 : null,
              decoration: InputDecoration(
                  errorText: _usernameExist ? "Username already taken" : null,
                  suffixIcon: usernameController.text.length > 0
                      ? IconButton(
                          onPressed: () => usernameController.clear(),
                          icon: Icon(Icons.clear, color: Colors.grey))
                      : null,
                  border: InputBorder.none,
                  hintText: 'Enter Username',
                  filled: true))
        ],
      ),
    );
  }

  Widget _emailField(String title, {bool isPassword = false}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .005),
            TextFormField(
                textInputAction: TextInputAction.next,
                validator: (val) => !EmailValidator.validate(val, true)
                    ? 'Not a valid email or username.'
                    : null,
                controller: emailController,
                obscureText: isPassword,
                maxLength: emailController.text.length > 39 ? 50 : null,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    suffixIcon: emailController.text.length > 0
                        ? IconButton(
                            onPressed: () => emailController.clear(),
                            icon: Icon(Icons.clear, color: Colors.grey))
                        : null,
                    border: InputBorder.none,
                    hintText: 'Enter Email',
                    filled: true))
          ],
        ));
  }

  Widget _passwordField(String title, {bool isPassword = false}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .005),
            TextFormField(
                maxLength: passwordController.text.length > 10 ? 15 : null,
                textInputAction: TextInputAction.next,
                validator: (val) => val.length < 6
                    ? 'Password must be between 6 and 15 characters'
                    : null,
                controller: passwordController,
                obscureText: isPassword,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    suffixIcon: passwordController.text.length > 0
                        ? IconButton(
                            onPressed: () => passwordController.clear(),
                            icon: Icon(Icons.clear, color: Colors.grey))
                        : null,
                    border: InputBorder.none,
                    hintText: 'Enter Password',
                    filled: true))
          ],
        ));
  }

  Widget _confirmPasswordField(String title, {bool isPassword = false}) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * .005),
            TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLength:
                    confirmPasswordController.text.length >= 15 ? 15 : null,
                textInputAction: TextInputAction.done,
                validator: (val) => val != passwordController.text
                    ? 'Passwords do not match'
                    : null,
                controller: confirmPasswordController,
                obscureText: isPassword,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    suffixIcon: confirmPasswordController.text.length > 0
                        ? IconButton(
                            onPressed: () => confirmPasswordController.clear(),
                            icon: Icon(Icons.clear, color: Colors.grey))
                        : null,
                    border: InputBorder.none,
                    hintText: 'Confirm Password',
                    filled: true))
          ],
        ));
  }

  Widget _signupButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final form = _formKey.currentState;
        form.save();

        setState(() {
          _usernameExist = false;
        });

        final valid = await usernameCheck(usernameController.text);

        if (!valid) {
          setState(() {
            _usernameExist = true;
          });
        } else if (form.validate()) {
          submit = true;
          try {
            await Provider.of<AuthService>(context, listen: false).createUser(
                username: usernameController.text,
                email: emailController.text,
                password: passwordController.text);
            setState(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          title: usernameController.text,
                        )),
                (Route<dynamic> route) => false,
              );
            });
          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message);
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString());
          }
        }
      },
      label: Text('SIGN UP'),
      icon: Icon(Icons.app_registration),
    );
  }

  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: SingleChildScrollView(child: Text(_message)),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
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
}

//Function to check username
Future<bool> usernameCheck(String username) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  return result.docs.isEmpty;
}
