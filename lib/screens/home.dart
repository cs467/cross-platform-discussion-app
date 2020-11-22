import 'package:flutter/material.dart';
import 'package:disc/screens/prompt.dart';
import 'package:disc/screens/prompt_proposal.dart';
import 'package:disc/Widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'homepage';
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
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
                        user: widget.title ?? "Disc ${index + 1}",
                        promptNumber: "${index + 1}",
                        text: "Disc ${index + 1}"
                      )),
            );
          },
          label: widget.title != null ? Text('Join Discussion') : Text('Read Discussion'),
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
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
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
        leading: widget.title != null ? Padding(
          padding: EdgeInsets.only(left: 0),
          child: Icon(
            Icons.brightness_1_sharp,
            size: 7,
            color: Color(0xff00e676),
            ),
        ) : Padding(
          padding: EdgeInsets.only(left: 0),
          child: Icon(
            Icons.brightness_1_sharp,
            size: 7,
            color: Theme.of(context).primaryColor,
            ),
        ),
      ),
      endDrawer: DrawerWidget(title: widget.title),
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
