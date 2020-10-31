import 'package:flutter/material.dart';
import 'package:disc/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'loginpage';
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

// ScaffoldKey might be unnecessary.
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _password;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
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
                ],
              ),
            ],
          ),
        ),
      )
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
              obscureText: isPassword,
              keyboardType: TextInputType.emailAddress,
              onSaved: (String value) {
                _email = value;
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
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
              obscureText: isPassword,
              keyboardType: TextInputType.name,
              onSaved: (String value) {
                _password = value;
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
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
                .loginUser(email: _email, password: _password);
            //print(result);

          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message);
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString());
          }
        }
        setState(() {
          //_successfulLogin(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
          );
          _successfulLogin(context);
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
          // Basically this code removes all the routes below the chosen.
          // Prevents the back button from appearing on the home screen.
          // Source: https://rb.gy/iaxydk
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
