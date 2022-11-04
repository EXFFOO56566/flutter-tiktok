import 'package:intl/intl.dart';

import '../helpers/helper.dart';

var formatterTime = new DateFormat('hh:mm a');
var formatterDate = new DateFormat('dd MMM yyyy');

class ChatModel {
  int totalChat = 0;
  List<ChatMessage> chatMessages = [];

  ChatModel();

  ChatModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      totalChat = jsonMap['total'] ?? 0;
      chatMessages = jsonMap['data'] != null ? parseData(jsonMap['data']) : [];
    } catch (e) {
      totalChat = 0;
      chatMessages = [];
    }
  }

  static List<ChatMessage> parseData(jsonData) {
    List list = jsonData;
    List<ChatMessage> attrList = list.map((data) => ChatMessage.fromJSON(data)).toList();
    return attrList;
  }
}

class ChatMessage {
  int chatId = 0;
  String msg = '';
  bool isRead = false;
  String sentOn = '';
  String sentDate = '';
  String sentDatetime = '';
  int convId = 0;
  int userId = 0;
  int timestamp = 0;

  ChatMessage();

  ChatMessage.fromJSON(Map<String, dynamic> json) {
    chatId = json["id"] ?? 0;
    msg = json["msg"] ?? '';
    isRead = json["isRead"] == null || json["isRead"] == 0 ? false : true;
    sentOn = json["sentOn"] == null ? '' : formatterTime.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sentOn"])));
    sentDate = json["sentOn"] == null ? '' : formatterDate.format(Helper.getYourCountryTime(DateFormat("yyyy-MM-dd HH:mm:ss").parse(json["sentOn"])));
    sentDatetime = json["sentOn"] == null ? '' : json["sentOn"];
    convId = json["convId"] ?? 0;
    userId = json["userId"] ?? 0;
  }
}
