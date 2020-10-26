import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddResponse extends StatelessWidget {
  final String userID = "z0gzldjEEk6bq1DKOVxl";
  final String responseText = "T is awesome. So is U!";

  @override
  Widget build(BuildContext context) {

    CollectionReference users = FirebaseFirestore.instance.collection('test_response_texts_prompt_5');

    Future<void> addResponse4() {
      return users
          .add({
            'userID': userID, 
            'response_text': responseText, 
            'likes': 0,
            'dislikes': 0,
            'flagged': false,
          })
          .then((value) => print("Res 4 Added"))
          .catchError((error) => print("Failed to add Res 4: $error"));
    }

    Future<void> addResponse5() {
      return users
          .add({
            'userID': userID, 
            'response_text': responseText, 
            'likes': 0,
            'dislikes': 0,
            'flagged': false,
          })
          .then((value) => print("Res 5 Added"))
          .catchError((error) => print("Failed to add Res 5: $error"));
    }

    return Column(
      children: [
        FlatButton(
          onPressed: addResponse4,
          child: Text(
            "Add Response 4",
          ),
        ),
        FlatButton(
          onPressed: addResponse5,
          child: Text(
          "Add Response 5",
          ),
        )
      ],
    );
  }
}
