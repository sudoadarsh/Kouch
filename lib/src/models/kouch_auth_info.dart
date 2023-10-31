class KouchAuthInfo {
  Info? info;
  bool? ok;
  UserCtx? userCtx;

  KouchAuthInfo({this.info, this.ok, this.userCtx});

  KouchAuthInfo.fromJson(Map<String, dynamic> json) {
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    ok = json['ok'];
    userCtx =
        json['userCtx'] != null ? UserCtx.fromJson(json['userCtx']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (info != null) {
      data['info'] = info!.toJson();
    }
    data['ok'] = ok;
    if (userCtx != null) {
      data['userCtx'] = userCtx!.toJson();
    }
    return data;
  }
}

class Info {
  String? authenticated;
  String? authenticationDb;
  List<String>? authenticationHandlers;

  Info(
      {this.authenticated, this.authenticationDb, this.authenticationHandlers});

  Info.fromJson(Map<String, dynamic> json) {
    authenticated = json['authenticated'];
    authenticationDb = json['authentication_db'];
    authenticationHandlers = json['authentication_handlers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['authenticated'] = authenticated;
    data['authentication_db'] = authenticationDb;
    data['authentication_handlers'] = authenticationHandlers;
    return data;
  }
}

class UserCtx {
  String? name;
  List<String>? roles;

  UserCtx({this.name, this.roles});

  UserCtx.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    roles = json['roles'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['roles'] = roles;
    return data;
  }
}
