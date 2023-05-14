class XY {
  const XY({required this.longitude, required this.latitude});
  final double longitude;
  final double latitude;
}

class PlayData {
  PlayData(
      {required this.name, required this.thumbnail, required this.id, this.points});
  final String name;
  final String thumbnail;
  List<XY>? points = [];
  final int id; // for connect to database
}