class FollowingModel {
  int totalRecords = 0;
  List<Users> users = [];
  FollowingModel();

  FollowingModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      totalRecords = jsonMap['total'] != null ? jsonMap['total'] : 0;
      users = jsonMap['data'] != null ? parseAttributes(jsonMap['data']) : [];
    } catch (e) {
      totalRecords = 0;
      users = [];
      print(e);
    }
  }

  static List<Users> parseAttributes(attributesJson) {
    List list = attributesJson;
    List<Users> attrList = list.map((data) => Users.fromJSON(data)).toList();
    return attrList;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["totalRecords"] = this.totalRecords;
    map["users"] = this.users;

    return map;
  }
}

class Users {
  int id = 0;
  String dp = "";
  String username = "";
  String firstName = "";
  String lastName = "";
  String followText = "";
  bool isVerified = false;
  bool online = false;

  Users.fromJSON(Map<String, dynamic> json) {
    id = json["user_id"];
    dp = json["user_dp"] == null ? '' : json["user_dp"];
    username = json["username"] == null ? '' : json["username"];
    firstName = json["fname"] == null ? '' : json["fname"];
    lastName = json["lname"] == null ? '' : json["lname"];
    isVerified = json['isVerified'] != null
        ? json['isVerified'] == 1
            ? true
            : false
        : false;
    online = json["online"] == 0 || json["online"] == null ? false : true;
    followText = json["followText"] == null ? '' : json["followText"];
  }
}

class BlockedModel {
  int totalRecords = 0;
  List<Users> users = [];
  BlockedModel();

  BlockedModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      totalRecords = jsonMap['total'] != null ? jsonMap['total'] : 0;
      users = jsonMap['data'] != null ? parseAttributes(jsonMap['data']) : [];
    } catch (e) {
      totalRecords = 0;
      users = [];
      print(e);
    }
  }

  static List<Users> parseAttributes(attributesJson) {
    List list = attributesJson;
    List<Users> attrList = list.map((data) => Users.fromJSON(data)).toList();
    return attrList;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["totalRecords"] = this.totalRecords;
    map["users"] = this.users;

    return map;
  }
}
