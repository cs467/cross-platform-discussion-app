import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: MyApp(),
    theme: ThemeData.dark(),
  ));
}
