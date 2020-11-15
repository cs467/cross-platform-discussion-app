class User {
  String uid;
  String username;
  String email;
  int likes;
  int dislikes;
  int streaks;
  int flags;
  int posts;
  DateTime registrationDateTime;

  User({
    this.uid,
    this.username,
    this.email,
    this.likes,
    this.dislikes,
    this.streaks,
    this.flags,
    this.posts,
    this.registrationDateTime,
  });

  factory User.fromMap(Map<String, dynamic> user) {
    return User(
      uid: user['uid'],
      username: user['username'],
      email: user['email'],
      likes: user['likes'],
      dislikes: user['dislikes'],
      streaks: user['streak'],
      flags: user['flags'],
      posts: user['posts'],
      registrationDateTime: user['registrationDateTime'],
    );
  }
}
