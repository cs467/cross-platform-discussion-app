import 'package:flutter/material.dart';
import 'package:disc/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'homepage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    appBar: AppBar(
      title: Text('Home Screen'),
    ),
    endDrawer: DrawerWidget(),
    bottomNavigationBar: BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 50.0,
      ),
    ),
    floatingActionButton: Semantics(
      child: loginButton(context),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  );
  }
}

Widget loginButton(BuildContext context) {
  return FloatingActionButton(
    tooltip: 'Login',
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.pushNamed(context, 'loginpage');
    },
  );
}