import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'loginpage';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Text(
                'Login Information',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20.0),
              // TextFormField(
              //     onSaved: (value) => _email = value,
              //     keyboardType: TextInputType.emailAddress,
              //     decoration: InputDecoration(labelText: "Email Address")),
              // TextFormField(
              //     onSaved: (value) => _password = value,
              //     obscureText: true,
              //     decoration: InputDecoration(labelText: "Password")),
              _emailPasswordWidget(_email, _password),
              SizedBox(height: 20.0),
              _submitButton(context),
              // RaisedButton(
              //     child: Text("LOGIN"),
              //     onPressed: () {
              //       final form = _formKey.currentState;
              //       form.save();

              //       // Validate will return true if is valid, or false if invalid.
              //       if (form.validate()) {
              //         print("$_email $_password");
              //       }
              //     }),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _entryField(String title, String word, {bool isPassword = false}) {
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
              onSaved: (value) => word = value,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _emailPasswordWidget(String _email, String _password) {
    return Column(
      children: <Widget>[
        _entryField("Email id", _email),
        _entryField("Password", _password, isPassword: true),
      ],
    );
  }

Widget _submitButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: LinearGradient(
            colors: [Color(0xff2193b0), Color(0xff6dd5ed)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight
              )
              ),
      child: Text(
        'Login',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
  