import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class PlayThemeData {
  PlayThemeData(
      {required this.name,
      required this.thumbnail,
      required this.id,
      this.cats});
  final String name;
  final String thumbnail;
  List<Cat>? cats = [];
  final int id; // for connect to database
}

// List<PlayThemeData> debugThemeData = <PlayThemeData>[
//   PlayThemeData(
//     id: 0,
//     name: '國立成功大學',
//     thumbnail: 'assets/themes/ncku.png',
//   ),
//   PlayThemeData(
//     id: 1,
//     name: '台南孔廟商圈',
//     thumbnail: 'assets/themes/Confucius Temple.png',
//   ),
//   PlayThemeData(
//     id: 2,
//     name: '猴硐猫村',
//     thumbnail: 'assets/themes/Houtong Cats Village.jpg',
//   )
// ];

StateProvider<PlayThemeData?> playDataProvider = StateProvider((ref) {
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
      required this.rank,
      required this.verified,
      required this.session,
      required this.cats});
  final int id;
  final String name;
  final String email;
  final int rank;
  final bool verified;
  final String? profile;
  final String? session;
  final int cats;
}

StateProvider<UserData?> userDataProvider = StateProvider((ref) {
  return null;
});

// EMAIL: algoalgogo@gmail.com
// NAME: INHPC
// PASSWORD: algoalgo2023

const defaultProfile = 'assets/images/defaultProfile.png';

// 對應某個遊玩主題
class RankingData {
  RankingData({required this.name, required this.cats});
  final String name; // user name
  final int cats; // 得分
}

List<RankingData> debugRankDataList = <RankingData>[
  RankingData(name: "侑", cats: 13),
  RankingData(name: "步夢", cats: 12),
  RankingData(name: "栞子", cats: 1),
  RankingData(name: "かすみ", cats: 1),
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
