import '../models/videos_model.dart';

class UserProfileModel {
  int totalRecords = 0;
  String totalVideosLike = "";
  String totalFollowings = "";
  String totalFollowers = "";
  int totalVideos = 0;
  String blocked = "";
  String largeProfilePic = "";
  String smallProfilePic = "";
  String followText = "";
  String name = "";
  String bio = "";
  String username = "";
  String appVersion = "";
  bool isVerified = false;
  List<Video> userVideos = [];
  UserProfileModel();

  UserProfileModel.fromJson(Map<String, dynamic> jsonMap) {
    // try {
    totalRecords = jsonMap['totalRecords'] != null ? jsonMap['totalRecords'] : 0;
    totalVideosLike = jsonMap['totalVideosLike'] != null ? jsonMap['totalVideosLike'] : '';
    totalFollowings = jsonMap['totalFollowings'] != null ? jsonMap['totalFollowings'].toString() : '';
    totalFollowers = jsonMap['totalFollowers'] != null ? jsonMap['totalFollowers'].toString() : '';
    totalVideos = jsonMap['totalVideos'] != null ? jsonMap['totalVideos'] : 0;
    blocked = jsonMap['blocked'] != null ? jsonMap['blocked'] : '';
    largeProfilePic = jsonMap['large_pic'] != null ? jsonMap['large_pic'] : '';
    smallProfilePic = jsonMap['small_pic'] != null ? jsonMap['small_pic'] : '';
    followText = jsonMap['followText'] != null ? jsonMap['followText'] : '';
    name = jsonMap['name'] != null ? jsonMap['name'] : '';
    username = jsonMap['username'] != null ? jsonMap['username'] : '';
    appVersion = jsonMap['version'] != null ? jsonMap['version'] : '';
    bio = jsonMap['bio'] != null ? jsonMap['bio'] : '';
    userVideos = jsonMap['data'] != null ? parseAttributes(jsonMap['data']) : [];
    isVerified = jsonMap['isVerified'] != null
        ? jsonMap['isVerified'] == 1
            ? true
            : false
        : false;
    /*} catch (e) {
      print("UserProfileModel  error $e");
    }*/
  }

  static List<Video> parseAttributes(attributesJson) {
    print("parseAttributes");
    List list = attributesJson;
    List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
    return attrList;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["totalRecords"] = this.totalRecords;
    map["totalVideosLike"] = this.totalVideosLike;
    map["totalFollowings"] = this.totalFollowings;
    map["totalFollowers"] = this.totalFollowers;
    map["totalVideos"] = this.totalVideos;
    map["blocked"] = this.blocked;
    map["largeProfilePic"] = this.largeProfilePic;
    map["smallProfilePic"] = this.smallProfilePic;
    map["followText"] = this.followText;
    map["name"] = this.name;
    map["username"] = this.username;
    map["isVerified"] = this.isVerified;
    map["userVideos"] = this.userVideos;
    map["version"] = this.appVersion;
    return map;
  }
}
