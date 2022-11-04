import 'dart:async';
import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pusher_client/pusher_client.dart';

import '../models/chat_model.dart';
import '../models/conversations_model.dart';
import '../models/users_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';

class ChatController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  ValueNotifier<bool> emojiShowing = new ValueNotifier(false);

  String amPm = "";
  bool showChatLoader = true;
  int page = 1;
  int userId = 0;
  bool showLoad = false;
  String msg = "";
  String message = "";
  VoidCallback listener = () {};
  double scrollPos = 0.0;
  OnlineUsersModel userObj = OnlineUsersModel();
  ScrollController chatScrollController = new ScrollController();
  ChatController() {
    scrollController = new ScrollController();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future createConversation(int userId) async {
    chatRepo.convId = await chatRepo.createConversation(userId);
  }

  void chatScrollToBottom() {
    if (chatScrollController.hasClients) {
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 2000),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> loadChat() async {
    showLoader.value = true;
    showLoader.notifyListeners();
    if (chatRepo.chatData.value.chatMessages.length == 0) {
      chatScrollController = new ScrollController();
      if (chatRepo.convId > 0) {
        chatRepo.markAsRead(chatRepo.convId);
        userRepo.echoObj.private('chat.${chatRepo.convId}').listen('NewChatMsg', (PusherEvent? e) {
          var data = jsonDecode(e!.data!);
          appendMsg(data: data);
        });
        userRepo.echoObj.private('chat.${chatRepo.convId}').listen('UserTyping', (PusherEvent? e) {
          var data = jsonDecode(e!.data!);
          if (data['typing'] == "true") {
            chatRepo.showTyping.value = true;
            chatRepo.showTyping.notifyListeners();
          } else {
            chatRepo.showTyping.value = false;
            chatRepo.showTyping.notifyListeners();
          }
        });
      }
    }

    chatRepo.chatListing(chatRepo.chatData.value.chatMessages.length, chatRepo.convId).then((obj) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (obj.totalChat == obj.chatMessages.length) {
        showChatLoader = false;
      }
      Timer(
          Duration(
            milliseconds: 1000,
          ), () {
        if (chatRepo.chatData.value.chatMessages.length <= 20) {
          chatScrollToBottom();
          listener = () async {
            if (chatScrollController.positions.isNotEmpty && chatScrollController.position.pixels == 0) {
              if (showChatLoader) {
                loadChat();
              }
            }
          };
          chatScrollController.addListener(listener);
          if (chatScrollController.positions.isNotEmpty) {
            scrollPos = chatScrollController.position.maxScrollExtent;
          }
        }
      });
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print("catchedError");
      print(e);
    });
  }

  appendMsg({data, timestamp}) async {
    DateTime timeNow = DateTime.now();
    var formatterDate = new DateFormat('dd MMM yyyy');
    var formatterDateTime = new DateFormat('yyyy-MM-dd HH:mm:ss');
    if (timeNow.hour > 11) {
      amPm = 'PM';
    } else {
      amPm = 'AM';
    }
    ChatMessage chatMessageObj = new ChatMessage();
    if (data != null) {
      data = jsonDecode(jsonEncode(data));
      var content = data['content'];
      chatMessageObj.convId = content["conversation_id"];
      chatMessageObj.userId = content["from_id"] ?? 0;
      chatMessageObj.msg = content["msg"];
      chatMessageObj.chatId = content["message_id"];
      chatMessageObj.isRead = true;
      chatMessageObj.sentDate = formatterDate.format(timeNow);
      chatMessageObj.sentDatetime = formatterDateTime.format(timeNow);
      chatMessageObj.sentOn = (timeNow.hour > 12)
          ? '${(timeNow.hour - 12).toString().length == 1 ? "0" + (timeNow.hour - 12).toString() : timeNow.hour}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute} $amPm'
          : '${timeNow.hour.toString().length == 1 ? "0" + timeNow.hour.toString() : timeNow.hour.toString()}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute.toString()} $amPm';
      chatMessageObj.timestamp = timestamp == null ? 0 : timestamp;
      if (content["msg"] != null && content["msg"].trim() != "") {
        if (content["conversation_id"] == chatRepo.convId) {
          chatRepo.myConversationData.notifyListeners();
          chatRepo.chatData.value.chatMessages.insert(0, chatMessageObj);
          chatRepo.chatData.notifyListeners();
        } else {
          try {
            Conversation latestChat = chatRepo.myConversationData.value.data.removeAt(chatRepo.myConversationData.value.data.indexWhere((element) => element.id == content["conversation_id"]));
            latestChat.message = content["msg"];
            latestChat.time = chatMessageObj.sentDatetime;
            chatRepo.myConversationData.value.data.insert(0, latestChat);
            chatRepo.myConversationData.notifyListeners();
          } catch (e) {
            chatRepo.myConversations(1, '');
          }
        }
        chatRepo.markAsRead(chatRepo.convId);
      }
    } else {
      msgController.text = '';
      chatMessageObj.convId = chatRepo.convId;
      chatMessageObj.userId = currentUser.value.userId;
      chatMessageObj.msg = message;
      chatMessageObj.isRead = true;
      chatMessageObj.sentDate = formatterDate.format(timeNow);
      chatMessageObj.sentDatetime = formatterDateTime.format(timeNow);
      chatMessageObj.sentOn = (timeNow.hour > 12)
          ? '${(timeNow.hour - 12).toString().length == 1 ? "0" + (timeNow.hour - 12).toString() : timeNow.hour}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute} $amPm'
          : '${timeNow.hour.toString().length == 1 ? "0" + timeNow.hour.toString() : timeNow.hour.toString()}:${timeNow.minute.toString().length == 1 ? "0" + timeNow.minute.toString() : timeNow.minute.toString()} $amPm';
      chatMessageObj.timestamp = timestamp;
      if (message != null && message.trim() != "") {
        message = "";
        try {
          chatRepo.chatData.value.chatMessages.insert(0, chatMessageObj);
          chatRepo.chatData.notifyListeners();
          Conversation latestChat = chatRepo.myConversationData.value.data.removeAt(chatRepo.chatData.value.chatMessages.indexWhere((element) => element.convId == chatMessageObj.convId));
          latestChat.message = chatMessageObj.msg;
          latestChat.time = chatMessageObj.sentDatetime;
          chatRepo.myConversationData.value.data.insert(0, latestChat);
          chatRepo.myConversationData.notifyListeners();
        } catch (e) {
          print("$e like");
        }
      }
    }
    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
    if (chatScrollController.positions.isNotEmpty)
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      );
  }

  Future<void> sendMsg() async {
    int timeNow = DateTime.now().millisecondsSinceEpoch;
    if (message.isNotEmpty) {
      chatRepo.sendMsg(message, userObj.id, chatRepo.convId, timeNow);
      appendMsg(timestamp: timeNow);
    }
  }

  void typing(type) {
    chatRepo.typing(chatRepo.convId, type);
  }

  onEmojiSelected(Emoji emoji) {
    msgController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(TextPosition(offset: msgController.text.length));
  }

  onBackspacePressed() {
    msgController
      ..text = msgController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(TextPosition(offset: msgController.text.length));
  }
}
