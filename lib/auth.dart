import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

// Used partial code from:
// https://morioh.com/p/e7f8d2c0fae3
class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use "as auth" on import if we end up using a User class.
  Future<User> getUser() async {
    User user = _auth.currentUser;
    return user;
  }

  Future signout() async {
    var result = FirebaseAuth.instance.signOut();
    notifyListeners();
    checkUser();
    return result;
  }

  Future createUser({String email, String password}) async {
    // Add code to create User
  }

  Future<User> loginUser({String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return result.user;
    } catch (e) {
      throw new FirebaseAuthException(code: e.code, message: e.message);
    }
  }

Future checkUser() async {
    notifyListeners();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

}
