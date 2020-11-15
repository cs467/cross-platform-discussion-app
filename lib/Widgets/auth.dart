import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

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
    //checkUser();
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
            "dislikes": 0,
            "streaks": 0,
            "flags": 0,
            "posts": 0,
            "registrationDateTime": DateTime.now().toUtc(),//.toString(),
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

// Used for Testing
// Future checkUser() async {
//     //notifyListeners();
//     FirebaseAuth.instance.authStateChanges().listen((User user) {
//       if (user == null) {
//         print('User is currently signed out!');
//       } else {
//         print('User is signed in!');
//       }
//     });
//   }

}
