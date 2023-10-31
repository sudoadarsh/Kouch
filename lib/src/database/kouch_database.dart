import 'package:kouch/src/auth/kouch_auth.dart';

abstract class _KouchDatabase {
  const _KouchDatabase();
}

class KouchDatabase implements _KouchDatabase {
  final String host;
  final KouchAuth auth;
  const KouchDatabase(this.host, this.auth);
  /// Returns a list of all the databases in the CouchDB instance.
  // static Future<List<String>> listAllDatabase() async {

  // }
}