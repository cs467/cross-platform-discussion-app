import 'package:flutter/material.dart';
import 'package:disc/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    confirmPasswordController.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Register"),
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
                        _textFieldWidget(),
                        SizedBox(height: 20.0),
                        _submitButton(context),
                        SizedBox(height: 20.0),
                        _continue(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/flutter.png', width: 100.0),
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
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _emailField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: usernameController.text.length > 0 ||
              emailController.text.length > 0
          ? Column(
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
                    textInputAction: TextInputAction.next,
                    validator: (val) => !EmailValidator.validate(val, true)
                        ? 'Not a valid email.'
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
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            )
          : Container(),
    );
  }

  Widget _passwordField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: emailController.text.length > 0 ||
              passwordController.text.length > 0
          ? Column(
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
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            )
          : Container(),
    );
  }

  Widget _confirmPasswordField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: passwordController.text.length > 0 ||
              confirmPasswordController.text.length > 0
          ? Column(
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
                                onPressed: () =>
                                    confirmPasswordController.clear(),
                                icon: Icon(Icons.clear, color: Colors.grey))
                            : null,
                        border: InputBorder.none,
                        hintText: 'Confirm Password',
                        fillColor: Color(0xfff3f3f4),
                        filled: true))
              ],
            )
          : Container(),
    );
  }

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final form = _formKey.currentState;
        form.save();

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
              /******
           * If I clear here, they clear before routing title to new page.
           *****/
              // usernameController.clear();
              // emailController.clear();
              // passwordController.clear();
              //_successfulLogin(context);
            });
          } on FirebaseAuthException catch (error) {
            return _buildErrorDialog(context, error.message);
          } on Exception catch (error) {
            return _buildErrorDialog(context, error.toString());
          }
        }
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
        child: Text("SIGN UP"),
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
}

//Function to check username
Future<bool> usernameCheck(String username) async {
  final result = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isEqualTo: username)
      .get();
  return result.docs.isEmpty;
}
