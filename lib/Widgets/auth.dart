import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> getUser() async {
    User user = _auth.currentUser;
    return user;
  }

  Future signout() async {
    var result = FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }

  Future createUser({String username, String email, String password}) async {
    try {
      var result = FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((currentUser) => FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.user.uid)
        .set({
          "uid": currentUser.user.uid,
          "username": username,
          "email": email,
          "likes": 0,
          "streaks": 0,
          "flags": 0,
          "posts": 0,
          "registrationDateTime": DateTime.now().toUtc(),
        })
        );
      notifyListeners();
      return result;
    } catch (e) {
      throw new FirebaseAuthException(code: e.code, message: e.message);
    }
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

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
