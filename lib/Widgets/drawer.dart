import 'dart:async';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home.dart';
import 'auth.dart';

changeBrightness(BuildContext context) {
  DynamicTheme.of(context).setBrightness(
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark);
}

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _mode = false;

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
            secondary: const Icon(Icons.lightbulb_outline),
          ),
          ListTile(
            title: const Text('Log In or Sign Up'),
            onTap: () {
              setState(() {
                Navigator.pushReplacementNamed(context, 'loginpage');
              });
            },
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () async {
              if (1 == 1) {
                  try {
                    User result =
                        await Provider.of<AuthService>(context, listen: false)
                            .signout();
                    print(result);
                  } on FirebaseAuthException catch (error) {
                    return _buildErrorDialog(context, error.message);
                  } on Exception catch (error) {
                    return _buildErrorDialog(context, error.toString());
                  }
                }
              setState(() {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              });
            },
          ),
        ],
      ),
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
        content: Text(_message),
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
