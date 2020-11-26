import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:disc/screens/login_page.dart';
import 'package:disc/screens/origin.dart';
import 'package:disc/screens/signup_page.dart';
import 'package:disc/screens/stats_page.dart';
import 'package:disc/screens/splash.dart';
import 'package:disc/screens/password_reset.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider<AuthService>(
      child: MyApp(),
      create: (context) => AuthService(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final routes = {
    OriginPage.routeName: (context) => OriginPage(),
    LoginPage.routeName: (context) => LoginPage(),
    HomePage.routeName: (context) => HomePage(),
    SignUpPage.routeName: (context) => SignUpPage(),
    StatsPage.routeName: (context) => StatsPage(),
    PasswordPage.routeName: (context) => PasswordPage(),
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
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild.unfocus();
              }
            },
            child:
                MaterialApp(theme: theme, routes: routes, home: SplashPage()),
          );
        });
  }
}
