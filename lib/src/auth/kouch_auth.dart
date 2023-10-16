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
}

// final class KouchJWTAuth implements KouchAuth {}
