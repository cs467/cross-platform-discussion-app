import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackHistory extends StatefulWidget {
  @override
  _FeedbackHistoryState createState() => _FeedbackHistoryState();
}

class _FeedbackHistoryState extends State<FeedbackHistory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Center(
              child: Text(
                "Feedback History",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Flexible(
            flex: 6,
            child: _buildGrid(),
          )
        ],
      )
    );
  }
}

Widget _buildGrid() => GridView.extent(
    maxCrossAxisExtent: 100,
    padding: const EdgeInsets.all(15),
    mainAxisSpacing: 50,
    crossAxisSpacing: 50,
    children: [
      Placeholder(), Placeholder(), Placeholder(), Placeholder(), Placeholder(),
      Placeholder(), Placeholder(), Placeholder(), Placeholder(), Placeholder(),
      Placeholder(), Placeholder(), Placeholder(), Placeholder(), Placeholder(),
    ]
);