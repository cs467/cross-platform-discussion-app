import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PromptProposal extends StatefulWidget {
  String user;
  PromptProposal({Key key, @required this.user}) : super(key: key);
  @override
  _PromptProposalState createState() => _PromptProposalState();
}

class _PromptProposalState extends State<PromptProposal> {
  TextEditingController postController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prompt Proposal"),
      ),
      body: Container(
        child: response(),
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
              FirebaseFirestore.instance.collection("proposal").add({
                "name": widget.user,
                "body": clean,
                "timeStamp": DateTime.now().toUtc().toString(),
                "likes": 0,
                "likedBy": [],
                "flags": 0,
                "flaggedBy": [],
              }).then((value) {
                postController.clear();
                //print(value.id);
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
                String clean = filter.censor(postController.text).trim();

                if (clean.length > 0) {
                  FirebaseFirestore.instance.collection("proposal").add({
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
              borderSide: BorderSide(color: Colors.transparent, width: 2.0),
            ),
          ),
        ),
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