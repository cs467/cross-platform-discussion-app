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
        color: Colors.green[200],
        child: Center(
          child: Text(
            "25 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (likes >= 50) {
    statsList.add(
      Container(
        color: Colors.blue[200],
        child: Center(
          child: Text(
            "50 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (likes >= 100) {
    statsList.add(
      Container(
        color: Colors.red[300],
        child: Center(
          child: Text(
            "100 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (likes >= 150) {
    statsList.add(
      Container(
        color: Colors.brown[300],
        child: Center(
          child: Text(
            "150 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (likes >= 200) {
    statsList.add(
      Container(
        color: Colors.grey[400],
        child: Center(
          child: Text(
            "200 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (likes >= 250) {
    statsList.add(
      Container(
        color: Colors.amber,
        child: Center(
          child: Text(
            "250 Likes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (streaks >= 25) {
    statsList.add(
      Container(
        color: Colors.green[200],
        child: Center(
          child: Text(
            "25 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (streaks >= 50) {
    statsList.add(
      Container(
        color: Colors.blue[200],
        child: Center(
          child: Text(
            "50 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (streaks >= 100) {
    statsList.add(
      Container(
        color: Colors.red[300],
        child: Center(
          child: Text(
            "100 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (streaks >= 150) {
    statsList.add(
      Container(
        color: Colors.brown[300],
        child: Center(
          child: Text(
            "150 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

    if (streaks >= 200) {
    statsList.add(
      Container(
        color: Colors.grey[400],
        child: Center(
          child: Text(
            "200 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

    if (streaks >= 250) {
    statsList.add(
      Container(
        color: Colors.amber,
        child: Center(
          child: Text(
            "250 Posting Day Streaks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  if (dislikes < 10) {
    statsList.add(
      Container(
        color: Colors.pink[200],
        child: Center(
          child: Text(
            "Less than 10 dislikes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  return statsList;
}

Widget _buildGrid(List<Container> statsList) => GridView.extent(
        maxCrossAxisExtent: 100,
        padding: const EdgeInsets.all(15),
        mainAxisSpacing: 50,
        crossAxisSpacing: 50,
        children: statsList,
);