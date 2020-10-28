import 'package:flutter/material.dart';
import 'package:disc/home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = 'loginpage';
  final GlobalKey<ScaffoldState> scaffoldKey;
  LoginPage({this.scaffoldKey});
  @override
  State<StatefulWidget> createState() => _LoginPageState(scaffoldKey);
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> scaffoldKey;
  _LoginPageState(this.scaffoldKey);

  String _password;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
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
        ),
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
              obscureText: isPassword,
              onSaved: (String value) {_email = value;},
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
              onSaved: (String value) {_password = value;},
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
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

  Widget _submitButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _formKey.currentState.save();
        //_performLogin();
        print("$_email $_password");
        // validateWithFirebase(_email, _password);
        // signIn();

        // Validate will return true if is valid, or false if invalid.
        // if (form.validate()) {
        //   print("$_email $_password");
        // }
      },
      child: Container(
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

  Widget _logo(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/flutter.png', width: 100.0),
    );
  }

  // void _performLogin() {
  //   var snackbar = SnackBar(
  //     content: Text('Email: $_email and Password $_password'),
  //   );
  //   Scaffold.of(context).showSnackBar(snackbar);
  // }
}
