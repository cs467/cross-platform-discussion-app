import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/screens/signup_page.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'loginpage';
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Login Page"),
        ),
        body: Align(
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
        ));
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _emailField("Username"),
        _passwordField("Password", isPassword: true),
      ],
    );
  }

  // I should be able to make these two one Widget but I cannot
  // figure out how to save both values onSaved.
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
                  suffixIcon: emailController.text.length > 0
                      ? IconButton(
                          onPressed: () => emailController.clear(),
                          icon: Icon(Icons.cancel, color: Colors.grey))
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
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                suffixIcon: passwordController.text.length > 0
                      ? IconButton(
                          onPressed: () => passwordController.clear(),
                          icon: Icon(Icons.cancel, color: Colors.grey))
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
        final form = _formKey.currentState;
        form.save();

        if (form.validate()) {
          try {
            User result = await Provider.of<AuthService>(context, listen: false)
                .loginUser(
                    email: emailController.text,
                    password: passwordController.text);
            print(result);
          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message);
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString());
          }
        }
        setState(() {
          _successfulLogin(context);

          Provider.of<AuthService>(context, listen: false).getUser().then(
              (currentUser) => FirebaseFirestore.instance
                  .collection("users")
                  .doc(currentUser.uid)
                  .get()
                  .then(
                      (DocumentSnapshot result) => Navigator.pushAndRemoveUntil(
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
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black54,
                  offset: Offset(0, 0),
                  blurRadius: 5,
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
              child: Text('Forgot Password?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text('Continue without logging in?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ));
  }

  Widget _signup(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Basically this code removes all the routes below the chosen.
          // Prevents the back button from appearing on the home screen.
          // Source: https://rb.gy/iaxydk
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

// This will display the error message sent back from
// Firebase after attempting to login with invalid credentials.
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
