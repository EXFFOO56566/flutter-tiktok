import 'package:intl/intl.dart';

import '../helpers/helper.dart';

var formatterTime = new DateFormat('hh:mm a');
var formatterDate = new DateFormat('dd MMM yyyy');

class NotificationModel {
  int total = 0;
  List<Notification> notifications = [];

  NotificationModel();

  NotificationModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      total = jsonMap['total'] != null ? jsonMap['total'] : 0;
      notifications = jsonMap['data'] != null ? parseData(jsonMap['data']) : [];
    } catch (e) {
      total = 0;
      notifications = [];
    }
  }

  static List<Notification> parseData(jsonData) {
    List list = jsonData;
    List<Notification> attrList = list.map((data) => Notification.fromJSON(data)).toList();
    return attrList;
  }
}

class Notification {
  int userId = 0;
  String firstName = '';
  String lastName = '';
  String username = '';
  String photo = '';
  String msg = '';
  int videoId = 0;
  String sentOn = '';
  String type = '';
  bool isRead = false;

  Notification();

  Notification.fromJSON(Map<String, dynamic> json) {
    try {
      userId = json["user_id"] ?? 0;
      username = json["username"] ?? '';
      firstName = json["first_name"] ?? '';
      lastName = json["last_name"] ?? '';
      photo = json["photo"] ?? '';
      msg = json["msg"] ?? '';
      type = json["type"] ?? '';
      videoId = json["video_id"] ?? 0;
      sentOn = json["sent_on"] == null
          ? ''
          : formatterDate.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sent_on"]))) +
              " " +
              formatterTime.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sent_on"])));
      isRead = json["is_read"] == 0 || json["is_read"] == null ? false : true;
    } catch (e) {
      print("Notifications Exception $e");
    }
  }
}

class NotificationSettingsModel {
  bool follow = false;
  bool like = false;
  bool comment = false;

  NotificationSettingsModel();

  NotificationSettingsModel.fromJSON(Map<String, dynamic> json) {
    follow = json["follow"] == 0 || json["follow"] == null ? false : true;
    like = json["like"] == 0 || json["like"] == null ? false : true;
    comment = json["comment"] == 0 || json["comment"] == null ? false : true;
  }
}
