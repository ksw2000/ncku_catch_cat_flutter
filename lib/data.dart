import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:catch_cat/util.dart';

class PlayThemeData {
  PlayThemeData(
      {required this.name, required this.thumbnail, required this.id});
  PlayThemeData.fromMap(Map<String, dynamic> j)
      : name = j['name'],
        thumbnail = j['thumbnail'],
        id = j['theme_id'];

  final String name;
  final String thumbnail;
  final int id; // for connect to database

  // int numOfCaught() {
  //   int i = 0;
  //   cats?.forEach((e) {
  //     if (e.isCaught) i++;
  //   });
  //   return i;
  // }
}

StateProvider<PlayThemeData?> playDataProvider = StateProvider((ref) {
  return null;
});

class Cat {
  Cat(
      {required this.kindID,
      required this.weight,
      required this.isCaught,
      required this.id,
      required this.position,
      required this.thumbnail,
      required this.name,
      required this.description});
  Cat.fromMap(Map<String, dynamic> j)
      : id = j['cat_id'],
        kindID = j['cat_kind_id'],
        weight = j['weight'],
        position = LatLng(j['lat'], j['lng']),
        isCaught = j['is_caught'],
        thumbnail = j['thumbnail'],
        name = j['name'],
        description = j['description'];

  final int id;
  final int kindID;
  final int weight;
  final LatLng position;
  final bool isCaught;
  final String thumbnail;
  final String name;
  final String description;
}

StateProvider<List<Cat>> catListDataProvider = StateProvider((ref) {
  return [];
});

class UserData {
  UserData(
      {required this.id,
      required this.name,
      required this.email,
      this.profile,
      required this.verified,
      required this.session,
      required this.level,
      required this.score,
      required this.cats,
      required this.shareGPS});

  UserData.fromMap(Map<String, dynamic> j)
      : id = j["uid"],
        session = j['session'],
        name = j["name"],
        profile = j["profile"] == "" ? null : j["profile"],
        email = j["email"],
        verified = j["verified"],
        level = j["level"],
        score = j["score"],
        cats = j["cats"],
        shareGPS = j["share_gps"];

  final int id;
  String name;
  String email;
  final bool verified;
  String? profile;
  final String? session;
  final int level;
  final int score;
  final int cats;
  bool shareGPS;

  void setShareGPS(bool flag) async {
    http.Response res = await http.post(uri(domain, '/user/update/share_gps'),
        body: jsonEncode({'session': session, 'share_or_not': flag}));
    print(res.body);
  }
}

StateProvider<UserData?> userDataProvider = StateProvider((ref) {
  return null;
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
  FriendData(
      {this.profile,
      required this.name,
      required this.id,
      required this.level,
      required this.cats,
      required this.score,
      this.themeCats = 0,
      this.themeScore = 0,
      this.lastLogin = 0,
      this.lat = 0,
      this.lng = 0});

  FriendData.fromMap(Map<String, dynamic> j)
      : id = j["uid"],
        name = j["name"],
        profile = j["profile"] == "" ? null : j["profile"],
        level = j["level"],
        cats = j["cats"],
        score = j["score"],
        themeCats = j["theme_cats"],
        themeScore = j["theme_score"],
        lastLogin = j["last_login"] ?? 0,
        lat = j["lat"] ?? 0,
        lng = j["lng"] ?? 0;

  final String name;
  final String? profile;
  final int id;
  final int level; // 好友 level
  final int cats; // 好友所抓到的貓的數
  final int score; // 好友的分數
  int themeCats; // 某個地圖中所獲取的貓貓數
  int themeScore; // 芋個地圖中所獲取的貓貓總分
  int lastLogin;
  double lat;
  double lng;
}

// class RankingData {
//   RankingData(
//       {required this.uid,
//       required this.name,
//       required this.score,
//       required this.cats});
//   RankingData.fromMap(Map<String, dynamic> j)
//       : uid = j['uid'],
//         name = j['name'],
//         score = j['score'],
//         cats = j['cats'];

//   final int uid;
//   final String name;
//   final int score;
//   final int cats;
// }

int numOfCaught(List<Cat> cat) {
  int i = 0;
  for (var e in cat) {
    if (e.isCaught) i++;
  }
  return i;
}
