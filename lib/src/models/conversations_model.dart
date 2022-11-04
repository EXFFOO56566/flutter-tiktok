import 'package:intl/intl.dart';

var formatterTime = new DateFormat('hh:mm a');
var formatterDate = new DateFormat('dd MMM yyyy');

class ConversationsModel {
  int total = 0;
  List<Conversation> data = [];
  ConversationsModel();
  ConversationsModel.fromJSON(Map<String, dynamic> json) {
    try {
      total = json['totalRecords'] ?? 0;
      data = json['data'] != null ? parseData(json['data']) : [];
    } catch (e) {
      total = 0;
      data = [];
      print("Exception: " + e.toString());
    }
  }

  static List<Conversation> parseData(jsonData) {
    List _list = jsonData;
    List<Conversation> list = _list.map((data) => Conversation.fromJSON(data)).toList();
    return list;
  }
}

class Conversation {
  int id = 0;
  int userId = 0;
  String personName = '';
  String userName = '';
  String userDp = '';
  String message = '';
  String time = '';
  bool online = false;
  bool isRead = false;
  Conversation({this.id = 0, this.userId = 0, this.personName = "", this.userName = "", this.userDp = "", this.message = "", this.time = "", this.online = false, this.isRead = false});
  Conversation.fromJSON(Map<String, dynamic> json) {
    try {
      id = json["id"] ?? 0;
      userId = json["user_id"] ?? 0;
      personName = json["person_name"] ?? '';
      userName = json["username"] ?? '';
      userDp = json["user_dp"] ?? '';
      message = json["message"] ?? '';
      time = json["time"] ?? '';
      online = json["online"] == 0 || json["online"] == null ? false : true;
      isRead = json["isRead"] == 0 || json["isRead"] == null ? false : true;
    } catch (e) {
      id = 0;
      userId = 0;
      personName = '';
      userName = '';
      userDp = '';
      message = '';
      time = '';
      online = false;
      isRead = false;
      print("Exceptionsssssssssss: " + e.toString());
    }
  }
}
