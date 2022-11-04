class VideoModel {
  int totalVideos = 0;
  List<Video> videos = [];

  VideoModel();

  VideoModel.fromJson(Map<String, dynamic> jsonMap) {
    print("jsonMap: $jsonMap ${jsonMap.runtimeType}");

    if (jsonMap != {}) {
      print("jsonMap['data']");
      print("${jsonMap['data']} + ${jsonMap['total']}");
      // try {
      if (jsonMap.containsKey("total")) totalVideos = jsonMap['total'] != null ? jsonMap['total'] : 0;
      if (jsonMap.containsKey("data")) videos = jsonMap['data'] != null ? parseAttributes(jsonMap['data']) : [];
      /*} catch (e) {
        print("videomodel from $e ");
        totalVideos = 0;
        videos = [];
      }*/
    } else {
      print("aasdasddfsdf");
    }
  }

  static List<Video> parseAttributes(jsonData) {
    print("parseAttributes $jsonData");
    List list = jsonData;
    List<Video> attrList = list.map((data) => Video.fromJSON(data)).toList();
    return attrList;
  }
}

class Video {
  int videoId = 0;
  int soundId = 0;
  String title = "";
  String soundTitle = "";
  String url = "";
  String videoGif = "";
  String videoThumbnail = "";
  int userId = 0;
  String userDP = "";
  String soundImageUrl = "";
  String tags = "";
  String username = "";
  String fName = "";
  String lName = "";
  String description = "";
  int duration = 0;
  String createdAt = "";
  String updatedAt = "";
  int totalFollowers = 0;
  int totalLikes = 0;
  int totalComments = 0;
  int totalViews = 0;
  bool isLike = false;
  String followText = "";
  int isFollowing = 0;
  bool isVerified = false;
  int privacy = 0;

  Video();

  Video.fromJSON(Map<String, dynamic> json) {
    print(json);
    videoId = json["video_id"] ?? 0;
    soundId = json["sound_id"] == null ? 0 : json["sound_id"];
    soundTitle = json["sound_title"] == null ? '' : json["sound_title"];
    title = json["title"] == null ? '' : json["title"];
    url = json["video"] == null ? '' : json["video"];
    videoGif = json['gif'] == null ? '' : json['gif'];
    videoThumbnail = json["thumb"] == null ? '' : json["thumb"];
    userId = json['user_id'];
    username = json['username'] == null ? '' : json['username'];
    fName = json['fname'] == null ? '' : json['fname'];
    lName = json['lname'] == null ? '' : json['lname'];
    description = json["description"] == null ? '' : json["description"];
    duration = json["duration"] == null ? 0 : json["duration"];
    tags = json["tags"] == null ? '' : json["tags"];
    createdAt = json["created_at"] == null ? '' : json["created_at"];
    updatedAt = json["updated_at"] == null ? '' : json["updated_at"];
    totalLikes = json["total_likes"] == null ? 0 : json['total_likes'];
    totalViews = json["total_views"] == null ? 0 : json['total_views'];
    totalFollowers = json["total_followers"] == null ? 0 : json['total_followers'];
    totalComments = json["total_comments"] == null ? 0 : json['total_comments'];
    isLike = json["like_id"] == null
        ? false
        : (json['like_id'] > 0)
            ? true
            : false;
    userDP = json['user_dp'] ?? "";
    soundImageUrl = json['sound_image_url'] == null ? '' : json['sound_image_url'];
    followText = json['followText'] == null ? 'Follow' : json['followText'];
    isFollowing = json['isFollowing'] == null ? 0 : json['isFollowing'];
    isVerified = json['isVerified'] != null
        ? json['isVerified'] == 1
            ? true
            : false
        : false;
    privacy = json['privacy'] == null ? 0 : json['privacy'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoId'] = this.videoId;
    data['soundId'] = this.soundId;
    data['soundTitle'] = this.soundTitle;
    data['title'] = this.title;
    data['url'] = this.url;
    data['videoGif'] = this.videoGif;
    data['videoThumbnail'] = this.videoThumbnail;
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['description'] = this.description;
    data['duration'] = this.duration;
    data['tags'] = this.tags;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['totalLikes'] = this.totalLikes;
    data['totalViews'] = this.totalViews;
    data['totalComments'] = this.totalComments;
    data['isLike'] = this.isLike;
    data['userDP'] = this.userDP;
    data['soundImageUrl'] = this.soundImageUrl;
    data['followText'] = this.followText;
    data['isFollowing'] = this.isFollowing;
    data['isVerified'] = this.isVerified;
    data['privacy'] = this.privacy;
    return data;
  }
}
