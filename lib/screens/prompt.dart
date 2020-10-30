import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

// ignore: must_be_immutable
class Prompt extends StatelessWidget {
  String text;
  String promptNumber;
  Prompt({Key key, @required this.text, @required this.promptNumber})
      : super(key: key);
  TextEditingController postController = new TextEditingController();
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
            title: Text('$text'),
          ),
          body: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts$promptNumber')
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (content, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data.documents != null &&
                    snapshot.data.documents.length > 0) {
                  return Column(
                    children: [
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
                                    snapshot.data
                                            .docs[int.parse(promptNumber) - 1]
                                        ['prompt'],
                                    textAlign: TextAlign.justify,
                                  );
                                }
                                return CircularProgressIndicator();
                              })),
                      SizedBox(height: 0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            var post = snapshot.data.documents[index];
                            var info = PromptPost();
                            info.name = post['name'];
                            info.body = post['body'];
                            print(info.name);
                            print(info.body);
                            return Semantics(
                              button: true,
                              enabled: true,
                              child: ListTile(
                                onTap: () async {},
                                trailing: Text(info.name),
                                title: Text(info.body),
                              ),
                            );
                          },
                        ),
                      ),
                      Center(
                        child: Semantics(
                            button: true,
                            enabled: true,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: TextField(
                                controller: postController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                maxLength: 225,
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
                                      FirebaseFirestore.instance
                                          .collection("posts$promptNumber")
                                          .add({
                                        "name": "TEST",
                                        "body": postController.text,
                                        "timeStamp": DateTime.now().toString(),
                                      }).then((value) {
                                        postController.clear();
                                        print(value.id);
                                      });
                                    },
                                  ),
                                  hintText: 'Post a Reponse Here',
                                  border: const OutlineInputBorder(),
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
