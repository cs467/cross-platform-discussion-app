import 'package:flutter/material.dart';
import 'package:disc/widgets/drawer.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

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
      button: true,
      enabled: true,
      onTapHint: 'Select an image',
      label: 'This button is used to send you to new entry screen',
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
  );
  }
}

Widget loginButton(BuildContext context) {
  return FloatingActionButton(
    tooltip: 'New Entry',
    child: Icon(Icons.add),
    onPressed: () {
      Navigator.pushNamed(context, 'loginpage');
    },
  );
}