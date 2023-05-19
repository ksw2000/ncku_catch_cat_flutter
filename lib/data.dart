import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class PlayData {
  PlayData(
      {required this.name,
      required this.thumbnail,
      required this.id,
      this.cats});
  final String name;
  final String thumbnail;
  List<Cat>? cats = [];
  final int id; // for connect to database
}

StateProvider<PlayData?> playDataProvider = StateProvider((ref) {
  return null;
});

class Cat {
  Cat({required this.id, required this.position});
  final int id;
  final LatLng position;
}

class UserData {
  UserData(
      {required this.id,
      required this.name,
      required this.email,
      this.profile,
      this.cats = const []});
  final int id;
  final String name;
  final String email;
  final String? profile;
  // int rank = 1; // rank 值可以由 cats 來計算
  List<Cat> cats = [];
}

StateProvider<UserData?> userDataProvider = StateProvider((ref) {
  // TODO: Get from database
  return UserData(id: 0, name: 'かすかす', email: 'algoalgogo@gmail.com');
});

const defaultProfile = 'assets/images/defaultProfile.png';

// 對應某個遊玩主題
class RankingData {
  RankingData({required this.name, required this.score});
  final String name; // user name
  final int score; // 得分
}

List<RankingData> debugRankDataList = <RankingData>[
  RankingData(name: "侑", score: 13),
  RankingData(name: "步夢", score: 12),
  RankingData(name: "栞子", score: 1),
  RankingData(name: "かすみ", score: 1),
  // RankingData(),
];

class FriendData {
  const FriendData(
      {required this.name,
      this.profile,
      required this.id,
      required this.level,
      required this.inviting});
  final String name;
  final String? profile;
  final int id;
  final int level; // 好友 level
  final bool inviting; // 好友申請
}

List<FriendData> debugFriendDataList = <FriendData>[
  const FriendData(name: "侑", id: 0, level: 1, inviting: false),
  const FriendData(name: "步夢", id: 0, level: 2, inviting: false),
  const FriendData(name: "栞子", id: 0, level: 10, inviting: false),
  const FriendData(name: "かすみ", id: 0, level: 20, inviting: false),
];

List<FriendData> debugFriendDataInvitingList = <FriendData>[
  const FriendData(name: "果林", id: 0, level: 1, inviting: true),
  const FriendData(name: "しずく", id: 0, level: 2, inviting: true),
];
