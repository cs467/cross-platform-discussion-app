import 'rankTile.dart';

class RankTileList {

  final List<RankTile> users;

  RankTileList({this.users});

  int get listLength => users.length;

  RankTile getEachEntry(int i) {
    return users[i];
  }
}