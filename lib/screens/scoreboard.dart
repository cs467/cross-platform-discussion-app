import 'package:disc/models/rankTile.dart';
import 'package:disc/models/rankTileList.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Scoreboard extends StatefulWidget {
  final String username;
  Scoreboard({Key key, this.username}) : super(key: key);

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  int likes;
  int dislikes;
  int streaks;
  int flags;
  int posts;
  String registrationDateTime;
  int userRank = 0;
  int userNum = 0;
  List<bool> isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Hi, ' + widget.username),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: widget.username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          if (snapshot.hasData) {
            likes = snapshot.data.documents[0]['likes'];
            dislikes = snapshot.data.documents[0]['dislikes'];
            streaks = snapshot.data.documents[0]['streaks'];
            flags = snapshot.data.documents[0]['flags'];
            posts = snapshot.data.documents[0]['posts'];
            registrationDateTime = DateFormat('yMMMM').format(
                snapshot.data.documents[0]['registrationDateTime'].toDate());

            return ListView(
              children: [
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    'User since ' + registrationDateTime,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Your Level'),
                      ),
                      Container(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 6,
                              child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: Container(
                                  child: LevelIcon(posts: posts),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 10,
                              child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: Container(
                                  child: LevelTitle(posts: posts),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        child: LevelMessage(posts: posts),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Your Rank'),
                    trailing:
                        Text(userRank.toString() + '/' + userNum.toString()),
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    title: Text(
                      'Your Stats (all time)',
                    ),
                    children: [
                      Card(
                        child: ListTile(
                          title: Text('Likes'),
                          trailing: Text(likes.toString()),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Dislikes'),
                          trailing: Text(dislikes.toString()),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Flags'),
                          trailing: Text(flags.toString()),
                        ),
                      ),
                    ],
                    trailing: Icon(Icons.more_vert),
                  ),
                ),
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Text(
                    'All Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Center(
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(30),
                      children: [
                        Container(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            '            Posts            ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            '            Likes            ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        setState(() {
                          for (int buttonIndex = 0;
                              buttonIndex < isSelected.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                        });
                      },
                      isSelected: isSelected,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Rank',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Usename',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 3,
                      child: Container(),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.only(right: 15),
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Likes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('likes', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data.documents != null &&
                          snapshot.data.documents.length > 0) {
                        RankTileList rankList;
                        List<RankTile> ranks = List();
                        snapshot.data.documents
                            .forEach((user) => ranks.add(RankTile.fromMap({
                                  'uid': user['uid'],
                                  'username': user['username'],
                                  'likes': user['likes'],
                                })));
                        rankList = RankTileList(users: ranks);
                        int rankNum = 1;
                        int nextRankNum = 2;
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => setState(() {
                                  userNum = snapshot.data.documents.length;
                                }));

                        return Container(
                          child: ListView.builder(
                            itemCount: rankList.listLength,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: ((index != 0) &&
                                        (rankList
                                                .getEachEntry(index - 1)
                                                .userLikes ==
                                            rankList
                                                .getEachEntry(index)
                                                .userLikes))
                                    ? () {
                                        nextRankNum++;
                                        return Text((rankNum.toString()));
                                      }()
                                    : ((index == 0)
                                        ? Text((rankNum.toString()))
                                        : () {
                                            //int tempRank = nextrankNum;
                                            rankNum = nextRankNum;
                                            nextRankNum++;
                                            return Text((rankNum.toString()));
                                          }()),
                                title:
                                    rankList.getEachEntry(index).userUsername ==
                                            widget.username
                                        ? () {
                                            int tempRank = rankNum;
                                            // () {
                                            //   setState(() {
                                            //     userRank = rankNum;
                                            //   });
                                            // };
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) => setState(() {
                                                          userRank = tempRank;
                                                        }));
                                            return Text(rankList
                                                .getEachEntry(index)
                                                .userUsername);
                                          }()
                                        : Text(rankList
                                            .getEachEntry(index)
                                            .userUsername),
                                trailing: Text(rankList
                                    .getEachEntry(index)
                                    .userLikes
                                    .toString()),
                              );
                            },
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                
              ],
            );
            //   return Container(
            //       child: Column(
            //     children: [
            //       Flexible(
            //         fit: FlexFit.tight,
            //         flex: 1,
            //         child: Center(
            //           child: Text(
            //             "All Time Stats",
            //             style:
            //                 TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),
            //       Flexible(
            //         flex: 6,
            //         child: _buildGrid(createStatsList(likes, dislikes, streaks)),
            //       )
            //     ],
            //   ));
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

class LevelIcon extends StatelessWidget {
  const LevelIcon({Key key, this.posts,}) : super(key: key);
  final int posts;

  @override
  Widget build(BuildContext context) {
    String imagePath;
    if (posts < 25) {
      imagePath = 'assets/images/levels/hatching.png';
    } else if (posts < 50) {
      imagePath = 'assets/images/levels/plant_sun.png';
    } else if (posts < 100) {
      imagePath = 'assets/images/levels/earth.png';
    } else if (posts < 150) {
      imagePath = 'assets/images/levels/heart_border.png';
    } else if (posts < 200) {
      imagePath = 'assets/images/stars/orange_star.png';
    } else if (posts < 250) {
      imagePath = 'assets/images/stars/silver_star.png';
    } else {
      imagePath = 'assets/images/stars/gold_star.png';
    }

    return Center(
      child: Image.asset(imagePath),
    );
  }
}

class LevelTitle extends StatelessWidget {
  const LevelTitle({Key key, this.posts,}) : super(key: key);
  final int posts;

  @override
  Widget build(BuildContext context) {
    String title;
    if (posts < 25) {
      title = "Hello World";
    } else if (posts < 50) {
      title = "Nature-Green";
    } else if (posts < 100) {
      title = "Blue-Planet";
    } else if (posts < 150) {
      title = "Red-Hot";
    } else if (posts < 200) {
      title = "Bronze-Star";
    } else if (posts < 250) {
      title = "Silver-Star";
    } else {
      title = "Gold-Star";
    }
    return Center(
      child: Text(
        title,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class LevelMessage extends StatelessWidget {
  const LevelMessage({Key key, this.posts}) : super(key: key);
  final int posts;

  @override
  Widget build(BuildContext context) {
    String message;
    if (posts < 25) {
      message = "We're so glad you're here!";
    } else if (posts < 50) {
      message = "Let's grow further together!";
    } else if (posts < 100) {
      message = "It's getting bigger and bigger!";
    } else if (posts < 150) {
      message = "You're the heart of this community!";
    } else if (posts < 200) {
      message = "Yay, you've made it to the star level!";
    } else if (posts < 250) {
      message = "Thank you for inspiring all of us!";
    } else {
      message = "WOW, you are THE BEST of the best!!";
    }

    return Center(
      child: Text(
        message,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
