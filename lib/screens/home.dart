import 'package:flutter/material.dart';
import 'package:disc/screens/prompt.dart';
import 'package:disc/screens/prompt_proposal.dart';
import 'package:disc/Widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';

var postNumber;
var numberPosts;

class HomePage extends StatefulWidget {
  static const routeName = 'homepage';
  HomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  List<Widget> _buildExpansionTileChildren(int index) => [
        Padding(
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
                    snapshot.data.docs[index]['prompt'],
                    textAlign: TextAlign.justify,
                  );
                }
                return CircularProgressIndicator();
              }),
        ),
        SizedBox(height: 1),
        Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('username', isEqualTo: widget.title)
                            .snapshots(),
                        builder: (context, snapshot) {
                          postNumber = index + 1;
                          if (snapshot.hasData &&
                              snapshot.data.documents != null &&
                              snapshot.data.documents.length > 0) {
                            var pPost = PromptPost();

                            /*for (var i = 0;
                            i < snapshot.data.documents[0]['following'].length;
                            i++) {
                          FirebaseFirestore.instance
                              .collection('posts$postNumber')
                              .where('name',
                                  isEqualTo: snapshot.data.documents[0]
                                      ['following'][i])
                              .get()
                              .then((value) {
                            print("NAME: ${value.docs.isEmpty}");
                            if (value.docs.isEmpty) {
                              pPost.hasPost.add(1);
                            } else {
                              pPost.hasPost.add(0);
                            }
                          });
                          print("PPOST: ${pPost.hasPost}");
                        }
                        */
                            var currentUser =
                                snapshot.data.documents[0]['following'];
                            print(snapshot.data.documents[0]['following']);
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot
                                    .data.documents[0]['following'].length,
                                itemBuilder: (context, index) {
                                  if (snapshot.data.documents.length > 0) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('posts$postNumber')
                                            .where('name',
                                                isEqualTo:
                                                    snapshot.data.documents[0]
                                                        ['following'][index])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data.documents != null &&
                                              snapshot.data.documents.length >
                                                  0) {
                                            print(
                                                "currentUser ${snapshot.data.documents.length}");

                                            return Card(
                                              child: ExpansionTile(
                                                  title: Text(
                                                    currentUser[index],
                                                    textAlign:
                                                        TextAlign.justify,
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'posts$postNumber')
                                                              .where('name',
                                                                  isEqualTo:
                                                                      currentUser[
                                                                          index])
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .hasData &&
                                                                snapshot.data
                                                                        .documents !=
                                                                    null &&
                                                                snapshot
                                                                        .data
                                                                        .documents
                                                                        .length >
                                                                    0) {
                                                              print(snapshot
                                                                  .data
                                                                  .documents
                                                                  .length);

                                                              return ListView
                                                                  .builder(
                                                                      scrollDirection:
                                                                          Axis
                                                                              .vertical,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemCount: snapshot
                                                                          .data
                                                                          .documents
                                                                          .length,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        if (snapshot.data.documents.length >
                                                                            0) {
                                                                          var post = snapshot
                                                                              .data
                                                                              .documents[index];
                                                                          var info =
                                                                              PromptPost();
                                                                          info.name =
                                                                              post['name'];
                                                                          info.body =
                                                                              post['body'];
                                                                          info.likes =
                                                                              post['likes'];
                                                                          info.likedBy =
                                                                              post['likedBy'];
                                                                          info.flags =
                                                                              post['flags'];
                                                                          info.flaggedBy =
                                                                              post['flaggedBy'];
                                                                          //print(post['timeStamp']);

                                                                          DateTime
                                                                              todayDate =
                                                                              DateTime.parse(post['timeStamp']);

                                                                          FirebaseFirestore
                                                                              .instance
                                                                              .collection('users')
                                                                              .where('username', isEqualTo: widget.title)
                                                                              .get()
                                                                              .then((value) {
                                                                            print("DATA: ${value.docs[0]['following']}");
                                                                            info.userFollows =
                                                                                value.docs[0]['following'].contains(info.name);
                                                                          });

                                                                          //print(todayDate);

                                                                          //print(post.documentID);

                                                                          return Semantics(
                                                                            button:
                                                                                true,
                                                                            enabled:
                                                                                true,
                                                                            child: StreamBuilder(
                                                                                stream: FirebaseFirestore.instance.collection('prompts').orderBy('number', descending: false).snapshots(),
                                                                                builder: (context, snapshot) {
                                                                                  //flag filter number

                                                                                  if (info.flags < 10 && !info.flaggedBy.contains(widget.title)) {
                                                                                    if (snapshot.hasData && snapshot.data.documents != null && snapshot.data.documents.length > 0) {
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
                                                                                                    if (info.likedBy.contains(widget.title)) {
                                                                                                      FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).update({
                                                                                                        "likes": info.likes - 1,
                                                                                                        "likedBy": FieldValue.arrayRemove([widget.title]),
                                                                                                      }).then((value) {});
                                                                                                      FirebaseFirestore.instance.collection('users').where('username', isEqualTo: info.name).get().then((value) {
                                                                                                        int curLikes = value.docs[0].get('likes');
                                                                                                        String curUid = value.docs[0].get('uid');
                                                                                                        FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                          "likes": curLikes - 1,
                                                                                                        });
                                                                                                      });
                                                                                                    } else {
                                                                                                      FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).update({
                                                                                                        "likes": info.likes + 1,
                                                                                                        "likedBy": FieldValue.arrayUnion([widget.title]),
                                                                                                      }).then((value) {});
                                                                                                      FirebaseFirestore.instance.collection('users').where('username', isEqualTo: info.name).get().then((value) {
                                                                                                        int curLikes = value.docs[0].get('likes');
                                                                                                        String curUid = value.docs[0].get('uid');
                                                                                                        FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                          "likes": curLikes + 1,
                                                                                                        });
                                                                                                      });
                                                                                                    }

                                                                                                    FocusScopeNode currentFocus = FocusScope.of(context);

                                                                                                    if (!currentFocus.hasPrimaryFocus) {
                                                                                                      currentFocus.unfocus();
                                                                                                    }
                                                                                                  },
                                                                                                  leading: Column(
                                                                                                    children: [
                                                                                                      SizedBox(height: 5),
                                                                                                      Icon(
                                                                                                        Icons.favorite,
                                                                                                        color: info.likedBy.contains(widget.title) ? Colors.red[300] : Colors.grey,
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
                                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                    children: [
                                                                                                      SizedBox(height: 5),
                                                                                                      Text(info.name),
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
                                                                                              actions: [
                                                                                                if (!info.name.contains(widget.title) && info.userFollows == false)
                                                                                                  IconSlideAction(
                                                                                                      caption: 'Follow',
                                                                                                      color: Colors.blue[300],
                                                                                                      icon: Icons.account_box_rounded,
                                                                                                      foregroundColor: Colors.white,
                                                                                                      onTap: () {
                                                                                                        FirebaseFirestore.instance.collection('users').where('username', isEqualTo: widget.title).get().then((value) {
                                                                                                          String curUid = value.docs[0].get('uid');
                                                                                                          FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                            "following": FieldValue.arrayUnion([info.name]),
                                                                                                          });
                                                                                                        }).then((value) {
                                                                                                          setState(() {});

                                                                                                          //print(value.id);
                                                                                                        });
                                                                                                      }),
                                                                                                if (!info.name.contains(widget.title) && info.userFollows == true)
                                                                                                  IconSlideAction(
                                                                                                      caption: 'Unfollow',
                                                                                                      color: Colors.blue[300],
                                                                                                      icon: Icons.account_box_rounded,
                                                                                                      foregroundColor: Colors.white,
                                                                                                      onTap: () {
                                                                                                        FirebaseFirestore.instance.collection('users').where('username', isEqualTo: widget.title).get().then((value) {
                                                                                                          String curUid = value.docs[0].get('uid');
                                                                                                          FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                            "following": FieldValue.arrayRemove([info.name]),
                                                                                                          });
                                                                                                        }).then((value) {
                                                                                                          setState(() {});
                                                                                                        });
                                                                                                      }),
                                                                                              ],
                                                                                              secondaryActions: <Widget>[
                                                                                                if (info.name.contains(widget.title))
                                                                                                  IconSlideAction(
                                                                                                    caption: 'Delete',
                                                                                                    color: Colors.red[300],
                                                                                                    icon: Icons.delete,
                                                                                                    onTap: () {
                                                                                                      if (info.name.contains(widget.title)) {
                                                                                                        FirebaseFirestore.instance.collection("posts$postNumber}").doc(post.documentID).get().then((value) {
                                                                                                          int postLikes = value.data()['likes'];
                                                                                                          print(postLikes);
                                                                                                          FirebaseFirestore.instance.collection('users').where('username', isEqualTo: widget.title).get().then((value) {
                                                                                                            int curLikes = value.docs[0].get('likes');
                                                                                                            int curPosts = value.docs[0].get('posts');
                                                                                                            String curUid = value.docs[0].get('uid');
                                                                                                            FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                              "likes": curLikes - postLikes,
                                                                                                              "posts": curPosts - 1,
                                                                                                            });
                                                                                                          });
                                                                                                          FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).delete();
                                                                                                        });
                                                                                                      }
                                                                                                    },
                                                                                                  ),
                                                                                                if (!info.name.contains(widget.title))
                                                                                                  IconSlideAction(
                                                                                                    caption: 'Report',
                                                                                                    color: Colors.orange[300],
                                                                                                    icon: Icons.flag,
                                                                                                    onTap: () async {
                                                                                                      if (info.flaggedBy.contains(widget.title)) {
                                                                                                        FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).update({
                                                                                                          "flags": info.flags - 1,
                                                                                                          "flaggedBy": FieldValue.arrayRemove([widget.title]),
                                                                                                        }).then((value) {});
                                                                                                        FirebaseFirestore.instance.collection('users').where('username', isEqualTo: info.name).get().then((value) {
                                                                                                          int curLikes = value.docs[0].get('flagged');
                                                                                                          String curUid = value.docs[0].get('uid');
                                                                                                          FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                            "flagged": curLikes - 1,
                                                                                                          });
                                                                                                        });
                                                                                                      } else {
                                                                                                        FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).get().then((value) {
                                                                                                          int postLikes = value.data()['likes'];
                                                                                                          FirebaseFirestore.instance.collection('users').where('username', isEqualTo: info.name).get().then((value) {
                                                                                                            int curLikes = value.docs[0].get('likes');
                                                                                                            String curUid = value.docs[0].get('uid');
                                                                                                            FirebaseFirestore.instance.collection("users").doc(curUid).update({
                                                                                                              "likes": curLikes - postLikes,
                                                                                                            });
                                                                                                          });
                                                                                                          FirebaseFirestore.instance.collection("posts$postNumber").doc(post.documentID).update({
                                                                                                            "flags": info.flags + 1,
                                                                                                            "flaggedBy": FieldValue.arrayUnion([widget.title]),
                                                                                                          }).then((value) {});
                                                                                                          FirebaseFirestore.instance.collection('users').where('username', isEqualTo: info.name).get().then((value) {
                                                                                                            int curFlags = value.docs[0].get('flags');
                                                                                                            int curPosts = value.docs[0].get('posts');
                                                                                                            String curUid = value.docs[0].get('uid');
                                                                                                            FirebaseFirestore.instance.collection("users").doc(curUid).update({
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
                                                                      });
                                                            }
                                                            return CircularProgressIndicator();
                                                          }),
                                                    ),
                                                  ]),
                                            );
                                          }
                                          return Container();
                                        });
                                  }
                                });
                          }
                          return CircularProgressIndicator();
                        })))
          ],
        ),
        SizedBox(height: 15),
        FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Prompt(
                      user: widget.title ?? "Disc ${index + 1}",
                      promptNumber: "${index + 1}",
                      text: "Disc ${index + 1}")),
            );
          },
          label: widget.title != null ? Text('Join Disc') : Text('Read Disc'),
          icon: Icon(Icons.insert_comment),
        ),
        SizedBox(height: 25),
      ];
  Card _buildExpansionTile(int index) {
    return Card(
      child: ExpansionTile(
        key: GlobalKey(),
        title: Text('Prompt ${index + 1}'),
        children: _buildExpansionTileChildren(index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Submit a Prompt'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PromptProposal(user: widget.title)),
          );
        },
      ),
      appBar: AppBar(
        title: Text('Home Page'),
        leading: widget.title != null
            ? Padding(
                padding: EdgeInsets.only(left: 0),
                child: Icon(
                  Icons.bolt,
                  color: Color(0xff00e676),
                ),
              )
            : Container(),
      ),
      endDrawer: DrawerWidget(title: widget.title),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) =>
                  _buildExpansionTile(
                index,
              ),
            ),
          ),
          Container(
            child: Card(
              child: SizedBox(
                height: 100,
                width: 4000,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
          )
        ],
      ),
    );
  }
}

class FirestoreFirebase {}
