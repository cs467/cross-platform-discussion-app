import 'package:cloud_firestore/cloud_firestore.dart';

class PromptPost {
  String body;
  String name;
  Timestamp timestamp;
  PromptPost({
    this.body,
    this.name,
    this.timestamp,
  });
}
