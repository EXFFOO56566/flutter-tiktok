class UserVideoModel {
  String videoID = "";
  String videoPath = "";
  String thumbImgUrl = "";
  String description = "";

  UserVideoModel({this.videoID = "", this.videoPath = "", this.thumbImgUrl = "", this.description = ""});

  UserVideoModel.fromJson(Map<String, dynamic> json) {
    videoID = json['videoID'];
    videoPath = json['videopath'];
    thumbImgUrl = json['thumbimgurl'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoID'] = this.videoID;
    data['videopath'] = this.videoPath;
    data['thumbimgurl'] = this.thumbImgUrl;
    data['description'] = this.description;

    return data;
  }
}
