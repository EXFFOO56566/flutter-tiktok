import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_client/pusher_client.dart';

import '../helpers/global_keys.dart';
import '../helpers/helper.dart';
import '../models/chat_model.dart';
import '../models/conversations_model.dart';
import '../models/following_model.dart';
import '../models/users_model.dart';
import 'user_repository.dart';

ValueNotifier<ChatModel> chatData = new ValueNotifier(ChatModel());
ValueNotifier<ChatModel> chatHistoryData = new ValueNotifier(ChatModel());
ValueNotifier<ConversationsModel> myConversationData = new ValueNotifier(ConversationsModel());
ValueNotifier<List<int>> onlineUserIds = new ValueNotifier([]);
ValueNotifier<List<OnlineUsersModel>> onlineUsers = new ValueNotifier([]);
ValueNotifier<FollowingModel> peopleData = new ValueNotifier(FollowingModel());
ValueNotifier<FollowingModel> chatService = new ValueNotifier(FollowingModel());
ValueNotifier<bool> showTyping = new ValueNotifier(false);
ValueNotifier<String> chatSettings = new ValueNotifier('');
int convId = 0;

Future chatListing(skip, convId) async {
  Uri uri = Helper.getUri('message/$convId/get-messages');
  uri = uri.replace(queryParameters: {'skip': skip.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status']) {
        var data = ChatModel.fromJson(json.decode(response.body)['data']);
        chatData.value.totalChat = data.totalChat;
        chatData.value.chatMessages.addAll(data.chatMessages);
        chatData.notifyListeners();
        return chatData.value;
      } else {
        ChatModel.fromJson({});
      }
    } else {
      ChatModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    ChatModel.fromJson({});
  }
}

Future onlineUsersList(String userIds) async {
  Uri uri = Helper.getUri('get-online-users');
  uri = uri.replace(queryParameters: {'ids': userIds.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        print(response.body);
        if (onlineUsers.value.isEmpty) {
          for (var item in json.decode(response.body)['data']) {
            onlineUsers.value.add(OnlineUsersModel.fromJson(item));
          }
        } else {
          List<OnlineUsersModel> tempOnlineUsers = [];
          for (var item in json.decode(response.body)['data']) {
            OnlineUsersModel iUser = OnlineUsersModel.fromJson(item);
            if (!onlineUserIds.value.contains(iUser.id)) {
              tempOnlineUsers.add(OnlineUsersModel.fromJson(item));
            }
          }
          onlineUsers.value.addAll(tempOnlineUsers);
        }
        onlineUsers.notifyListeners();
        return onlineUsers.value;
      }
    } else {
      return [];
    }
  } catch (e) {
    print("error $e");
    return [];
  }
}

Future<ChatModel> chatHistoryListing(page) async {
  Uri uri = Helper.getUri('chat-history');
  uri = uri.replace(queryParameters: {'page': page.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          chatHistoryData.value.chatMessages.insertAll(0, ChatModel.fromJson(json.decode(response.body)['data']).chatMessages);
        } else {
          chatHistoryData.value = ChatModel.fromJson(json.decode(response.body)['data']);
        }
        chatHistoryData.notifyListeners();
        return chatData.value;
      } else {
        return ChatModel.fromJson({});
      }
    } else {
      return ChatModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return ChatModel.fromJson({});
  }
}

Future<ConversationsModel> myConversations(page, searchKeyword) async {
  Uri uri = Helper.getUri('conversation/get');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status']) {
        if (page > 1) {
          myConversationData.value.data.addAll(ConversationsModel.fromJSON(json.decode(response.body)).data);
        } else {
          myConversationData.value = ConversationsModel.fromJSON(json.decode(response.body));
        }
        myConversationData.value.data.forEach((element) {
          if (onlineUserIds.value.contains(element.userId)) {
            element.online = true;
          }
        });
        myConversationData.notifyListeners();
        return myConversationData.value;
      } else {
        return ConversationsModel.fromJSON({});
      }
    } else {
      return ConversationsModel.fromJSON({});
    }
  } catch (e) {
    return ConversationsModel.fromJSON({});
  }
}

Future<FollowingModel> getPeople(page, searchKeyword) async {
  Uri uri = Helper.getUri('chat-users');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          peopleData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          peopleData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        peopleData.value.users.forEach((element) {
          if (onlineUserIds.value.contains(element.id)) {
            element.online = true;
          }
        });
        peopleData.notifyListeners();
        return peopleData.value;
      } else {
        return FollowingModel.fromJson({});
      }
    } else {
      return FollowingModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return FollowingModel.fromJson({});
  }
}

