import 'package:kouch/src/auth/kouch_auth.dart';
import 'package:kouch/src/database/kouch_database.dart';
import 'package:kouch/src/models/kouch_auth_info.dart';

/// An Instance of [Kouch].
///
/// * Call .init(host) to initialize [Kouch] with the CouchDB host.
/// * Call .deInit() to clear persistent properties. Properties such as "Host Name",
/// "Authentication Cookies" etc. are persisted across instances of Kouch.
abstract class _Kouch {
  /// Initializes Kouch.
  /// * [host] : The CouchDB host. Throws [FormatException] if valid url is not provided.
  void init({required String host});

  /// To obtain session and authorization data.
  /// * [auth] : The type of authentication required.
  Future<KouchAuthInfo> authorize({required KouchAuth auth});

  /// Instance of CouchDB database.
  /// * [name] : The name of the database.
  KouchDatabase database(String name);

  /// De-initializes Kouch.
  void deInit();
}

class Kouch implements _Kouch {
  /// The CouchDB host.
  static String? _host;

  /// The Authentication type.
  static KouchAuth? _auth;

  @override
  void init({required String host}) {
    Uri.parse(host);
    _host = host;
  }

  @override
  Future<KouchAuthInfo> authorize({required KouchAuth auth}) async {
    assert(_host != null);
    _auth = auth;
    return await auth.authenticate(_host!);
  }

  @override
  KouchDatabase database(String name) {
    assert(_host != null);
    assert(_host != null);
    return KouchDatabase(_host!, _auth!);
  }

  @override
  void deInit() {
    _host = null;
    _auth = null;
  }
}
