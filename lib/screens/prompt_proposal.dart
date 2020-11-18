import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:disc/models/post.dart';

class PromptProposal extends StatefulWidget {
  PromptProposal({Key key, @required this.user}) : super(key: key);
  final String user;
  @override
  _PromptProposalState createState() => _PromptProposalState();
}

class _PromptProposalState extends State<PromptProposal> {
  String sort = "timeStamp";
  TextEditingController postController = new TextEditingController();
  final ScrollController _scrollController = ScrollController();

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          title: Text("Prompt Proposal"),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('proposal')
              .orderBy(sort, descending: false)
              .snapshots(),
          builder: (content, snapshot) {
            if (snapshot.hasData && snapshot.data.documents != null) {
              return Column(
                children: [
                  tiles(snapshot),
                  response(),
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
          },
        ),
      ),
    );
  }

  Widget response() {
    return Center(
        child: Padding(
    padding: const EdgeInsets.only(left: 15.0, right: 15, top: 8),
    child: TextFormField(
      textInputAction: TextInputAction.send,
      onFieldSubmitted: (value) {
        final filter = ProfanityFilter();
        String clean = filter.censor(postController.text).trim();

        if (clean.length > 0) {
          submitProposal(clean);
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
            String clean = filter.censor(postController.text).trim();

            if (clean.length > 0) {
              submitProposal(clean);
            } else {}
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
        ),
        hintText: 'Submit Your Prompt Here',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 2.0),
        ),
      ),
    ),
        ),
      );
  }

   Widget centerPortion(
      BuildContext context, int index, AsyncSnapshot<dynamic> snapshot) {
    return Container(
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
      child: tileWork(context, index, snapshot),
    );
  }

  Widget tileWork(
      BuildContext context, int index, AsyncSnapshot<dynamic> snapshot) {
    {
      var post = snapshot.data.documents[index];
      var info = PromptPost();
      info.name = post['name'];
      info.body = post['body'];
      info.likes = post['likes'];
      info.likedBy = post['likedBy'];
      info.flags = post['flags'];
      info.flaggedBy = post['flaggedBy'];
      //print(post['timeStamp']);

      DateTime todayDate = DateTime.parse(post['timeStamp']);

      //print(todayDate);

      //print(post.documentID);

      //flag filter number
      if (info.flags < 1) {
        return Card(
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
                    if (info.likedBy.contains(widget.user)) {
                      FirebaseFirestore.instance
                          .collection("proposal")
                          .doc(post.documentID)
                          .update({
                        "likes": info.likes - 1,
                        "likedBy": FieldValue.arrayRemove([widget.user]),
                      }).then((value) {
                        postController.clear();
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('username', isEqualTo: info.name)
                          .get()
                          .then((value) {
                        int curLikes = value.docs[0].get('likes');
                        String curUid = value.docs[0].get('uid');
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(curUid)
                            .update({
                          "likes": curLikes - 1,
                        });
                      });
                    } else {
                      FirebaseFirestore.instance
                          .collection("proposal")
                          .doc(post.documentID)
                          .update({
                        "likes": info.likes + 1,
                        "likedBy": FieldValue.arrayUnion([widget.user]),
                      }).then((value) {
                        postController.clear();
                      });
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('username', isEqualTo: info.name)
                          .get()
                          .then((value) {
                        int curLikes = value.docs[0].get('likes');
                        String curUid = value.docs[0].get('uid');
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(curUid)
                            .update({
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
                        color: info.likedBy.contains(widget.user)
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
              secondaryActions: <Widget>[
                if (info.name.contains(widget.user))
                  IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red[300],
                    icon: Icons.delete,
                    onTap: () {
                      if (info.name.contains(widget.user)) {
                        FirebaseFirestore.instance
                            .collection("proposal")
                            .doc(post.documentID)
                            .get()
                            .then((value) {
                          int postLikes = value.data()['likes'];
                          print(postLikes);
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('username', isEqualTo: widget.user)
                              .get()
                              .then((value) {
                            int curLikes = value.docs[0].get('likes');
                            int curPosts = value.docs[0].get('posts');
                            String curUid = value.docs[0].get('uid');
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(curUid)
                                .update({
                              "likes": curLikes - postLikes,
                              "posts": curPosts - 1,
                            });
                          });
                          FirebaseFirestore.instance
                              .collection("proposal")
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
                      if (info.flaggedBy.contains(widget.user)) {
                        FirebaseFirestore.instance
                            .collection("proposal")
                            .doc(post.documentID)
                            .update({
                          "flags": info.flags - 1,
                          "flaggedBy": FieldValue.arrayRemove([widget.user]),
                        }).then((value) {
                          postController.clear();
                        });
                        FirebaseFirestore.instance
                            .collection('users')
                            .where('username', isEqualTo: info.name)
                            .get()
                            .then((value) {
                          int curLikes = value.docs[0].get('flagged');
                          String curUid = value.docs[0].get('uid');
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(curUid)
                              .update({
                            "flagged": curLikes - 1,
                          });
                        });
                      } else {
                        FirebaseFirestore.instance
                            .collection("proposal")
                            .doc(post.documentID)
                            .get()
                            .then((value) {
                          int postLikes = value.data()['likes'];
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('username', isEqualTo: info.name)
                              .get()
                              .then((value) {
                            int curLikes = value.docs[0].get('likes');
                            String curUid = value.docs[0].get('uid');
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(curUid)
                                .update({
                              "likes": curLikes - postLikes,
                            });
                          });
                          FirebaseFirestore.instance
                              .collection("proposal")
                              .doc(post.documentID)
                              .update({
                            "flags": info.flags + 1,
                            "flaggedBy": FieldValue.arrayUnion([widget.user]),
                          }).then((value) {
                            postController.clear();
                          });
                          FirebaseFirestore.instance
                              .collection('users')
                              .where('username', isEqualTo: info.name)
                              .get()
                              .then((value) {
                            int curFlags = value.docs[0].get('flags');
                            int curPosts = value.docs[0].get('posts');
                            String curUid = value.docs[0].get('uid');
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
        );
      }
      return CircularProgressIndicator();
    }
  }

  Future submitProposal(String clean) {
    return FirebaseFirestore.instance.collection("proposal").add({
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
        FirebaseFirestore.instance.collection("users").doc(curUid).update({
          "posts": curPosts + 1,
        });
      });
      //print(value.id);
    });
  }

  void _scrollToSelectedContent(
      bool isExpanded, double previousOffset, int index, GlobalKey myKey) {}

  List<Widget> _buildExpansionTileChildren(int index) => [
        StreamBuilder(
              stream: FirebaseFirestore.instance
        .collection('proposal')
        .orderBy(sort, descending: false)
        .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
          snapshot.data.documents != null &&
          snapshot.data.documents.length > 0) {
        return centerPortion(context, index, snapshot);
                }
                return CircularProgressIndicator();
              }),
        //SizedBox(height: 25),
      ];

  ExpansionTile _buildExpansionTile(int index) {
    final GlobalKey expansionTileKey = GlobalKey();
    double previousOffset;

    return ExpansionTile(
      key: expansionTileKey,
      onExpansionChanged: (isExpanded) {
        if (isExpanded) previousOffset = _scrollController.offset;
        _scrollToSelectedContent(
            isExpanded, previousOffset, index, expansionTileKey);
      },
      title: Text('Proposal ${index + 1}'),
      children: _buildExpansionTileChildren(index),
    );
  }

  Widget tiles(AsyncSnapshot<dynamic> snapshot) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: snapshot.data.documents.length,
      itemBuilder: (BuildContext context, int index) => _buildExpansionTile(
        index,
      ),
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
