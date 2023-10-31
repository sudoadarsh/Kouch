import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kouch/src/errors/kouch_exception.dart';
import 'package:kouch/src/utils/kouch_endpoints.dart';
import 'package:kouch/src/utils/kouch_parameters.dart';

/// Interface for obtaining session and authorization data.
///
/// Types of Authentication:
/// 1. [KouchCookieAuth]
/// 2. [KouchJWTAuth]
abstract class KouchAuth {
  /// Authenticate.
  Future<Map<String, dynamic>> authenticate(String host);
  /// To get the authentication headers for future CouchDB api calls.
  Map<String, String> authHeaders();
  const KouchAuth();
}

final class KouchCookieAuth implements KouchAuth {
  /// The CouchDB username.
  final String username;

  /// The CouchDB password.
  final String password;

  KouchCookieAuth({required this.username, required this.password});

  /// The authenticate cookie.
  String? cookie;

  @override
  Future<Map<String, dynamic>> authenticate(String host) async {
    // Request headers.
    final Map<String, String> headers = {
      KouchParameters.contentType: KouchParameters.applicationForm,
    };
    // Request body.
    final Map<String, String> body = {
      KouchParameters.name: username,
      KouchParameters.password: password,
    };
    // Authenticate.
    final http.Response response = await http.post(
      Uri.parse(host + KouchEndpoints.session),
      headers: headers,
      body: body,
    );
    // Validate the response.
    if (response.statusCode != 200) {
      throw KouchAuthenticateException(response.body);
    }
    // Get the session cookie from the response headers.
    cookie = response.headers[KouchParameters.setCookie];
    if (cookie == null) throw KouchAuthenticateException("Invalid Cookie");
    return jsonDecode(response.body);
  }

  /// To get the headers based on the authenticate method used.
  @override
  Map<String, String> authHeaders() => {
      KouchParameters.contentType: KouchParameters.applicationJson,
      KouchParameters.cookie: cookie ?? "",
    };
}

final class KouchJWTAuth implements KouchAuth {
  /// The JWT token.
  final String token;
  const KouchJWTAuth({required this.token});

  @override
  Future<Map<String, dynamic>> authenticate(String host) async {
    // Request headers.
    final Map<String, String> headers = {
      KouchParameters.contentType: KouchParameters.applicationJson,
      KouchParameters.authorization: "${KouchParameters.bearer} $token",
    };
    final http.Response response = await http.get(
      Uri.parse(host + KouchEndpoints.session),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw KouchAuthenticateException(response.body);
    }
    return jsonDecode(response.body);
  }

  @override
  Map<String, String> authHeaders() {
    throw UnimplementedError();
  }
}
