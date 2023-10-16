import 'package:kouch/src/auth/kouch_auth.dart';

/// An Instance of [Kouch].
///
/// Call .init(host) to initialize [Kouch] with the CouchDB host.
///
/// Call .deInit() to clear persistent properties. Properties such as "Host Name",
/// "Authentication Cookies" etc. are persisted across instances of Kouch.
abstract class _Kouch {
  /// Initializes Kouch.
  /// * [host] : The CouchDB host. Throws [FormatException] if valid url is not provided.
  void init({required String host});

  /// To obtain session and authorization data.
  /// * [type] : The type of authentication required.
  Future<Map<String, dynamic>> authorize({required KouchAuth auth});

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
  Future<Map<String, dynamic>> authorize({required KouchAuth auth}) async {
    assert(_host != null);
    _auth = auth;
    return await auth.authenticate(_host!);
  }

  @override
  void deInit() {
    _host = null;
  }
}
