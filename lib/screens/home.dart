import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:disc/screens/prompt.dart';
import 'package:disc/Widgets/drawer.dart';
import 'package:disc/Widgets/no_internet_access.dart';
import 'package:disc/singleton/app_connectivity.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class HomePage extends StatefulWidget {
  static const routeName = 'homepage';
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  int cSelect = 1;

  String string, timedString;
  var timer;
  var previousResult;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() {
        _source = source;
      });
    });
  }

  Timer startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    timer = Timer(duration, handleTimeout);
    return timer;
  }

  void handleTimeout() async {
    ConnectivityResult result = await (Connectivity().checkConnectivity());

    switch (result) {
      case ConnectivityResult.none:
        timedString = "Offline";
        break;
      case ConnectivityResult.mobile:
        timedString = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        timedString = "WiFi: Online";
    }

    if ((previousResult != result) && mounted) {
      setState(() {});
    }

    previousResult = result;
  }

  final ScrollController _scrollController = ScrollController();

  List<Widget> _buildExpansionTileChildren(int index) => [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('prompts')
                  .orderBy('number', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data.documents != null &&
                    snapshot.data.documents.length > 0) {
                  return Text(
                    snapshot.data.docs[index]['prompt'],
                    textAlign: TextAlign.left,
                  );
                }
                return CircularProgressIndicator();
              }),
        ),
        SizedBox(height: 15),
      ];

  Card _buildExpansionTile(int index) {
    return Card(
      child: ExpansionTile(
          key: Key(index.toString()),
          initiallyExpanded: index == selected,
          title: Text('Prompt ${index + 1}'),
          children: _buildExpansionTileChildren(index),
          onExpansionChanged: ((newState) {
            if (newState)
              setState(() {
                cSelect = index + 1;
                Duration(seconds: 20000);
                selected = index;
              });
            else
              setState(() {
                selected = -1;
              });
          })),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        string = "WiFi: Online";
    }

    startTimeout();
    if (string != timedString) {
      string = timedString;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: (string == "Offline")
          ? null
          : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (string == "Offline")
          ? null
          : FloatingActionButton.extended(
              label: Row(
                children: [
                  Icon(Icons.insert_comment),
                  SizedBox(
                    width: 5,
                  ),
                  Text('Join Discussion'),
                ],
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Prompt(
                          user: widget.title ?? "Disc $cSelect",
                          promptNumber: "$cSelect",
                          text: "Disc $cSelect")),
                );
              },
            ),
      appBar: AppBar(
        centerTitle: true,
        title: Text('Daychat'),
      ),
      endDrawer:
          (string == "Offline") ? null : DrawerWidget(title: widget.title),
      body: (string == "Offline")
          ? NoInternetAccess()
          : ListView.builder(
              key: Key('builder ${selected.toString()}'),
              controller: _scrollController,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) =>
                  _buildExpansionTile(
                index,
              ),
            ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
