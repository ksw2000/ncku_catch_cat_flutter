import 'dart:convert';

import 'package:catch_cat/util.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class PlayThemeData {
  PlayThemeData.fromMap(Map<String, dynamic> j)
      : name = j['name'],
        thumbnail = j['thumbnail'],
        id = j['theme_id'];

  final String name;
  final String thumbnail;
  final int id; // for connect to database
}

StateProvider<PlayThemeData?> playDataProvider = StateProvider((ref) {
  return null;
});

class Cat {
  Cat.fromMap(Map<String, dynamic> j)
      : id = j['cat_id'],
        kindID = j['cat_kind_id'],
        weight = j['weight'],
        position = LatLng(j['lat'].toDouble(), j['lng'].toDouble()),
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

class CatKindData {
  CatKindData.fromMap(Map<String, dynamic> j)
      : kindID = j['cat_kind_id'],
        weight = j['weight'],
        isCaught = j['is_caught'],
        thumbnail = j['thumbnail'],
        name = j['name'],
        description = j['description'];

  final int kindID;
  final int weight;
  final bool isCaught;
  final String thumbnail;
  final String name;
  final String description;
}

StateProvider<List<Cat>> catListDataProvider = StateProvider((ref) {
  return [];
});

class UserData {
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

  void setShareGPSInServer(bool flag) async {
    http.Response res = await http.post(uri(domain, '/user/update/share_gps'),
        body: jsonEncode({'session': session, 'share_or_not': flag}));
    debugPrint(res.body);
  }
}

StateProvider<UserData?> userDataProvider = StateProvider((ref) {
  return null;
});

const defaultProfile = 'assets/images/defaultProfile.png';

class FriendData {
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
        lat = j["lat"].toDouble(),
        lng = j["lng"].toDouble();

  final String name;
  final String? profile;
  final int id;
  final int level; // 好友 level
  final int cats; // 好友所抓到的貓的數
  final int score; // 好友的分數
  int themeCats; // 某個地圖中所獲取的貓貓數
  int themeScore; // 某個地圖中所獲取的貓貓總分
  int lastLogin;
  double lat;
  double lng;
}

int numOfCaught(List<Cat> cat) {
  int i = 0;
  for (var e in cat) {
    if (e.isCaught) i++;
  }
  return i;
}

class StoryData {
  StoryData(
      {required this.title,
      required this.abstraction,
      required this.content,
      this.lock = true});
  String title;
  String abstraction;
  String content;
  bool lock;
}
