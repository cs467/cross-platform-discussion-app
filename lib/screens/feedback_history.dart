import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var likes;
var dislikes;
var streaks;

class FeedbackHistory extends StatelessWidget {
  final String username;
  FeedbackHistory({Key key, this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Hi, ' + username),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.hasData) {
            likes = snapshot.data.documents[0]['likes'];
            dislikes = snapshot.data.documents[0]['dislikes'];
            streaks = snapshot.data.documents[0]['streaks'];

            return Container(
                child: Column(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Center(
                    child: Text(
                      "All Time Stats",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Flexible(
                  flex: 6,
                  child: _buildGrid(createStatsList(likes, dislikes, streaks)),
                )
              ],
            ));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
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
            Image.asset('assets/images/crowns/green_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "25 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/crowns/blue_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "50 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/crowns/red_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "100 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/crowns/brown_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "150 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/crowns/silver_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "200 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/crowns/gold_crown.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "250 Likes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/green_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "25 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/blue_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "50 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/red_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "100 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/orange_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "150 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/silver_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "200 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
            Image.asset('assets/images/stars/gold_star.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "250 Streaks",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if ((dislikes / likes) < 0.05) {
    statsList.add(
      Container(
        child: Column(
          children: [
            Image.asset('assets/images/faces/sunglasses.png'),
            FittedBox(
              fit: BoxFit.contain,
              child: Text(
                "Few dislikes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return statsList;
}

Widget _buildGrid(List<Container> statsList) => GridView.extent(
      maxCrossAxisExtent: 150,
      padding: const EdgeInsets.all(0),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: statsList,
    );
