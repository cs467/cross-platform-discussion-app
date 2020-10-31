import 'package:flutter/material.dart';
import 'package:disc/screens/prompt.dart';
import 'package:disc/Widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'homepage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                        text: "Disc ${index + 1}",
                        promptNumber: "${index + 1}",
                      )),
            );
          },
          label: Text('Join Discussion'),
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
    return Scaffold(
      //resizeToAvoidBottomPadding: 
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Disc'),
      ),
      endDrawer: DrawerWidget(),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) => _buildExpansionTile(
          index,
        ),
      ),
    );
  }
}
