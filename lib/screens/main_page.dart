import 'package:flutter/material.dart';
import 'add_response.dart';
import 'feedback_history.dart';

class MyHomePage extends StatelessWidget {

  final controller = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cross Platform Discussion App'),
      ),
      body: Center(
        child: PageView(
          controller: controller,
          children: <Widget>[
            AddResponse(),
            Container(
              child: Text("Main Screen")
            ),
            FeedbackHistory(),
          ],
        )
      ),
    );
  }
}