import 'dart:async';

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disc/screens/login_page.dart';
import 'package:disc/Widgets/auth.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key key, this.title}) : super(key: key); 
  final String title;
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _mode = false;
  _DrawerWidgetState();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            height: 50,
            child: DrawerHeader(child: Text('Settings')),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _mode,
            onChanged: (bool value) {
              setState(() {
                _mode = value;
                changeBrightness(context);
              });
            },
          ),
          _signInSignOut(context),
          widget.title != null
          ? ListTile(
              title: const Text('See Your Stats'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('statspage', arguments: widget.title);
              },
            ) 
          : Container(),
        ],
      ),
    );
  }

  Widget _signInSignOut(BuildContext context) {
    return Column(
      children: [
        widget.title == null ? ListTile(
          title: const Text('Log In or Sign Up'),
          onTap: () async {
            setState(() {
              Navigator.pushReplacementNamed(context, 'loginpage');
            });
          },
        ) : Container(),
        widget.title != null ? ListTile(
          title: const Text('Sign Out'),
          onTap: () async {
            try {
              await Provider.of<AuthService>(context, listen: false).signout();
            } on FirebaseAuthException catch (error) {
              return _buildErrorDialog(context, error.message);
            } on Exception catch (error) {
              return _buildErrorDialog(context, error.toString());
            }
            setState(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
              _successfulSignout(context);
            });
          },
        ) : Container(),
      ],
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

changeBrightness(BuildContext context) {
  DynamicTheme.of(context).setBrightness(
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark);
}

Future _successfulSignout(BuildContext context) {
  return showDialog(
    builder: (context) {
      return AlertDialog(
        title: Text('Sign Out Success'),
        content:
            SingleChildScrollView(child: Text('You are no longer signed in.')),
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