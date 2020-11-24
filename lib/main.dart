import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:disc/screens/login_page.dart';
import 'package:disc/screens/signup_page.dart';
import 'package:disc/screens/splash.dart';

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
    LoginPage.routeName: (context) => LoginPage(),
    HomePage.routeName: (context) => HomePage(),
    SignUpPage.routeName: (context) => SignUpPage()
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
