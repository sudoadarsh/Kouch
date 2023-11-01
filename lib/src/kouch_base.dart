import 'dart:convert';

import 'package:kouch/src/auth/kouch_auth.dart';
import 'package:kouch/src/database/kouch_database.dart';
import 'package:kouch/src/errors/kouch_exception.dart';
import 'package:kouch/src/models/kouch_auth_info.dart';
import 'package:kouch/src/utils/kouch_endpoints.dart';
import 'package:kouch/src/utils/kouch_parameters.dart';
import 'package:http/http.dart' as http;

/// An Instance of CouchDB.
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

  /// To obtain a list of all the databases in the CouchDB instance.
  /// * [descending] : Return the databases in descending order by key. Default is false.
  /// * [endKey] : Stop returning databases when the specified key is reached.
  /// * [endKeyAlias] : Alias for endKey param.
  /// * [limit] : Limit the number of the returned databases to the specified number.
  /// * [skip] :  Skip this number of databases before starting to return the results. Default is 0.
  /// * [startKey] : Return databases starting with the specified key.
  /// * [startKeyAlias] : Alias for startKey.
  Future<List<String>> getAllDatabases({
    bool descending,
    String? endKey,
    String? endKeyAlias,
    int? limit,
    int skip,
    String? startKey,
    String? startKeyAlias,
  });

  /// Instance of CouchDB database.
  /// * [name] : The name of the database.
  /// ## Caution:
  /// Name must begin with a lowercase letter (a-z) and can contain
  /// * Lowercase characters (a-z)
  /// * Digits (0-9)
  /// * Any of the characters _, $, (, ), +, -, and /.
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
    assert(_auth != null);
    // Validate the name of the database.
    if (RegExp(r'^[a-z][a-z0-9_$()+/-]*$').hasMatch(name)) {
      return KouchDatabase(_host!, _auth!, name: name);
    }
    throw KouchDatabaseException("Invalid Database name!");
  }

  @override
  Future<List<String>> getAllDatabases({
    bool descending = false,
    String? endKey,
    String? endKeyAlias,
    int? limit,
    int skip = 0,
    String? startKey,
    String? startKeyAlias,
  }) async {
    // Create the query parameters.
    final Map<String, String> query = {
      KouchParameters.descending: descending.toString(),
      KouchParameters.skip: skip.toString(),
    };
    if (endKey != null) query[KouchParameters.endKey] = endKey;
    if (endKeyAlias != null) query[KouchParameters.endKeyAlias] = endKeyAlias;
    if (limit != null) query[KouchParameters.limit] = limit.toString();
    if (startKey != null) query[KouchParameters.startKey] = startKey;
    if (startKeyAlias != null) {
      query[KouchParameters.startKeyAlias] = startKeyAlias;
    }
    // Create the request.
    http.Response response = await http.get(
      Uri.parse(_host! + KouchEndpoints.allDbs).replace(queryParameters: query),
      headers: _auth?.authHeaders()
    );
    // Validate the response.
    if (response.statusCode != 200) throw KouchDatabaseException(response.body);
    final List<dynamic> dbs = jsonDecode(response.body);
    return dbs.map((e) => e as String).toList();
  }

  @override
  void deInit() {
    _host = null;
    _auth = null;
  }
}
