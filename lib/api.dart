const domain = 'localhost:8080';

Uri uri(
  String authority,
  String unencodedPath, [
  Map<String, dynamic>? queryParameters,
]) {
  return (Uri.base.port == 443)
      ? Uri.https(authority, unencodedPath, queryParameters)
      : Uri.http(authority, unencodedPath, queryParameters);
}
