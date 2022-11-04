class HashVideosModel {
  int totalRecords = 0;
  List<Videos> videos = [];
  List<Banners> banners = [];

  HashVideosModel();

  HashVideosModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      totalRecords = jsonMap['total'] != null ? jsonMap['total'] : 0;
      videos = jsonMap['data'] != null ? parseVideoAttributes(jsonMap['data']) : [];
      banners = jsonMap['tagBanners'] != null ? parseBannerAttributes(jsonMap['tagBanners']) : [];
    } catch (e) {
      totalRecords = 0;
      videos = [];
      banners = [];
    }
  }

  static List<Videos> parseVideoAttributes(attributesJson) {
    List list = attributesJson;
    List<Videos> attrList = list.map((data) => Videos.fromJSON(data)).toList();
    return attrList;
  }

  static List<Banners> parseBannerAttributes(attributesJson) {
    List list = attributesJson;
    List<Banners> attrList = list.map((data) => Banners.fromJSON(data)).toList();
    return attrList;
  }
}

class Videos {
  int id = 0;
  int userId = 0;
  String dp = "";
  String thumb = "";
  String userName = "";
  bool isVerified = false;
  String tags = "";

  Videos.fromJSON(Map<String, dynamic> json) {
    id = json["video_id"];
    userId = json["user_id"];
    dp = json["user_dp"] == null ? '' : json["user_dp"];
    thumb = json["thumb"] == null ? '' : json["thumb"];
    userName = json["username"] == null ? '' : json["username"];
    tags = json["tags"] == null ? '' : json["tags"];
    isVerified = json['isVerified'] != null
        ? json['isVerified'] == 1
            ? true
            : false
        : false;
  }
}

class Banners {
  int id = 0;
  String tag = "";
  String banner = "";
  Banners.fromJSON(Map<String, dynamic> json) {
    id = json["tag_id"];
    tag = json["tag"] == null ? '' : json["tag"];
    banner = json["banner"] == null ? '' : json["banner"];
  }
}
