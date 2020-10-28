import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:disc/login_page.dart';
import 'package:disc/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final routes = {
    LoginPage.routeName: (context) => LoginPage(),
    HomePage.routeName: (context) => HomePage()
  };

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        primarySwatch: Colors.blueGrey,
        brightness: brightness,
      ),
    themedWidgetBuilder: (context, theme) {
      return MaterialApp(
        theme: theme,
        routes: routes,
      );
    });
  }
}
