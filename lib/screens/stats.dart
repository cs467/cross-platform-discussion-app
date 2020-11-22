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
  int streaks;
  int flags;
  int posts;
  String registrationDateTime;
  int userRank = 0;
  int userNum = 0;
  List<bool> isSelected = [true, false];
bool rSelected = true, lSelected = false;
  String sort = "timeStamp";

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
                    title: Text('Your Rank ' + (isSelected[0] == true ? '(Posts)' : '(Likes)')),
                    trailing:
                        Text(
                          userRank.toString() + '/' + userNum.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                          title: Text('Posts'),
                          trailing: Text(posts.toString()),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text('Likes'),
                          trailing: Text(likes.toString()),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            isSelected[0] = true;
                            isSelected[1] = false;
                            rSelected = true;
                            lSelected = false;
                            setState(() {});
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: rSelected == true ? Colors.grey[500] : Colors.grey[200], 
                                  width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Posts",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            isSelected[1] = true;
                            isSelected[0] = false;
                            rSelected = false;
                            lSelected = true;
                            setState(() {});
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: new BorderSide(
                                color: lSelected == true ? Colors.grey[500] : Colors.grey[200],
                                width: 2.0
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Likes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ),
                Container(height: 15,),
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
                          'Username',
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
                          isSelected[0] == true ? 'Posts' : 'Likes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                isSelected[0] == true 
                ?
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .orderBy('posts', descending: true)
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
                                  'posts': user['posts'],
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
                              return Card(
                                child: ListTile(
                                  leading: ((index != 0) &&
                                          (rankList
                                                  .getEachEntry(index - 1)
                                                  .userPosts ==
                                              rankList
                                                  .getEachEntry(index)
                                                  .userPosts))
                                      ? () {
                                          nextRankNum++;
                                          return Text((rankNum.toString()));
                                        }()
                                      : ((index == 0)
                                          ? Text((rankNum.toString()))
                                          : () {
                                              rankNum = nextRankNum;
                                              nextRankNum++;
                                              return Text((rankNum.toString()));
                                            }()),
                                  title:
                                      rankList.getEachEntry(index).userUsername ==
                                              widget.username
                                          ? () {
                                              int tempRank = rankNum;
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
                                      .userPosts
                                      .toString()),
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    })
                    :
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
                              return Card(
                                child: ListTile(
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
                                              rankNum = nextRankNum;
                                              nextRankNum++;
                                              return Text((rankNum.toString()));
                                            }()),
                                  title:
                                      rankList.getEachEntry(index).userUsername ==
                                              widget.username
                                          ? () {
                                              int tempRank = rankNum;
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
                                ),
                              );
                            },
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    })
                    ,               
              ],
            );
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
      title = "Hello-World";
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