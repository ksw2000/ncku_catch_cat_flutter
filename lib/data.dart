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
  List<Cat> cats = [];
}

StateProvider<UserData?> userDataProvider = StateProvider((ref) {
  // TODO: Get from database
  return UserData(id: 0, name: 'かすかす', email: 'algoalgogo@gmail.com');
});

const defaultProfile = 'assets/images/defaultProfile.png';

class RankingData {
  RankingData(
      {
      // required this.uid,
      required this.name,
      // required this.themeID,
      required this.score});
  // final int uid; // uid
  final String name; // user name
  // final int themeID; // 對應的主題
  final int score; // 得分
}

List<RankingData> debugRankData = <RankingData>[
  RankingData(name: "侑", score: 13),
  RankingData(name: "步夢", score: 12),
  RankingData(name: "栞子", score: 1),
  RankingData(name: "かすみ", score: 1),
  // RankingData(),
];
