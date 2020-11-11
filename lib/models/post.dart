import 'package:cloud_firestore/cloud_firestore.dart';

class PromptPost {
  String body;
  String name;
  var likes;
  var likedBy = [];
  var flags;
  var flaggedBy = [];
  Timestamp timestamp;
  PromptPost({
    this.flags,
    this.flaggedBy,
    this.likedBy,
    this.body,
    this.name,
    this.likes,
    this.timestamp,
  });
}
