class RankTile {
  String uid;
  String username;
  //String email;
  int likes;
  int posts;
  // int dislikes;
  // int streaks;
  // int flags;
  // DateTime registrationDateTime;

  RankTile({
    this.uid,
    this.username,
    // this.email,
    this.likes,
    this.posts,
    // this.dislikes,
    // this.streaks,
    // this.flags,
    // this.registrationDateTime,
  });

  factory RankTile.fromMap(Map<String, dynamic> user) {
    return RankTile(
      uid: user['uid'],
      username: user['username'],
      //email: user['email'],
      likes: user['likes'],
      posts: user['posts'],
      // dislikes: user['dislikes'],
      // streaks: user['streak'],
      // flags: user['flags'],
      // registrationDateTime: user['registrationDateTime'],
    );
  }

  String get userUid => this.uid;
  String get userUsername => this.username;
  int get userLikes => this.likes;
  int get userPosts => this.posts;
}
