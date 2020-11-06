import 'package:flutter/material.dart';
import 'package:disc/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = 'signuppage';
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool submit;

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
          title: Text("Sign Up Page"),
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
        //_confirmPasswordField("Confirm Password", isPassword: true)
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
              //autofocus: true,
              controller: usernameController,
              obscureText: isPassword,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                 suffixIcon: usernameController.text.length > 0
                      ? IconButton(
                          onPressed: () => usernameController.clear(),
                          icon: Icon(Icons.cancel, color: Colors.grey))
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
                  hintText: 'Enter Email',
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

  // Widget _confirmPasswordField(String title, {bool isPassword = false}) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: <Widget>[
  //         Text(
  //           title,
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //         ),
  //         SizedBox(
  //           height: 10,
  //         ),
  //         TextFormField(
  //             controller: confirmPasswordController,
  //             obscureText: isPassword,
  //             keyboardType: TextInputType.name,
  //             decoration: InputDecoration(
  //                suffixIcon: confirmPasswordController.text.length > 0
  //                     ? IconButton(
  //                         onPressed: () => confirmPasswordController.clear(),
  //                         icon: Icon(Icons.cancel, color: Colors.grey))
  //                     : null,
  //                 border: InputBorder.none,
  //                 hintText: 'Confirm Password',
  //                 fillColor: Color(0xfff3f3f4),
  //                 filled: true))
  //       ],
  //     ),
  //   );
  // }

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final form = _formKey.currentState;
        form.save();

        if (form.validate()) {
          //if (passwordController.text == confirmPasswordController.text) {
            submit = true;
            try {
              User result =
                  await Provider.of<AuthService>(context, listen: false)
                      .createUser(
                          username: usernameController.text,
                          email: emailController.text,
                          password: passwordController.text);
              print(result);
            } on FirebaseAuthException catch (error) {
              return _buildErrorDialog(context, error.message);
            } on Exception catch (error) {
              return _buildErrorDialog(context, error.toString());
            }
          //} else {
            //_buildErrorDialog(context, "Passwords do not match");
          //}
        }

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
