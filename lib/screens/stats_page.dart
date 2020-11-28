// Screen to display the user's stats (level, # of posts, likes, etc.) and all user ranking.
// source 1: https://stackoverflow.com/questions/57242651/using-fractionallysizedbox-in-a-row
// source 2: https://medium.com/flutter-community/flutter-expansion-collapse-view-fde9c51ac438
// source 3: https://stackoverflow.com/questions/55060998/how-to-continuously-check-internet-connect-or-not-on-flutter

import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/no_internet_access.dart';
import 'package:disc/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disc/models/rankTile.dart';
import 'package:disc/models/rankTileList.dart';
import 'package:disc/singleton/app_connectivity.dart';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

class StatsPage extends StatefulWidget {
  static const routeName = 'statspage';
  StatsPage({Key key}) : super(key: key);

  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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

  String string, timedString;
  var timer;
  var previousResult;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() {
        _source = source;
      });
    });
  }

  Timer startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    timer = Timer(duration, handleTimeout);
    return timer;
  }

  void handleTimeout() async {
    ConnectivityResult result = await (Connectivity().checkConnectivity());

    switch (result) {
      case ConnectivityResult.none:
        timedString = "Offline";
        break;
      case ConnectivityResult.mobile:
        timedString = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        timedString = "WiFi: Online";
    }

    if ((previousResult != result) && mounted) {
      setState(() {});
    }

    previousResult = result;
  }

  @override
  Widget build(BuildContext context) {
    final String username = ModalRoute.of(context).settings.arguments;

    switch (_source.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        string = "WiFi: Online";
    }

    startTimeout();
    if (string != timedString) {
      string = timedString;
    }

    return Scaffold(
      appBar: AppBar(
        leading: (string == "Offline")
            ? null
            : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(title: username)),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  height: 25,
                  width: 25,
                  child: Icon(
                    Icons.keyboard_arrow_left,
                  ),
                ),
              ),
        centerTitle: true,
        title: Text('Hi, ' + username),
      ),
      body: (string == "Offline")
        ? NoInternetAccess()
        : StreamBuilder(
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
                streaks = snapshot.data.documents[0]['streaks'];
                flags = snapshot.data.documents[0]['flags'];
                posts = snapshot.data.documents[0]['posts'];
                registrationDateTime = DateFormat('yMMMM').format(snapshot
                    .data.documents[0]['registrationDateTime']
                    .toDate());

                return ListView(
                  children: [
                    UserJoinMonthYear(registrationDateTime: registrationDateTime),
                    UserLevel(posts: posts),
                    UserRank(isSelected: isSelected, userRank: userRank, userNum: userNum),
                    UserStats(posts: posts, likes: likes, flags: flags),
                    AllUserRankingHeaderText(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: sortByPostsOrLikes(),
                    ),
                    Container(
                      height: 15,
                    ),
                    AllUserRankingTitleTexts(isSelected: isSelected),
                    isSelected[0] == true
                      ? StreamBuilder(
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
                              snapshot.data.documents.forEach(
                                  (user) => ranks.add(RankTile.fromMap({
                                        'uid': user['uid'],
                                        'username': user['username'],
                                        'posts': user['posts'],
                                      })));
                              rankList = RankTileList(users: ranks);
                              int rankNum = 1;
                              int nextRankNum = 2;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        userNum =
                                            snapshot.data.documents.length;
                                      }));

                              return Container(
                                child: ListView.builder(
                                  itemCount: rankList.listLength,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        leading: ((index != 0) &&
                                                (rankList
                                                        .getEachEntry(
                                                            index - 1)
                                                        .userPosts ==
                                                    rankList
                                                        .getEachEntry(index)
                                                        .userPosts))
                                            ? () {
                                                nextRankNum++;
                                                return Text(
                                                    (rankNum.toString()));
                                              }()
                                            : ((index == 0)
                                                ? Text((rankNum.toString()))
                                                : () {
                                                    rankNum = nextRankNum;
                                                    nextRankNum++;
                                                    return Text((rankNum
                                                        .toString()));
                                                  }()),
                                        title: rankList
                                                    .getEachEntry(index)
                                                    .userUsername ==
                                                username
                                            ? () {
                                                int tempRank = rankNum;
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback(
                                                        (_) => setState(() {
                                                              userRank =
                                                                  tempRank;
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
                      : StreamBuilder(
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
                              snapshot.data.documents.forEach(
                                  (user) => ranks.add(RankTile.fromMap({
                                        'uid': user['uid'],
                                        'username': user['username'],
                                        'likes': user['likes'],
                                      })));
                              rankList = RankTileList(users: ranks);
                              int rankNum = 1;
                              int nextRankNum = 2;
                              WidgetsBinding.instance
                                  .addPostFrameCallback((_) => setState(() {
                                        userNum =
                                            snapshot.data.documents.length;
                                      }));

                              return Container(
                                child: ListView.builder(
                                  itemCount: rankList.listLength,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        leading: ((index != 0) &&
                                                (rankList
                                                        .getEachEntry(
                                                            index - 1)
                                                        .userLikes ==
                                                    rankList
                                                        .getEachEntry(index)
                                                        .userLikes))
                                            ? () {
                                                nextRankNum++;
                                                return Text(
                                                    (rankNum.toString()));
                                              }()
                                            : ((index == 0)
                                                ? Text((rankNum.toString()))
                                                : () {
                                                    rankNum = nextRankNum;
                                                    nextRankNum++;
                                                    return Text((rankNum
                                                        .toString()));
                                                  }()),
                                        title: rankList
                                                    .getEachEntry(index)
                                                    .userUsername ==
                                                username
                                            ? () {
                                                int tempRank = rankNum;
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback(
                                                        (_) => setState(() {
                                                              userRank =
                                                                  tempRank;
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
                          }),
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

  Row sortByPostsOrLikes() {
    return Row(
      children: [
        SizedBox(width: 15),
        buildTappablePosts(),
        SizedBox(width: 15),
        buildTappableLikes(),
        SizedBox(width: 15),
      ],
    );
  }

  Expanded buildTappableLikes() {
    return Expanded(
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
                color: lSelected == true
                    ? Colors.grey[500]
                    : Colors.grey[200],
                width: 2.0),
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
    );
  }

  Expanded buildTappablePosts() {
    return Expanded(
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
              color: rSelected == true
                  ? Colors.grey[500]
                  : Colors.grey[200],
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
    );
  }
}

class AllUserRankingTitleTexts extends StatelessWidget {
  const AllUserRankingTitleTexts({
    Key key,
    @required this.isSelected,
  }) : super(key: key);

  final List<bool> isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RankText(),
        UsernameText(),
        Flexible(
          fit: FlexFit.tight,
          flex: 3,
          child: Container(),
        ),
        PostsOrLikesText(isSelected: isSelected),
      ],
    );
  }
}

class PostsOrLikesText extends StatelessWidget {
  const PostsOrLikesText({
    Key key,
    @required this.isSelected,
  }) : super(key: key);

  final List<bool> isSelected;

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
    );
  }
}

class UsernameText extends StatelessWidget {
  const UsernameText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
    );
  }
}

class RankText extends StatelessWidget {
  const RankText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
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
    );
  }
}

class AllUserRankingHeaderText extends StatelessWidget {
  const AllUserRankingHeaderText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        'All Users',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class UserStats extends StatelessWidget {
  const UserStats({
    Key key,
    @required this.posts,
    @required this.likes,
    @required this.flags,
  }) : super(key: key);

  final int posts;
  final int likes;
  final int flags;

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}

class UserRank extends StatelessWidget {
  const UserRank({
    Key key,
    @required this.isSelected,
    @required this.userRank,
    @required this.userNum,
  }) : super(key: key);

  final List<bool> isSelected;
  final int userRank;
  final int userNum;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Your Rank ' +
            (isSelected[0] == true ? '(Posts)' : '(Likes)')),
        trailing: Text(
          userRank.toString() + '/' + userNum.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class UserLevel extends StatelessWidget {
  const UserLevel({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final int posts;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                LevelIconHolder(posts: posts),
                LevelTitleHolder(posts: posts),
              ],
            ),
          ),
          Container(
            height: 50,
            child: LevelMessage(posts: posts),
          ),
        ],
      ),
    );
  }
}

class LevelTitleHolder extends StatelessWidget {
  const LevelTitleHolder({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final int posts;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 10,
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: Container(
          child: LevelTitle(posts: posts),
        ),
      ),
    );
  }
}

class LevelIconHolder extends StatelessWidget {
  const LevelIconHolder({
    Key key,
    @required this.posts,
  }) : super(key: key);

  final int posts;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 6,
      child: FractionallySizedBox(
        widthFactor: 0.95,
        child: Container(
          child: LevelIcon(posts: posts),
        ),
      ),
    );
  }
}

class UserJoinMonthYear extends StatelessWidget {
  const UserJoinMonthYear({
    Key key,
    @required this.registrationDateTime,
  }) : super(key: key);

  final String registrationDateTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        'User since ' + registrationDateTime,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class LevelIcon extends StatelessWidget {
  const LevelIcon({
    Key key,
    this.posts,
  }) : super(key: key);
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
  const LevelTitle({
    Key key,
    this.posts,
  }) : super(key: key);
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
