// Screen where the user logs in the app with username and password 
// source: https://stackoverflow.com/questions/55060998/how-to-continuously-check-internet-connect-or-not-on-flutter

import 'dart:async';

import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';

import 'package:disc/singleton/app_connectivity.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/screens/origin.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:disc/Widgets/no_internet_access.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class LoginPage extends StatefulWidget {
  static const routeName = 'loginpage';
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _emailExist = false;
  bool _usernameExist = true;

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
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          _logo(context),
                          SizedBox(height: 20.0),
                          _emailPasswordWidget(),
                          SizedBox(height: 40.0),
                          _loginButton(context),
                          SizedBox(height: 40.0),
                          _passwordReset(context),
                          SizedBox(height: 20.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _emailField("Username"),
        _passwordField("Password", isPassword: true),
      ],
    );
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
              controller: emailController,
              obscureText: isPassword,
              validator: (val) =>
                  !EmailValidator.validate(val, true) && _usernameExist == true
                      ? 'Not a valid email or username'
                      : null,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorText:
                      _emailExist ? "Email or username does not exist" : null,
                  suffixIcon: emailController.text.length > 0
                      ? IconButton(
                          onPressed: () {
                            emailController.clear();
                          },
                          icon: Icon(Icons.clear, color: Colors.grey))
                      : null,
                  border: InputBorder.none,
                  hintText: 'Enter Email or Username',
                  filled: true))
        ],
      ),
    );
  }

  Widget _passwordField(String title, {bool isPassword = false}) {
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
              controller: passwordController,
              obscureText: isPassword,
              keyboardType: TextInputType.emailAddress,
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
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: "btn1",
      onPressed: () async {
        var result;
        final form = _formKey.currentState;
        form.save();

        result = await usernameCheck(emailController.text);

        if (result != "None") {
          _usernameExist = false;
        }

        if (form.validate() || _usernameExist == false) {
          try {
            await Provider.of<AuthService>(context, listen: false).loginUser(
                email: result == "None" ? emailController.text : result,
                password: passwordController.text);
            setState(() {
              //_successfulLogin(context);

              Provider.of<AuthService>(context, listen: false).getUser().then(
                  (currentUser) => FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUser.uid)
                      .get()
                      .then((DocumentSnapshot result) =>
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomePage(title: result["username"])),
                            (Route<dynamic> route) => false,
                          ))
                      .catchError((err) => print(err)));
              emailController.clear();
              passwordController.clear();
            });
          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message);
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString());
          }
        } else {}
      },
      label: Text('SIGN IN'),
      icon: Icon(Icons.login),
    );
  }

  Widget _passwordReset(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            Navigator.of(context).pushReplacementNamed('passwordpage');
          });
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text('Forgot Password?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ));
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/day-origin.png', width: 200.0),
    );
  }
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

Future _successfulLogin(BuildContext context) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Log In Success'),
        content: SingleChildScrollView(
            child: Text('Congrats, you have successfully Logged In!!')),
        actions: <Widget>[
          FlatButton(
              child: Text('Proceed'),
              color: Color(0xff2193b0),
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
      // Must return something.
      email = "None";
    }
  }
  return email;
}
