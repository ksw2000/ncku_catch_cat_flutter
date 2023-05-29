const domain = 'lab.had.name:8080';

Uri uri(
  String authority,
  String unencodedPath, [
  Map<String, dynamic>? queryParameters,
]) {
  return (Uri.base.port == 443)
      ? Uri.https(authority, unencodedPath, queryParameters)
      : Uri.http(authority, unencodedPath, queryParameters);
}

// d: meters
String obscureDistance(int d) {
  // > 1000
  if (d >= 1000) {
    d = (d ~/ 100);
    int e = d % 10;
    d = d ~/ 10;
    return e != 0 ? "$d.${e}KM" : "${d}KM";
  } else if (d >= 100) {
    d = d ~/ 100 * 100;
    return "${d}M";
  } else if (d >= 10) {
    d = d ~/ 10 * 10;
    return "${d}M";
  }
  return "${d}M";
}

String humanReadTime(int time) {
  int d = (DateTime.now().millisecondsSinceEpoch ~/ 1000 - time);
  if (d < 60) {
    return '剛剛';
  } else if (d < 60 * 60) {
    return '${d ~/ 60}分鐘前';
  } else if (d < 24 * 60 * 60) {
    return '${d ~/ 3660}小時前';
  } else if (d < 30 * 24 * 60 * 60) {
    return '${d ~/ (3660 * 24)}天前';
  } else {
    return '超過三十天';
  }
}
