import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:provider/provider.dart';
import './Widgets/auth.dart';
import './screens/home.dart';
import './screens/login_page.dart';
import './screens/feedback_history.dart';

void main() async {
  // Tip to make sure Firebase was initialized (4th example): 
  // https://rb.gy/e7kpxj
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider<AuthService>(
      child: MyApp(),
      create: (BuildContext context) {
        return AuthService();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  static final routes = {
    //FeedbackHistory.routeName: (context) => FeedbackHistory(),
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
            home: HomePage(),
          );
        });
  }
}
