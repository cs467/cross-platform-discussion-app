import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/app_connectivity.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/screens/signup_page.dart';
import 'package:disc/screens/password_reset.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:email_validator/email_validator.dart';

const timeout = const Duration(seconds: 5);
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

  String string;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  // @override
  // void initState() {
  //   super.initState();

  //   _connectivity.initialise();

  //   _connectivity.myStream.listen((source) {
  //     setState(() {
  //       _source = source;
  //       startTimeout(5000);
  //     });
  //   });
  // }

  startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    print("time out!");
    setState(() {});
    // callback function
    // _connectivity.myStream.listen((source) {
    //   _source = source;
    //   switch (_source.keys.toList()[0]) {
    //     case ConnectivityResult.none:
    //       string = "Offline";
    //       break;
    //     case ConnectivityResult.mobile:
    //       string = "Mobile: Online";
    //       break;
    //     case ConnectivityResult.wifi:
    //       string = "WiFi: Online";
    //   }
    // });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _connectivity.disposeStream();
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
    startTimeout();
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
    print("online? $string");

    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: (string == "Offline")
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Icon(
                        Icons.cloud_off,
                        color: Colors.black,
                        size: 108.0,
                      ),
                    ),
                    Container(
                      child: Text(
                        "No Internet",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        "Your device is not connected to the internet.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        "Check your WiFi or mobile data connection.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
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
                            _emailPasswordWidget(),
                            SizedBox(height: 20.0),
                            _submitButton(context),
                            SizedBox(height: 20.0),
                            _passwordReset(context),
                            _continue(context),
                            SizedBox(height: 10.0),
                            _signup(context)
                          ],
                        ),
                      ],
                    ),
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
                      ? 'Not a valid email.'
                      : null,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  errorText: _emailExist ? "Email does not exist" : null,
                  suffixIcon: emailController.text.length > 0
                      ? IconButton(
                          onPressed: () => emailController.clear(),
                          icon: Icon(Icons.clear, color: Colors.grey))
                      : null,
                  border: InputBorder.none,
                  hintText: 'Enter Email or Username',
                  fillColor: Color(0xfff3f3f4),
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
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var result;
        final form = _formKey.currentState;
        form.save();

        result = await usernameCheck(emailController.text);

        if (result != "None") {
          _usernameExist = false;
        }

        if (form.validate() || _usernameExist == false) {
          try {
            emailController.text = result;
            await Provider.of<AuthService>(context, listen: false).loginUser(
                email: emailController.text, password: passwordController.text);
            setState(() {
              _successfulLogin(context);

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
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0, 3),
                  blurRadius: 3,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight)),
        child: Text("LOGIN"),
      ),
    );
  }

  Widget _continue(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text('Continue without logging in?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ));
  }

  Widget _passwordReset(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          setState(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => PasswordPage()),
              (Route<dynamic> route) => true,
            );
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

  Widget _signup(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
            (Route<dynamic> route) => false,
          );
        },
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text('Click here to Sign Up',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ));
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/flutter.png', width: 100.0),
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
      email = "None";
    }
  }
  return email;
}
