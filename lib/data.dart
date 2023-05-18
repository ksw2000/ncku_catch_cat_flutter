import 'package:flutter_riverpod/flutter_riverpod.dart';

class XY {
  const XY({required this.longitude, required this.latitude});
  final double longitude;
  final double latitude;
}

class PlayData {
  PlayData(
      {required this.name,
      required this.thumbnail,
      required this.id,
      this.points});
  final String name;
  final String thumbnail;
  List<XY>? points = [];
  final int id; // for connect to database
}

class Cat {
  Cat({required this.id, required this.position});
  final int id;
  final XY position;
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

Provider<UserData?> userData = Provider((ref) {
  // TODO: Get from database
  return UserData(id: 0, name: 'かすかす', email: 'algoalgogo@gmail.com');
});
