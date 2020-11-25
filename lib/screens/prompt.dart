import 'package:connectivity/connectivity.dart';
import 'package:disc/Widgets/no_internet_access.dart';
import 'package:disc/screens/home.dart';
import 'package:disc/singleton/app_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:profanity_filter/profanity_filter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'dart:async';

const timeout = const Duration(seconds: 3);
const ms = const Duration(milliseconds: 1);

// ignore: must_be_immutable
class Prompt extends StatefulWidget {
  String text;
  String promptNumber;
  String user;
  Prompt({Key key, @required this.text, @required this.promptNumber, this.user})
      : super(key: key);

  @override
  _PromptState createState() => _PromptState();
}

class _PromptState extends State<Prompt> {
  var sort = "timeStamp";
  bool rSelected = true, lSelected = false;

  TextEditingController postController = new TextEditingController();

  Timer _timer;
  DateTime now = DateTime.now();

  String string, timedString;
  var timer;
  var previousResult;

  Map _source = {ConnectivityResult.none: false};
  AppConnectivity _connectivity = AppConnectivity.instance;

  @override
  void initState() {
    _timer = Timer.periodic(
      Duration(seconds: 5),
      (Timer t) => setState(() {}),
    );

    super.initState();
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      setState(() { _source = source;});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    timer.cancel();
    super.dispose();
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

  Widget build(BuildContext context) {
    String startsWith =
        DateTime(now.year, now.month, now.day).toUtc().toString();

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

    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text('${widget.text}'),
            leading: (string == "Offline")
            ? null
            : (!widget.user.contains("Disc")
                  ? BackButton(
                    color:  Color(0xffffffff),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(title: widget.user)
                        ),
                        (Route<dynamic> route) => false,
                      );
                    })
                  : BackButton(
                    color: Color(0xffffffff),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(title: widget.user)
                        ),
                        (Route<dynamic> route) => false,
                      );
                    })
              )
          ),
          body:  (string == "Offline")
          ? NoInternetAccess()
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts${widget.promptNumber}')
                  .orderBy(sort, descending: true)
                  .where(sort, isGreaterThan: startsWith)
                  .snapshots(),
                  //rSelected == true ?
                  // FirebaseFirestore.instance
                  // .collection('posts${widget.promptNumber}')
                  // .orderBy('timeStamp', descending: true)
                  // .where('timeStamp', isGreaterThan: startsWith)
                  // .orderBy('likes', descending: true)
                  // .snapshots(),
              builder: (content, snapshot) {
                if (snapshot.hasData && snapshot.data.documents != null) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 0, left: 10, right: 10),
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                              color: Colors.transparent,
                              width: 2,
                            )),
                            child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('prompts')
                                        .orderBy('number', descending: false)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data.documents != null &&
                                          snapshot.data.documents.length > 0) {
                                        return Text(
                                          snapshot.data.docs[
                                              int.parse(widget.promptNumber) -
                                                  1]['prompt'],
                                          textAlign: TextAlign.justify,
                                        );
                                      }
                                      return CircularProgressIndicator();
                                    })),
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
                                sort = "timeStamp";
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
                                      width: 2.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Recent"),
                                )),
                              ),
                            )),
                            SizedBox(width: 15),
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                sort = "likes";
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
                                    child: Text("Likes"),
                                  ))),
                            )),
                            SizedBox(width: 15),
                          ],
                        ),
                      ),
                      SizedBox(height: 0),
                      showChat(snapshot),
                      SizedBox(height: 5),
                      response(),
                      SizedBox(height: 5)
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                      SizedBox(height: 300),
                    ],
                  );
                }
              }),
        ));
  }

  Widget showChat(AsyncSnapshot<dynamic> snapshot) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200],
                  width: 2,
                ),
                top: BorderSide(
                  color: Colors.grey[200],
                  width: 2,
                ))),
        child: ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              if (snapshot.data.documents.length > 0) {
                var post = snapshot.data.documents[index];
                var info = PromptPost();
                info.name = post['name'];
                info.body = post['body'];
                info.likes = post['likes'];
                info.likedBy = post['likedBy'];
                info.flags = post['flags'];
                info.flaggedBy = post['flaggedBy'];

                // final AsyncSnapshot<dynamic> ds = snapshot.data;
                // final Map<String, dynamic> Function() map = ds.data;

                //print(snapshot.data);
                
                DateTime todayDate = DateTime.parse(post['timeStamp']);

                return Semantics(
                  button: true,
                  enabled: true,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('prompts')
                          .orderBy('number', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        //flag filter number
                        if (info.flags < 1) {
                          if (snapshot.hasData &&
                              snapshot.data.documents != null &&
                              snapshot.data.documents.length > 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: Card(
                                //elevation: 2,
                                //color: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Colors.transparent,
                                    width: 2,
                                  )),
                                  child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actionExtentRatio: 0.25,
                                    child: Container(
                                      color: Colors.transparent,
                                      child: ListTile(
                                        onTap: () async {
                                          if (info.likedBy
                                              .contains(widget.user)) {
                                            FirebaseFirestore.instance
                                                .collection(
                                                    "posts${widget.promptNumber}")
                                                .doc(post.documentID)
                                                .update({
                                              "likes": info.likes - 1,
                                              "likedBy": FieldValue.arrayRemove(
                                                  [widget.user]),
                                            }).then((value) {
                                              postController.clear();
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .where('username',
                                                    isEqualTo: info.name)
                                                .get()
                                                .then((value) {
                                              int curLikes =
                                                  value.docs[0].get('likes');
                                              String curUid =
                                                  value.docs[0].get('uid');
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(curUid)
                                                  .update({
                                                "likes": curLikes - 1,
                                              });
                                            });
                                          } else {
                                            FirebaseFirestore.instance
                                                .collection(
                                                    "posts${widget.promptNumber}")
                                                .doc(post.documentID)
                                                .update({
                                              "likes": info.likes + 1,
                                              "likedBy": FieldValue.arrayUnion(
                                                  [widget.user]),
                                            }).then((value) {
                                              postController.clear();
                                            });
                                            FirebaseFirestore.instance
                                                .collection('users')
                                                .where('username',
                                                    isEqualTo: info.name)
                                                .get()
                                                .then((value) {
                                              int curLikes =
                                                  value.docs[0].get('likes');
                                              String curUid =
                                                  value.docs[0].get('uid');
                                              FirebaseFirestore.instance
                                                  .collection("users")
                                                  .doc(curUid)
                                                  .update({
                                                "likes": curLikes + 1,
                                              });
                                            });
                                          }

                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);

                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                        },
                                        leading: Column(
                                          children: [
                                            SizedBox(height: 5),
                                            Icon(
                                              Icons.favorite,
                                              color: info.likedBy
                                                      .contains(widget.user)
                                                  ? Colors.red[300]
                                                  : Colors.grey,
                                              size: 24.0,
                                              semanticLabel: null,
                                            ),
                                            SizedBox(height: 5),
                                            Text(info.likes.toString(),
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                )),
                                          ],
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            SizedBox(height: 5),
                                            GestureDetector(
                                              child: Text(info.name),
                                              onTap: () {},
                                            ),
                                            SizedBox(height: 10),
                                            Text(timeago.format(todayDate),
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                ))
                                          ],
                                        ),
                                        title: Text(info.body),
                                      ),
                                    ),
                                    secondaryActions: <Widget>[
                                      if (info.name.contains(widget.user))
                                        IconSlideAction(
                                          caption: 'Delete',
                                          color: Colors.red[300],
                                          icon: Icons.delete,
                                          onTap: () {
                                            if (info.name
                                                .contains(widget.user)) {
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      "posts${widget.promptNumber}")
                                                  .doc(post.documentID)
                                                  .get()
                                                  .then((value) {
                                                int postLikes =
                                                    value.data()['likes'];
                                                print(postLikes);
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .where('username',
                                                        isEqualTo: widget.user)
                                                    .get()
                                                    .then((value) {
                                                  int curLikes = value.docs[0]
                                                      .get('likes');
                                                  int curPosts = value.docs[0]
                                                      .get('posts');
                                                  String curUid =
                                                      value.docs[0].get('uid');
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(curUid)
                                                      .update({
                                                    "likes":
                                                        curLikes - postLikes,
                                                    "posts": curPosts - 1,
                                                  });
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        "posts${widget.promptNumber}")
                                                    .doc(post.documentID)
                                                    .delete();
                                              });
                                            }
                                          },
                                        ),
                                      if (!info.name.contains(widget.user))
                                        IconSlideAction(
                                          caption: 'Report',
                                          color: Colors.orange[300],
                                          icon: Icons.flag,
                                          onTap: () async {
                                            if (info.flaggedBy
                                                .contains(widget.user)) {
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      "posts${widget.promptNumber}")
                                                  .doc(post.documentID)
                                                  .update({
                                                "flags": info.flags - 1,
                                                "flaggedBy":
                                                    FieldValue.arrayRemove(
                                                        [widget.user]),
                                              }).then((value) {
                                                postController.clear();
                                              });
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .where('username',
                                                      isEqualTo: info.name)
                                                  .get()
                                                  .then((value) {
                                                int curLikes = value.docs[0]
                                                    .get('flagged');
                                                String curUid =
                                                    value.docs[0].get('uid');
                                                FirebaseFirestore.instance
                                                    .collection("users")
                                                    .doc(curUid)
                                                    .update({
                                                  "flagged": curLikes - 1,
                                                });
                                              });
                                            } else {
                                              FirebaseFirestore.instance
                                                  .collection(
                                                      "posts${widget.promptNumber}")
                                                  .doc(post.documentID)
                                                  .get()
                                                  .then((value) {
                                                int postLikes =
                                                    value.data()['likes'];
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .where('username',
                                                        isEqualTo: info.name)
                                                    .get()
                                                    .then((value) {
                                                  int curLikes = value.docs[0]
                                                      .get('likes');
                                                  String curUid =
                                                      value.docs[0].get('uid');
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(curUid)
                                                      .update({
                                                    "likes":
                                                        curLikes - postLikes,
                                                  });
                                                });
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        "posts${widget.promptNumber}")
                                                    .doc(post.documentID)
                                                    .update({
                                                  "flags": info.flags + 1,
                                                  "flaggedBy":
                                                      FieldValue.arrayUnion(
                                                          [widget.user]),
                                                }).then((value) {
                                                  postController.clear();
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .where('username',
                                                        isEqualTo: info.name)
                                                    .get()
                                                    .then((value) {
                                                  int curFlags = value.docs[0]
                                                      .get('flags');
                                                  int curPosts = value.docs[0]
                                                      .get('posts');
                                                  String curUid =
                                                      value.docs[0].get('uid');
                                                  FirebaseFirestore.instance
                                                      .collection("users")
                                                      .doc(curUid)
                                                      .update({
                                                    "flags": curFlags + 1,
                                                    "posts": curPosts - 1,
                                                  });
                                                });
                                              });
                                            }
                                          },
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return CircularProgressIndicator();
                        }
                        return Container();
                      }),
                );
              }
              return Container();
            }),
      ),
    );
  }

  Widget response() {
    return Center(
      child: !widget.user.contains("Disc")
          ? Semantics(
              button: true,
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15, top: 8),
                child: TextFormField(
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (value) {
                    final filter = ProfanityFilter();
                    String clean = filter.censor(postController.text).trim();

                    if (clean.length > 0) {
                      FirebaseFirestore.instance
                          .collection("posts${widget.promptNumber}")
                          .add({
                        "name": widget.user,
                        "body": clean,
                        "timeStamp": DateTime.now().toUtc().toString(),
                        "likes": 0,
                        "likedBy": [],
                        "flags": 0,
                        "flaggedBy": [],
                      }).then((value) {
                        postController.clear();
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('username', isEqualTo: widget.user)
                          .get()
                          .then((value) {
                        int curPosts = value.docs[0].get('posts');
                        String curUid = value.docs[0].get('uid');
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(curUid)
                            .update({
                          "posts": curPosts + 1,
                        });
                      });
                    } else {}
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  controller: postController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  maxLength: 525,
                  buildCounter: (
                    BuildContext context, {
                    int currentLength,
                    int maxLength,
                    bool isFocused,
                  }) {
                    return Text('${maxLength - currentLength}');
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        final filter = ProfanityFilter();
                        String clean =
                            filter.censor(postController.text).trim();

                        if (clean.length > 0) {
                          FirebaseFirestore.instance
                              .collection("posts${widget.promptNumber}")
                              .add({
                            "name": widget.user,
                            "body": clean,
                            "timeStamp": DateTime.now().toUtc().toString(),
                            "likes": 0,
                            "likedBy": [],
                            "flags": 0,
                            "flaggedBy": [],
                          }).then((value) {
                            postController.clear();
                            FirebaseFirestore.instance
                                .collection('users')
                                .where('username', isEqualTo: widget.user)
                                .get()
                                .then((value) {
                              int curPosts = value.docs[0].get('posts');
                              String curUid = value.docs[0].get('uid');
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(curUid)
                                  .update({
                                "posts": curPosts + 1,
                              });
                            });
                            //print(value.id);
                          });
                        } else {}
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                    ),
                    hintText: 'Post a Reponse Here',
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 2.0),
                    ),
                  ),
                ),
              ))
          : Container(),
    );
  }
}

String validateProfanity(String value) {
  final filter = ProfanityFilter();
  if (filter.hasProfanity(value) == true) {
    return "Remove Profanity to Post a Response";
  }
  return null;
}
