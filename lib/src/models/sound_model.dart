class SoundModelList {
  int totalRecord = 0;
  String status = "";
  List<SoundData>? data;

  SoundModelList({this.totalRecord = 0, this.status = "", this.data});

  SoundModelList.fromJSON(Map<String, dynamic> json) {
    totalRecord = json['total_record'] ?? 0;
    status = json['status'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(new SoundData.fromJSON(v));
      });
    }
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['total_record'] = this.totalRecord;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJSON()).toList();
    }
    return data;
  }
}

class SoundData {
  int soundId = 0;
  String title = "";
  String url = "";
  int userId = 0;
  String tags = "";
  String imageUrl = "";
  String category = "";
  String catId = "";
  String album = "";
  String createdAt = "";
  int duration = 0;
  int usedTimes = 0;
  int fav = 0;
  SoundData({
    this.soundId = 0,
    this.title = "",
    this.url = "",
    this.userId = 0,
    this.tags = "",
    this.imageUrl = "",
    this.duration = 0,
    this.fav = 0,
    this.category = "",
    this.album = "",
    this.catId = "",
    this.usedTimes = 0,
    this.createdAt = "",
  });

  SoundData.fromJSON(Map<String, dynamic> json) {
    soundId = json["sound_id"] == null ? 0 : json["sound_id"];
    userId = json['user_id'] == null ? 0 : json["user_id"];
    title = json['title'] == null ? "" : json["title"];
    url = json['sound_url'] == null ? "" : json["sound_url"];
    tags = json['tags'] == null ? "" : json["tags"];
    fav = json['fav'] == null ? 0 : json["fav"];
    duration = json['duration'] == null ? 0 : json["duration"];
    category = json['category'] == null ? "" : json["category"];
    catId = json['cat_id'] == null ? "" : json["cat_id"];
    album = json['album'] == null ? "" : json["album"];
    usedTimes = json['used_times'] == null ? 0 : json["used_times"];
    imageUrl = json['image_url'] == null ? "" : json["image_url"];
    createdAt = json['created_at'] == null ? "" : json["created_at"];
  }

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data["sound_id"] = this.soundId;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['sound_url'] = this.url;
    data['tags'] = this.tags;
    data['fav'] = this.fav;
    data['duration'] = this.duration;
    data['category'] = this.category;
    data['cat_id'] = this.catId;
    data['album'] = this.album;
    data['used_times'] = this.usedTimes;
    data['image_url'] = this.imageUrl;
    data['created_at'] = this.createdAt;
    return data;
  }
}
