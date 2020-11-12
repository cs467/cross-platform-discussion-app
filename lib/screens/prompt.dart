import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:profanity_filter/profanity_filter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'dart:async';

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
  String sort = "timeStamp";
  bool rSelected = true, lSelected = false;

  TextEditingController postController = new TextEditingController();

  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(
      Duration(seconds: 5),
      (Timer t) => setState(() {}),
    );

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.text}'),
          ),
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts${widget.promptNumber}')
                  .orderBy(sort, descending: true)
                  .snapshots(),
              builder: (content, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data.documents != null &&
                    snapshot.data.documents.length > 0) {
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
                                //print(sort);
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
                                //print(sort);
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
                      Expanded(
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
                                var post = snapshot.data.documents[index];
                                var info = PromptPost();
                                info.name = post['name'];
                                info.body = post['body'];
                                info.likes = post['likes'];
                                info.likedBy = post['likedBy'];
                                info.flags = post['flags'];
                                info.flaggedBy = post['flaggedBy'];
                                //print(post['timeStamp']);

                                DateTime todayDate =
                                    DateTime.parse(post['timeStamp']);

                                //print(todayDate);

                                //print(post.documentID);
                                //print(info.name);
                                //print(info.body);
                                return Semantics(
                                  button: true,
                                  enabled: true,
                                  child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection('prompts')
                                          .orderBy('number', descending: false)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        //flag filter number
                                        if (info.flags < 1) {
                                          if (snapshot.hasData &&
                                              snapshot.data.documents != null &&
                                              snapshot.data.documents.length >
                                                  0) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    actionPane:
                                                        SlidableDrawerActionPane(),
                                                    actionExtentRatio: 0.25,
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: ListTile(
                                                        onTap: () async {
                                                          if (info.likedBy
                                                              .contains(widget
                                                                  .user)) {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "posts${widget.promptNumber}")
                                                                .doc(post
                                                                    .documentID)
                                                                .update({
                                                              "likes":
                                                                  info.likes -
                                                                      1,
                                                              "likedBy": FieldValue
                                                                  .arrayRemove([
                                                                widget.user
                                                              ]),
                                                            }).then((value) {
                                                              postController
                                                                  .clear();
                                                            });
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .where(
                                                                    'username',
                                                                    isEqualTo:
                                                                        info.name)
                                                                .get()
                                                                .then((value) {
                                                              int curLikes = value
                                                                  .docs[0]
                                                                  .get('likes');
                                                              String curUid =
                                                                  value.docs[0]
                                                                      .get(
                                                                          'uid');
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "users")
                                                                  .doc(curUid)
                                                                  .update({
                                                                "likes":
                                                                    curLikes -
                                                                        1,
                                                              });
                                                            });
                                                          } else {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "posts${widget.promptNumber}")
                                                                .doc(post
                                                                    .documentID)
                                                                .update({
                                                              "likes":
                                                                  info.likes +
                                                                      1,
                                                              "likedBy": FieldValue
                                                                  .arrayUnion([
                                                                widget.user
                                                              ]),
                                                            }).then((value) {
                                                              postController
                                                                  .clear();
                                                            });
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .where(
                                                                    'username',
                                                                    isEqualTo:
                                                                        info.name)
                                                                .get()
                                                                .then((value) {
                                                              int curLikes = value
                                                                  .docs[0]
                                                                  .get('likes');
                                                              String curUid =
                                                                  value.docs[0]
                                                                      .get(
                                                                          'uid');
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "users")
                                                                  .doc(curUid)
                                                                  .update({
                                                                "likes":
                                                                    curLikes +
                                                                        1,
                                                              });
                                                            });
                                                          }

                                                          FocusScopeNode
                                                              currentFocus =
                                                              FocusScope.of(
                                                                  context);

                                                          if (!currentFocus
                                                              .hasPrimaryFocus) {
                                                            currentFocus
                                                                .unfocus();
                                                          }
                                                        },
                                                        leading: Column(
                                                          children: [
                                                            SizedBox(height: 5),
                                                            Icon(
                                                              Icons.favorite,
                                                              color: info
                                                                      .likedBy
                                                                      .contains(
                                                                          widget
                                                                              .user)
                                                                  ? Colors
                                                                      .red[300]
                                                                  : Colors.grey,
                                                              size: 24.0,
                                                              semanticLabel:
                                                                  'Text to announce in accessibility modes',
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                                info.likes
                                                                    .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                )),
                                                          ],
                                                        ),
                                                        trailing: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            SizedBox(height: 5),
                                                            Text(info.name),
                                                            SizedBox(
                                                                height: 10),
                                                            Text(
                                                                timeago.format(
                                                                    todayDate),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      10.0,
                                                                ))
                                                          ],
                                                        ),
                                                        title: Text(info.body),
                                                      ),
                                                    ),
                                                    secondaryActions: <Widget>[
                                                      if (info.name.contains(
                                                          widget.user))
                                                        IconSlideAction(
                                                          caption: 'Delete',
                                                          color:
                                                              Colors.red[300],
                                                          icon: Icons.delete,
                                                          onTap: () {
                                                            if (info.name
                                                                .contains(widget
                                                                    .user)) {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "posts${widget.promptNumber}")
                                                                  .doc(post
                                                                      .documentID)
                                                                  .delete();
                                                            }
                                                          },
                                                        ),
                                                      if (!info.name.contains(
                                                          widget.user))
                                                        IconSlideAction(
                                                          caption: 'Report',
                                                          color: Colors
                                                              .orange[300],
                                                          icon: Icons.flag,
                                                          onTap: () async {
                                                            if (info.flaggedBy
                                                                .contains(widget
                                                                    .user)) {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "posts${widget.promptNumber}")
                                                                  .doc(post
                                                                      .documentID)
                                                                  .update({
                                                                "flags":
                                                                    info.flags -
                                                                        1,
                                                                "flaggedBy":
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  widget.user
                                                                ]),
                                                              }).then((value) {
                                                                postController
                                                                    .clear();
                                                              });
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .where(
                                                                      'username',
                                                                      isEqualTo:
                                                                          info
                                                                              .name)
                                                                  .get()
                                                                  .then(
                                                                      (value) {
                                                                int curLikes = value
                                                                    .docs[0]
                                                                    .get(
                                                                        'flags');
                                                                String curUid =
                                                                    value
                                                                        .docs[0]
                                                                        .get(
                                                                            'uid');
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(curUid)
                                                                    .update({
                                                                  "flags":
                                                                      curLikes -
                                                                          1,
                                                                });
                                                              });
                                                            } else {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "posts${widget.promptNumber}")
                                                                  .doc(post
                                                                      .documentID)
                                                                  .update({
                                                                "flags":
                                                                    info.flags +
                                                                        1,
                                                                "flaggedBy":
                                                                    FieldValue
                                                                        .arrayUnion([
                                                                  widget.user
                                                                ]),
                                                              }).then((value) {
                                                                postController
                                                                    .clear();
                                                              });
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .where(
                                                                      'username',
                                                                      isEqualTo:
                                                                          info
                                                                              .name)
                                                                  .get()
                                                                  .then(
                                                                      (value) {
                                                                int curLikes = value
                                                                    .docs[0]
                                                                    .get(
                                                                        'flags');
                                                                String curUid =
                                                                    value
                                                                        .docs[0]
                                                                        .get(
                                                                            'uid');
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(curUid)
                                                                    .update({
                                                                  "flags":
                                                                      curLikes +
                                                                          1,
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
                              }),
                        ),
                      ),
                      SizedBox(height: 5),
                      Center(
                        child: Semantics(
                            button: true,
                            enabled: true,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 15, top: 8),
                              child: TextFormField(
                                textInputAction: TextInputAction.send,
                                onFieldSubmitted: (value) {
                                  final filter = ProfanityFilter();
                                  String clean =
                                      filter.censor(postController.text).trim();

                                  if (clean.length > 0) {
                                    FirebaseFirestore.instance
                                        .collection(
                                            "posts${widget.promptNumber}")
                                        .add({
                                      "name": widget.user,
                                      "body": clean,
                                      "timeStamp":
                                          DateTime.now().toUtc().toString(),
                                      "likes": 0,
                                      "likedBy": [],
                                      "flags": 0,
                                      "flaggedBy": [],
                                    }).then((value) {
                                      postController.clear();
                                      //print(value.id);
                                    });
                                  }
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

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
                                      String clean = filter
                                          .censor(postController.text)
                                          .trim();

                                      if (clean.length > 0) {
                                        FirebaseFirestore.instance
                                            .collection(
                                                "posts${widget.promptNumber}")
                                            .add({
                                          "name": widget.user,
                                          "body": clean,
                                          "timeStamp":
                                              DateTime.now().toUtc().toString(),
                                          "likes": 0,
                                          "likedBy": [],
                                          "flags": 0,
                                          "flaggedBy": [],
                                        }).then((value) {
                                          postController.clear();
                                          //print(value.id);
                                        });
                                      } else {}
                                      FocusScopeNode currentFocus =
                                          FocusScope.of(context);

                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                    },
                                  ),
                                  hintText: 'Post a Reponse Here',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.transparent, width: 2.0),
                                  ),
                                ),
                              ),
                            )),
                      ),
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
}

String validateProfanity(String value) {
  final filter = ProfanityFilter();
  if (filter.hasProfanity(value) == true) {
    return "Remove Profanity to Post a Response";
  }
  return null;
}