Future<bool> sendMsg(msg, userId, convId, timestamp) async {
  print("sendMsg api");
  Uri uri = Helper.getUri('message/$convId/store');
  print("timestamp: $timestamp");
  try {
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + currentUser.value.token,
      "X-Socket-Id": socketId.value,
    };
    var response = await http.post(uri, headers: headers, body: {
      'msg': msg,
      'to_user': userId.toString(),
      "timestamp": timestamp.toString(),
    });
    print("sendMsg response.body ${response.body}");
    var jsonData = jsonDecode(response.body);

    if (jsonData['status']) {
      return true;
    } else {
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text('${jsonData['msg']}')));
      chatData.value.chatMessages.removeWhere((element) => element.timestamp.toString() == jsonData['timestamp'].toString());
      chatData.notifyListeners();
      return false;
    }
  } catch (e) {
    print("chat send error $e");
    return false;
    ChatModel.fromJson({});
  }
}

markAsRead(convId) async {
  Uri uri = Helper.getUri('message/$convId/read');
  try {
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + currentUser.value.token,
      "X-Socket-Id": socketId.value,
    };
    var response = await http.post(uri, headers: headers);
    print("markAsRead ${response.body}");
  } catch (e) {
    print(e.toString());
    ChatModel.fromJson({});
  }
}

typing(convId, type) async {
  Uri uri = Helper.getUri('message/$convId/typing');
  try {
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + currentUser.value.token,
      "X-Socket-Id": socketId.value,
    };

    var response = await http.post(uri, headers: headers, body: {
      'typing': type.toString(),
    });
  } catch (e) {
    print(e.toString());
  }
}

Future<int> createConversation(int userId) async {
  Uri uri = Helper.getUri('conversation/store');
  uri = uri.replace(queryParameters: {
    'user_id': userId.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['status']) {
        return jsonData['id'];
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  } catch (e) {
    print(e.toString());
    return 0;
  }
}

joinSocketUser() async {
  print("Enter in joinSocketUser");
  echoObj.join('chat').here((PusherEvent? users) {
    print("Enter in Here ${users!.data}");
    socketId.value = echoObj.socketId()!;
    print("Socket Id ${echoObj.socketId()}");
    socketId.notifyListeners();
    List<int> ids = [];
    if (users.data != null) {
      ids = Helper.parsePusherEventData(users.data);
      onlineUserIds.value = ids;
      onlineUserIds.notifyListeners();
      onlineUsersList(ids.join(','));
    }
    if (onlineUserIds.value.length > 0 && myConversationData.value.data.length > 0) {
      for (int i = 0; i < myConversationData.value.data.length; i++) {
        for (int j = 0; j < onlineUserIds.value.length; j++) {
          if (onlineUserIds.value.elementAt(j).toString() == myConversationData.value.data.elementAt(i).userId.toString()) {
            myConversationData.value.data.elementAt(i).online = true;
            myConversationData.notifyListeners();
          }
        }
      }
    }
  }).joining((PusherEvent? user) {
    print("Enter in Joining ${user!.userId}");
    if (user.userId != null && myConversationData.value.data.length > 0) {
      for (int i = 0; i < myConversationData.value.data.length; i++) {
        if (user.userId == myConversationData.value.data.elementAt(i).userId.toString()) {
          myConversationData.value.data.elementAt(i).online = true;
          myConversationData.notifyListeners();
        }
      }
      if (!onlineUserIds.value.contains(int.parse(user.userId!))) {
        onlineUserIds.value.add(int.parse(user.userId!));
        onlineUserIds.notifyListeners();
        onlineUsersList(user.userId!);
      }
    }
  }).leaving((PusherEvent? user) {
    print("Enter in Leaving ${user}");
    if (user != null && user.userId != null && myConversationData.value.data.length > 0) {
      for (int i = 0; i < myConversationData.value.data.length; i++) {
        if (user.userId == myConversationData.value.data.elementAt(i).userId.toString()) {
          myConversationData.value.data.elementAt(i).online = false;
          myConversationData.notifyListeners();
        }
      }
      if (onlineUserIds.value.contains(int.parse(user.userId!))) {
        onlineUserIds.value.remove(int.parse(user.userId!));
        onlineUserIds.notifyListeners();
        onlineUsers.value.removeWhere((element) => element.id == int.parse(user.userId!));
        onlineUsers.notifyListeners();
      }
    }
  }).listen('PresenceEvent', (e) {
    print(e);
  });
}

Future<void> getChatSettings() async {
  Uri uri = Helper.getUri('get-chat-with');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var rs = await Dio().post(
    uri.toString(),
    options: Options(headers: headers),
  );
  if (rs.statusCode == 200) {
    if (rs.data['status'] && rs.data['chatWith'] != null) {
      chatSettings.value = rs.data['chatWith'];
      chatSettings.notifyListeners();
    }
  }
}

Future<void> updateChatSetting() async {
  Uri uri = Helper.getUri('get-chat-with');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var rs = await Dio().post(
    uri.toString(),
    options: Options(headers: headers),
    queryParameters: {
      "chat_with": chatSettings.value,
    },
  );
  if (rs.statusCode == 200) {
    ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text('Chat setting updated!')));
  }
}
