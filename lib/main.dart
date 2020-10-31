import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/Widgets/auth.dart';
import 'package:disc/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Tip to make sure Firebase was initialized (4th example):
  // https://rb.gy/e7kpxj
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
          return GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild.unfocus();
              }
            },
            child: MaterialApp(
              theme: theme,
              routes: routes,
              home: FutureBuilder<User>(
                future:
                    Provider.of<AuthService>(context, listen: false).getUser(),
                builder: (context, AsyncSnapshot<User> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.hasData ? HomePage() : LoginPage();
                  } else {
                    return Center(
                      child: Container(
                        child: CircularProgressIndicator(),
                        alignment: Alignment(0.0, 0.0),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        });
  }
}
