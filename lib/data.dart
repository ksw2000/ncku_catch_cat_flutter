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

  UserData.fromMap(Map<String, dynamic> j)
      : id = j["uid"],
        session = j['session'],
        name = j["name"],
        profile = j["profile"] == "" ? null : j["profile"],
        email = j["email"],
        verified = j["verified"],
        rank = j["rank"],
        cats = j["cats"];

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
  return UserData(
    cats: 0,
    name: 'INHPC',
    email: 'algoalgogo@gmail.com',
    id: 452108996911,
    rank: 0,
    verified: false,
    session: '0',
  );
  // return null;
});

// user 1
// email:     algoalgogo@gmail.com
// name:      INHPC
// password:  algoalgo2023

// user 2
// email:     ayumu@mail.com
// name:      歩夢
// password:  algoalgo2023

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
      {this.profile,
      required this.name,
      required this.id,
      required this.level});

  FriendData.fromMap(Map<String, dynamic> j)
      : id = j["uid"],
        name = j["name"],
        profile = j["profile"] == "" ? null : j["profile"],
        level = j["level"];

  final String name;
  final String? profile;
  final int id;
  final int level; // 好友 level
}

// StateProvider<List<FriendData>?> friendDataProvider = StateProvider((ref) {
//   return null;
// });

// StateProvider<List<FriendData>?> friendInvitingDataProvider =
//     StateProvider((ref) {
//   return null;
// });

// List<FriendData> debugFriendDataList = <FriendData>[
//   const FriendData(name: "侑", id: 0, level: 1, inviting: false),
//   const FriendData(name: "步夢", id: 0, level: 2, inviting: false),
//   const FriendData(name: "栞子", id: 0, level: 10, inviting: false),
//   const FriendData(name: "かすみ", id: 0, level: 20, inviting: false),
// ];

// List<FriendData> debugFriendDataInvitingList = <FriendData>[
//   const FriendData(name: "果林", id: 0, level: 1, inviting: true),
//   const FriendData(name: "しずく", id: 0, level: 2, inviting: true),
// ];
