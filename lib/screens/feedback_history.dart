import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var likes;
var dislikes;
var streaks;

class FeedbackHistory extends StatelessWidget {
  
  //currently, just hard-coding the Document ID of a specific user in Firebase
  final String documentId = "CDrU6W1jBHICyAoQ34X2";

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection('test_user_collection');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();
          likes = data['likesTotal'];
          dislikes = data['dislikesTotal'];
          streaks = data['posting_streak_days'];
          
          return Container(
            child: Column(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Center(
                    child: Text(
                      "All Time Stats",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: _buildGrid(createStatsList(likes, dislikes, streaks)),
                )
              ],
            )
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

List<Container> createStatsList(int likes, int dislikes, int streaks) {
  List<Container> statsList = List();
  statsList.length = 0;

  if (likes >= 25) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/green_crown.png'),
            Text(
              "25 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (likes >= 50) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/blue_crown.png'),
            Text(
              "50 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (likes >= 100) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/red_crown.png'),
            Text(
              "100 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (likes >= 150) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/brown_crown.png'),
            Text(
              "150 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (likes >= 200) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/silver_crown.png'),
            Text(
              "200 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (likes >= 250) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/crowns/gold_crown.png'),
            Text(
              "250 Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],  
        ),
      ),
    );
  }

  if (streaks >= 25) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/smiling.png'),
            Text(
              "25 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  if (streaks >= 50) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/sunglasses.png'),
            Text(
              "50 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  if (streaks >= 100) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/big_eyes.png'),
            Text(
              "100 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  if (streaks >= 150) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/heart_eyes.png'),
            Text(
              "150 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

    if (streaks >= 200) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/star_eyes.png'),
            Text(
              "200 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

    if (streaks >= 250) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/faces/partying.png'),
            Text(
              "250 Streaks",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  if (dislikes < 10) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/cats/kissing_cat.png'),
            Text(
              "Few dislikes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  return statsList;
}

Widget _buildGrid(List<Container> statsList) => GridView.extent(
        maxCrossAxisExtent: 130,
        padding: const EdgeInsets.all(0),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: statsList,
);