import 'package:kouch/kouch.dart';
import 'package:kouch/src/auth/kouch_auth.dart';

void main() async {
  final Kouch kouch = Kouch();
  // Initialize [Kouch].
  kouch.init(host: "http://127.0.0.1:5984");
  // Cookie base authentication.
  final Map<String, dynamic> auth = await  kouch.authorize(auth: KouchCookieAuth(username: "admin", password: "sudoadarsh"));
  print(auth);
  // Get user info.
  final Map<String, dynamic> userInfo = await kouch.userInfo();
  print(userInfo);
  // Get the CouchDB database.
}