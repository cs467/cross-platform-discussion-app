import 'package:flutter/material.dart';
import '../screens/prompt.dart';
import 'package:disc/widgets/drawer.dart';

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
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            textAlign: TextAlign.justify,
          ),
        ),
        SizedBox(height: 15),
        FloatingActionButton.extended(
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
