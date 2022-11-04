import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:leuke/src/helpers/global_keys.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/chat_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/chat_model.dart';
import '../models/users_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';

class ChatView extends StatefulWidget {
  final OnlineUsersModel userObj;
  ChatView({Key? key, required this.userObj}) : super(key: key);
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends StateMVC<ChatView> {
  ChatController _con = ChatController();
  _ChatViewState() : super(ChatController()) {
    _con = ChatController();
  }

  @override
  void initState() {
    super.initState();
    initialFunc();
  }

  initialFunc() async {
    _con.userObj = widget.userObj;
    chatRepo.convId = widget.userObj.convId;
    if (chatRepo.convId == 0) {
      await _con.createConversation(widget.userObj.id);
    }
    _con.loadChat();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () {
        _con.chatScrollController.removeListener(_con.listener);
        chatRepo.convId = 0;
        chatRepo.chatData.value = ChatModel.fromJson({});
        chatRepo.chatData.notifyListeners();
        Navigator.pushReplacementNamed(
          context,
          "/conversation",
        );
        return Future.value(true);
      },
      child: SafeArea(
        child: ValueListenableBuilder(
            valueListenable: _con.showLoader,
            builder: (context, bool loader, _) {
              return ModalProgressHUD(
                progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                inAsyncCall: loader,
                child: Scaffold(
                  backgroundColor: settingRepo.setting.value.bgColor,
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    elevation: 0,
                    iconTheme: IconThemeData(
                      size: 16,
                      color: settingRepo.setting.value.textColor, //change your color here
                    ),
                    leadingWidth: 30,
                    titleSpacing: 10,
                    backgroundColor: settingRepo.setting.value.appbarColor,
                    leading: InkWell(
                      onTap: () {
                        _con.chatScrollController.removeListener(_con.listener);
                        chatRepo.convId = 0;
                        chatRepo.chatData.value = ChatModel.fromJson({});
                        chatRepo.chatData.notifyListeners();
                        Navigator.pushReplacementNamed(
                          context,
                          "/conversation",
                        );
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: settingRepo.setting.value.iconColor,
                      ),
                    ),
                    centerTitle: true,
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          height: 80,
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: widget.userObj.userDp != ""
                                      ? CachedNetworkImage(
                                          imageUrl: widget.userObj.userDp,
                                          placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                        )
                                      : Image.asset(
                                          "assets/images/default-user.png",
                                        ),
                                ).centered(),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              ValueListenableBuilder(
                                  valueListenable: chatRepo.showTyping,
                                  builder: (context, bool typing, _) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "${widget.userObj.name}".text.ellipsis.bold.size(16).make(),
                                        typing
                                            ? Row(
                                                children: [
                                                  DefaultTextStyle(
                                                    style: const TextStyle(
                                                      fontSize: 12.0,
                                                    ),
                                                    child: AnimatedTextKit(
                                                      animatedTexts: [
                                                        TyperAnimatedText('typing...', speed: Duration(milliseconds: 100)),
                                                      ],
                                                      isRepeatingAnimation: true,
                                                      repeatForever: true,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                      ],
                                    );
                                  }),
                            ],
                          )),
                    ),
                  ),
                  body: ValueListenableBuilder(
                      valueListenable: chatRepo.chatData,
                      builder: (context, ChatModel _chat, _) {
                        return Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    color: settingRepo.setting.value.bgColor,
                                    child: SafeArea(
                                      child: _chat.chatMessages.isNotEmpty
                                          ? Container(
                                              color: settingRepo.setting.value.bgColor,
                                              padding: EdgeInsets.only(bottom: 55),
                                              child: GroupedListView<ChatMessage, String>(
                                                shrinkWrap: true,
                                                elements: _chat.chatMessages,
                                                controller: _con.chatScrollController,
                                                groupBy: (ChatMessage element) => element.sentDate,
                                                itemComparator: (item1, item2) => (DateFormat("yyyy-MM-dd HH:mm:ss").parse(item2.sentDatetime))
                                                    .millisecondsSinceEpoch
                                                    .compareTo((DateFormat("yyyy-MM-dd HH:mm:ss").parse(item1.sentDatetime)).millisecondsSinceEpoch),
                                                groupComparator: (item1, item2) =>
                                                    (DateFormat('dd MMM yyyy').parse(item2)).millisecondsSinceEpoch.compareTo((DateFormat('dd MMM yyyy').parse(item1)).millisecondsSinceEpoch),
                                                useStickyGroupSeparators: true, // optional
                                                floatingHeader: true, // optional
                                                order: GroupedListOrder.DESC, // optional
                                                groupSeparatorBuilder: (String groupByValue) {
                                                  return Container(
                                                    width: config.App(context).appWidth(100),
                                                    height: 50,
                                                    child: Row(
                                                      children: [
                                                        Expanded(child: Divider()),
                                                        Center(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 1.7),
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                6.0,
                                                              ),
                                                              margin: EdgeInsets.all(
                                                                3,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.all(
                                                                  Radius.circular(15),
                                                                ),
                                                                color: settingRepo.setting.value.dpBorderColor,
                                                              ),
                                                              child: Text(
                                                                groupByValue,
                                                                style: TextStyle(
                                                                  fontFamily: "NanumGothic",
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: settingRepo.setting.value.textColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(child: Divider()),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                itemBuilder: (context, ChatMessage message) {
                                                  return Container(
                                                    width: config.App(context).appWidth(100),
                                                    margin: EdgeInsets.only(top: 3, bottom: 3),
                                                    child: Padding(
                                                      padding: EdgeInsets.only(left: 14, right: 14, top: 3, bottom: 3),
                                                      child: Column(
                                                        crossAxisAlignment: message.userId != currentUser.value.userId ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                        children: [
                                                          Align(
                                                            alignment: (message.userId != currentUser.value.userId ? Alignment.topLeft : Alignment.topRight),
                                                            child: Row(
                                                              mainAxisAlignment: message.userId != currentUser.value.userId ? MainAxisAlignment.start : MainAxisAlignment.end,
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                message.userId != currentUser.value.userId
                                                                    ? Container(
                                                                        width: 30,
                                                                        height: 30,
                                                                        margin: EdgeInsets.only(bottom: 20),
                                                                        decoration: BoxDecoration(
                                                                          color: settingRepo.setting.value.dpBorderColor,
                                                                          borderRadius: BorderRadius.circular(100),
                                                                        ),
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(100),
                                                                          child: widget.userObj.userDp != ""
                                                                              ? CachedNetworkImage(
                                                                                  imageUrl: widget.userObj.userDp,
                                                                                  memCacheHeight: 50,
                                                                                  memCacheWidth: 50,
                                                                                  width: 40,
                                                                                  height: 40,
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : Image.asset(
                                                                                  "assets/images/default-user.png",
                                                                                ),
                                                                        ).p(2),
                                                                      )
                                                                    : Container(),
                                                                SizedBox(
                                                                  width: message.userId != currentUser.value.userId ? 5 : 0,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment: message.userId != currentUser.value.userId ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                                                  children: [
                                                                    InkWell(
                                                                      onLongPress: () {
                                                                        Clipboard.setData(new ClipboardData(text: message.msg));
                                                                        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: new Text("Copied to Clipboard")));
                                                                      },
                                                                      child: Container(
                                                                        constraints: BoxConstraints(maxWidth: config.App(context).appWidth(65)),
                                                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                                                                        decoration: BoxDecoration(
                                                                          color: message.userId == currentUser.value.userId ? settingRepo.setting.value.accentColor : settingRepo.setting.value.bgShade,
                                                                          borderRadius: BorderRadius.only(
                                                                            topRight: Radius.circular(15.0),
                                                                            bottomRight: Radius.circular(message.userId == currentUser.value.userId ? 0 : 15.0),
                                                                            bottomLeft: Radius.circular(message.userId == currentUser.value.userId ? 15.0 : 0),
                                                                            topLeft: Radius.circular(15.0),
                                                                          ),
                                                                        ),
                                                                        child: message.msg.selectableText.textStyle(TextStyle(fontSize: 14, color: settingRepo.setting.value.textColor!)).make(),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.fromLTRB(4, 2, 0, 3),
                                                                      child:
                                                                          message.sentOn.text.textStyle(TextStyle(fontSize: 10, color: settingRepo.setting.value.textColor!.withOpacity(0.6))).make(),
                                                                    )
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  width: message.userId == currentUser.value.userId ? 5 : 0,
                                                                ),
                                                                message.userId == currentUser.value.userId
                                                                    ? Container(
                                                                        width: 30,
                                                                        height: 30,
                                                                        margin: EdgeInsets.only(bottom: 20),
                                                                        decoration: BoxDecoration(
                                                                          color: settingRepo.setting.value.dpBorderColor,
                                                                          borderRadius: BorderRadius.circular(100),
                                                                        ),
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(100),
                                                                          child: currentUser.value.userDP != ""
                                                                              ? CachedNetworkImage(
                                                                                  imageUrl: currentUser.value.userDP,
                                                                                  memCacheHeight: 50,
                                                                                  memCacheWidth: 50,
                                                                                  width: 40,
                                                                                  height: 40,
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : Image.asset(
                                                                                  "assets/images/default-user.png",
                                                                                ),
                                                                        ).p(2),
                                                                      )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : SizedBox(
                                              height: 0,
                                            ),
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 0, bottom: 2, top: 0),
                                            constraints: BoxConstraints(
                                              maxHeight: 300,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: settingRepo.setting.value.bgShade,
                                            ),
                                            child: ListView(
                                              shrinkWrap: true,
                                              children: [
                                                Container(
                                                  width: config.App(context).appWidth(95),
                                                  child: TextField(
                                                    maxLines: null,
                                                    minLines: 1,
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.white,
                                                    ),
                                                    onTap: () {
                                                      if (_con.emojiShowing.value) {
                                                        _con.emojiShowing.value = false;
                                                        _con.emojiShowing.notifyListeners();
                                                      }
                                                      if (_con.chatScrollController.positions.isNotEmpty) {
                                                        Timer(
                                                          Duration(
                                                            milliseconds: 500,
                                                          ),
                                                          () => _con.chatScrollController.animateTo(
                                                            _con.chatScrollController.position.maxScrollExtent,
                                                            duration: Duration(milliseconds: 100),
                                                            curve: Curves.easeInOut,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      if (value.length == 1) {
                                                        _con.typing(true);
                                                      }
                                                      if (value.length == 0) {
                                                        _con.typing(false);
                                                      }
                                                      _con.message = value;
                                                    },
                                                    controller: _con.msgController,
                                                    decoration: InputDecoration(
                                                      // fillColor: settingRepo.setting.value.bgShade,
                                                      // filled: true,
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide.none,
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                      hintText: chatRepo.showTyping.value ? "${widget.userObj.name} is typing.." : "Say something",
                                                      hintStyle: TextStyle(fontSize: 16.0, color: Colors.white54),
                                                      prefixIcon: InkWell(
                                                        onTap: () {
                                                          FocusScope.of(context).unfocus();
                                                          _con.emojiShowing.value = !_con.emojiShowing.value;
                                                          _con.emojiShowing.notifyListeners();
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(13),
                                                          child: SvgPicture.asset(
                                                            'assets/icons/smile.svg',
                                                            width: 20,
                                                            height: 20,
                                                            fit: BoxFit.fill,
                                                            color: Colors.white54,
                                                          ),
                                                        ),
                                                      ),
                                                      contentPadding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                                    ),
                                                  ),
                                                ).centered(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _con.typing(false);
                                          _con.sendMsg();
                                        },
                                        icon: SvgPicture.asset(
                                          'assets/icons/send.svg',
                                          width: 25,
                                          height: 25,
                                          fit: BoxFit.fill,
                                          color: settingRepo.setting.value.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _con.emojiShowing,
                                builder: (context, bool showEmoji, _) {
                                  return Offstage(
                                    offstage: !showEmoji,
                                    child: SizedBox(
                                      height: 250,
                                      child: EmojiPicker(
                                          onEmojiSelected: (Category category, Emoji emoji) {
                                            _con.onEmojiSelected(emoji);
                                          },
                                          onBackspacePressed: _con.onBackspacePressed,
                                          config: Config(
                                              columns: 7,
                                              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                                              verticalSpacing: 0,
                                              horizontalSpacing: 0,
                                              initCategory: Category.RECENT,
                                              bgColor: const Color(0xFFF2F2F2),
                                              indicatorColor: Colors.blue,
                                              iconColor: Colors.grey,
                                              iconColorSelected: Colors.blue,
                                              progressIndicatorColor: Colors.blue,
                                              backspaceColor: Colors.blue,
                                              showRecentsTab: true,
                                              recentsLimit: 28,
                                              noRecentsText: 'No Recents',
                                              noRecentsStyle: const TextStyle(fontSize: 20, color: Colors.black26),
                                              tabIndicatorAnimDuration: kTabScrollDuration,
                                              categoryIcons: const CategoryIcons(),
                                              buttonMode: ButtonMode.MATERIAL)),
                                    ),
                                  );
                                }),
                          ],
                        );
                      }),
                ),
              );
            }),
      ),
    );
  }
}
