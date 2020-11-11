import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disc/screens/login_page.dart';
import 'package:provider/provider.dart';
import 'package:disc/Widgets/auth.dart';

class PasswordPage extends StatefulWidget {
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _emailExist = false;
  String _warning, email;

  TextEditingController emailController = new TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text("Reset Password"),
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
                        showAlert(),
                        _logo(context),
                        SizedBox(height: 20.0),
                         _emailField("Email"),
                        SizedBox(height: 20.0),
                        _submitButton(context),
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
                  errorText: _emailExist ? "Email does not exist" : null,
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
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
          if (emailController.text.isEmpty) {
            _buildErrorDialog(context, "Email is empty");
          } else {
            final valid = await emailCheck(emailController.text);

            if (valid) {
              setState(() {
                _emailExist = true;
              });
            } else {
              //_buildErrorDialog(context, "A password reset link has been sent to $email");
              await Provider.of<AuthService>(context, listen: false)
                  .resetPassword(emailController.text);
                  
              setState(() {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage(email: emailController.text)),
                  (Route<dynamic> route) => false,
                );
                email = emailController.text;
                _buildErrorDialog(context, "A password reset link has been sent to $email");
              });
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
        child: Text("RESET"),
      ),
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

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/flutter.png', width: 100.0),
    );
  }

  Widget showAlert() {
    if (_warning != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Container(
                child: Text(_warning),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _warning = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
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

