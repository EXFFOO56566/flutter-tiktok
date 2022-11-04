class EditProfileModel {
  int id = 0;
  int userId = 0;
  String name = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String userName = "";
  String mobile = "";
  String gender = "";
  String bio = "";
  String dp = "";
  DateTime dob = DateTime.now();
  String appToken = "";
  String token = "";
  String userDP = "";
  String country = "";
  String largeProfilePic = "";
  String smallProfilePic = "";
  int isAnyUserFollow = 0;
  EditProfileModel();

  EditProfileModel.fromJson(Map<String, dynamic> json) {
    try {
      id = json['user_id'];
      firstName = json['fname'];
      lastName = json['lname'] != null ? json['lname'] : '';
      name = firstName + " " + lastName;
      userName = json['username'];
      email = json['email'];
      mobile = json['mobile'] != null ? json['mobile'] : '';
      gender = json['gender'] != null ? json['gender'] : '';
      bio = json['bio'] != null ? json['bio'] : '';
      dp = json['user_dp'] != null ? json['user_dp'] : '';
      largeProfilePic = json['large_pic'] != null ? json['large_pic'] : '';
      smallProfilePic = json['small_pic'] != null ? json['small_pic'] : '';
      dob = json['dob'] != null ? DateTime.parse(json['dob']) : DateTime.now();
      country = json['country'] != null ? json['country'] : '';
    } catch (e) {
      id = 0;
      firstName = '';
      lastName = '';
      name = '';
      userName = '';
      email = '';
      mobile = '';
      gender = '';
      bio = '';
      dp = '';
      largeProfilePic = '';
      smallProfilePic = '';
      dob = DateTime.now();
      country = '';
    }
  }

  EditProfileModel.fromJSON(Map<String, dynamic> json) {
    try {
      userId = json['user_id'];
      name = json['first_name'] + " " + json['last_name'];
      userName = json['username'];
      email = json['email'];
      token = json['app_token'] != null ? json['app_token'] : '';
      userDP = json['user_dp'] != null ? json['user_dp'] : '';
      isAnyUserFollow = json['is_following_videos'] != null ? json['is_following_videos'] : 0;
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['username'] = this.userName;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['gender'] = this.gender;
    data['bio'] = this.bio;
    data['dob'] = this.dob.toString();
    data['app_token'] = this.appToken;
    return data;
  }
}
