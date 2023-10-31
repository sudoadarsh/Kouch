import 'package:kouch/src/auth/kouch_auth.dart';

abstract class _KouchDatabase {
  const _KouchDatabase();

  /// Creates a new database. 
  Map<String, dynamic> create();
}

class KouchDatabase implements _KouchDatabase {
  final String host;
  final KouchAuth auth;
  /// The name of the database.
  final String name;
  const KouchDatabase(this.host, this.auth, {required this.name});

  @override
  Map<String, dynamic> create() {
    throw UnimplementedError();
  }
}