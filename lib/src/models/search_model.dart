import 'hash_videos_model.dart';
import 'videos_model.dart';

class SearchModel {
  // int totalRecords = 0;
  List<Video> users = [];
  List<Videos> videos = [];
  List<dynamic> hashTags = [];

  SearchModel();

  SearchModel.fromJson(Map<String, dynamic> jsonMap) {
    // try {
    print("SearchModel.fromJson $jsonMap");
    users = jsonMap['users'] != null ? parseUsersAttributes(jsonMap['users']) : [];
    videos = jsonMap['videos'] != null ? parseVideoAttributes(jsonMap['videos']) : [];
    hashTags = jsonMap['hashTags'] != null ? jsonMap['hashTags'] : [];
    // } catch (e) {
    //   print("search model error $e");
    //   videos = [];
    //   users = [];
    // }
  }

  static List<Video> parseUsersAttributes(jsonData) {
    // try {
    List list = jsonData;
    List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
    return attrList;
    // } catch (e) {
    //   print("search model Users error $e");
    //   return [];
    // }
  }

  static List<Videos> parseVideoAttributes(attributesJson) {
    try {
      List list = attributesJson;
      List<Videos> attrList = list.map((data) => Videos.fromJSON(data)).toList();
      return attrList;
    } catch (e) {
      print("search model video error $e");
      return [];
    }
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
