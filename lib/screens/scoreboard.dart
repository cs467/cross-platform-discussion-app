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
  String registrationDateTime;
  int userRank = 0;
  int userNum = 0;
//  List<bool> isSelected = [true, false];

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
                              flex: 5,
                              child: FractionallySizedBox(
                                widthFactor: 0.95,
                                child: Container(
                                  color: Colors.green[200],
                                  child: Center(
                                    child: Text(
                                      "placeholder"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 10,
                              child: FractionallySizedBox(                               
                                widthFactor: 0.95,
                                child: Container(
                                  color: Colors.orange[200],
                                  child: Center(
                                    child: Text(
                                      "placeholder"
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        child: Center(
                          child: Text(
                            "customized message"
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Your Rank'),
                    trailing: Text(userRank.toString() + '/' + userNum.toString()),
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    title: Text(
                      'Your Stats (all time)',
                      // style: TextStyle(
                      //   fontSize: 18.0,
                      //   fontWeight: FontWeight.bold
                      // ),
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
                        //.limit(20)
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
                // ToggleButtons(
                //   children: [
                //     Container(
                //       child: Text('Weekly'),
                //     ),
                //     Container(
                //       child: Text('All Time'),
                //     ),
                //   ],
                //   onPressed: (int index) {
                //     setState(() {
                //       for (int buttonIndex = 0;
                //           buttonIndex < isSelected.length;
                //           buttonIndex++) {
                //         if (buttonIndex == index) {
                //           isSelected[buttonIndex] = true;
                //         } else {
                //           isSelected[buttonIndex] = false;
                //         }
                //       }
                //     });
                //   },
                //   isSelected: isSelected,
                // )
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
