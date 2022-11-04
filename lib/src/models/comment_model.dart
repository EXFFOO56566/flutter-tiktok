class CommentModel {
  String status;
  CommentData? data;
  int totalRecords;

  CommentModel({required this.data, this.status = "", this.totalRecords = 0});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      data: json['data'] != null ? CommentData.fromJson(json['data']) : null,
      status: json['status'],
      totalRecords: json['total_records'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CommentData {
  int commentId = 0;
  int userId = 0;
  String userName = "";
  bool isVerified = false;
  String userDp = "";
  String comment = "";
  String time = "";
  int videoId = 0;
  String token = "";
  CommentData();

  CommentData.fromJson(Map<String, dynamic> json) {
    try {
      commentId = json['comment_id'];
      userId = json['user_id'];
      userName = json['name'];
      comment = json['comment'];
      userDp = json['pic'] != null ? json['pic'] : '';
      time = json['timing'] != null ? json['timing'] : '';
      isVerified = json['isVerified'] != null
          ? json['isVerified'] == 1
              ? true
              : false
          : false;
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['commentId'] = this.commentId;
    data['comment'] = this.comment;
    data['time'] = this.time;
    data['userDp'] = this.userDp;
    data['videoId'] = this.videoId;
    data['token'] = this.token;
    data['isVerified'] = this.isVerified;
    return data;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = userId;
    map['userName'] = userName;
    map['commentId'] = commentId;
    map['comment'] = comment;
    map['time'] = time;
    map['userDp'] = userDp;
    map['isVerified'] = isVerified;
    return map;
  }
}
