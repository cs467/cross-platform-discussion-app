import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/app_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:disc/screens/prompt.dart';
import 'package:disc/screens/prompt_proposal.dart';
import 'package:disc/Widgets/drawer.dart';
//import 'package:disc/singleton/ConnectionStatusSingleton.dart';

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
  // StreamSubscription _connectionChangeStream;

  // bool isOffline;

  // @override
  // initState() {
  //   super.initState();

  //   ConnectionStatusSingleton connectionStatus =
  //       ConnectionStatusSingleton.getInstance();
  //   isOffline = !connectionStatus.hasConnection;
  //   _connectionChangeStream =
  //       connectionStatus.connectionChange.listen(connectionChanged);
  // }

  // void connectionChanged(dynamic hasConnection) {
  //   setState(() {
  //     isOffline = !hasConnection;
  //   });
  // }
  String string;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  @override
  void initState() {
    super.initState();

    _connectivity.initialise();

    _connectivity.myStream.listen((source) {
      setState(() {
        _source = source;
        startTimeout(5000);
      });
    });
  }

  startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, handleTimeout);
  }

  void handleTimeout() {
    // callback function
    _connectivity.myStream.listen((source) {
      _source = source;
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
    });
  }

  final ScrollController _scrollController = ScrollController();

  void _scrollToSelectedContent(
      bool isExpanded, double previousOffset, int index, GlobalKey myKey) {}

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
                    textAlign: TextAlign.justify,
                  );
                }
                return CircularProgressIndicator();
              }),
        ),
        SizedBox(height: 15),
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Prompt(
                      user: widget.title ?? "Disc ${index + 1}",
                      promptNumber: "${index + 1}",
                      text: "Disc ${index + 1}")),
            );
          },
          label: widget.title != null
              ? Text('Join Discussion')
              : Text('Read Discussion'),
          icon: Icon(Icons.insert_comment),
        ),
        SizedBox(height: 25),
      ];

  ExpansionTile _buildExpansionTile(int index) {
    final GlobalKey expansionTileKey = GlobalKey();
    double previousOffset;

    return ExpansionTile(
      key: expansionTileKey,
      onExpansionChanged: (isExpanded) {
        if (isExpanded) previousOffset = _scrollController.offset;
        _scrollToSelectedContent(
            isExpanded, previousOffset, index, expansionTileKey);
      },
      title: Text('Prompt ${index + 1}'),
      children: _buildExpansionTileChildren(index),
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
    print("online? $string");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (string == "Offline")
          ? null
          : FloatingActionButton.extended(
              label: Text('Submit a Prompt'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PromptProposal(user: widget.title)),
                );
              },
            ),
      appBar: AppBar(
        title: Text('Home Page'),
        leading: widget.title != null
            ? Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.bolt,
                  color: Color(0xff00e676),
                ),
              )
            : Container(),
      ),
      endDrawer: DrawerWidget(title: widget.title),
      body: (string == "Offline")
          ? Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Icon(
                        Icons.cloud_off,
                        color: Colors.black,
                        size: 108.0,
                      ),
                    ),
                    Container(
                      child: Text(
                        "No Internet",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Container(
                      child: Text(
                        "Your device is not connected to the internet.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        "Check your WiFi or mobile data connection.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
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
    _connectivity.disposeStream();
    super.dispose();
  }
}
