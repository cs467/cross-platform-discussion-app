import 'package:cloud_firestore/cloud_firestore.dart';

class PromptPost {
  String body;
  String name;
  var likes;
  var likedBy = [];
  Timestamp timestamp;
  PromptPost({
    this.likedBy,
    this.body,
    this.name,
    this.likes,
    this.timestamp,
  });
}
