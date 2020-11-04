import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  initState() {
    Provider.of<AuthService>(context, listen: false)
        .getUser()
        .then((currentUser) => {
              if (currentUser == null)
                {Navigator.pushReplacementNamed(context, "loginpage")}
              else
                {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(currentUser.uid)
                      .get()
                      .then((DocumentSnapshot result) =>
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                        title: result["username"],
                                      ))))
                      .catchError((err) => print(err))
                }
            })
        .catchError((err) => print(err));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Center(
            child: Container(
              child: CircularProgressIndicator(),
              alignment: Alignment(0.0, 0.0),
            ),
          ),
        ),
      ),
    );
  }
}
