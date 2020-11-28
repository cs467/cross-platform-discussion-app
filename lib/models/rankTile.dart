// Model to represent a single item (tile) in the all user ranking on the stats page

class RankTile {
  String uid;
  String username;
  int likes;
  int posts;

  RankTile({
    this.uid,
    this.username,
    this.likes,
    this.posts,
  });

  factory RankTile.fromMap(Map<String, dynamic> user) {
    return RankTile(
      uid: user['uid'],
      username: user['username'],
      likes: user['likes'],
      posts: user['posts'],
    );
  }

  String get userUid => this.uid;
  String get userUsername => this.username;
  int get userLikes => this.likes;
  int get userPosts => this.posts;
}
