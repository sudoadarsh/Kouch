import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kouch/src/errors/kouch_exception.dart';
import 'package:kouch/src/models/kouch_auth_info.dart';
import 'package:kouch/src/utils/kouch_endpoints.dart';
import 'package:kouch/src/utils/kouch_parameters.dart';

/// Interface for obtaining session and authorization data.
///
/// Types of Authentication:
/// 1. [KouchCookieAuth]
/// 2. [KouchJWTAuth]
abstract class KouchAuth {
  const KouchAuth();
  
  /// Authenticate.
  Future<KouchAuthInfo> authenticate(String host);

  /// To get the authentication headers for future CouchDB api calls.
  Map<String, String> authHeaders();
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
  Future<KouchAuthInfo> authenticate(String host) async {
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
    // Decode the response body.
    final Map<String, dynamic> decodedBody = jsonDecode(response.body);
    if (decodedBody[KouchParameters.ok]) {
      return KouchAuthInfo.fromJson(await _userInfo(host));
    }
    throw KouchAuthenticateException(response.body);
  }

  /// To get the headers based on the authenticate method used.
  @override
  Map<String, String> authHeaders() {
    return {
        KouchParameters.contentType: KouchParameters.applicationJson,
        KouchParameters.cookie: cookie ?? "",
      };
  }

  Future<Map<String, dynamic>> _userInfo(String host) async {
    // Request headers.
    final http.Response response = await http.get(
      Uri.parse(host + KouchEndpoints.session),
      headers: authHeaders(),
    );
    if (response.statusCode != 200) {
      throw KouchAuthenticateException(response.body);
    }
    return jsonDecode(response.body);
  }
}

final class KouchJWTAuth implements KouchAuth {
  /// The JWT token.
  final String token;
  const KouchJWTAuth({required this.token});

  @override
  Future<KouchAuthInfo> authenticate(String host) async {
    // // Request headers.
    // final Map<String, String> headers = {
    //   KouchParameters.contentType: KouchParameters.applicationJson,
    //   KouchParameters.authorization: "${KouchParameters.bearer} $token",
    // };
    // final http.Response response = await http.get(
    //   Uri.parse(host + KouchEndpoints.session),
    //   headers: headers,
    // );
    // if (response.statusCode != 200) {
    //   throw KouchAuthenticateException(response.body);
    // }
    // return jsonDecode(response.body);
    throw UnimplementedError();
  }

  @override
  Map<String, String> authHeaders() {
    throw UnimplementedError();
  }
}
