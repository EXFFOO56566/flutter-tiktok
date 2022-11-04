import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/chat_list_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/conversations_model.dart';
import '../models/following_model.dart';
import '../models/users_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'chat_view.dart';

class ConversationsView extends StatefulWidget {
  @override
  _ConversationsViewState createState() => _ConversationsViewState();
}

class _ConversationsViewState extends StateMVC<ConversationsView> {
  ChatListController _con = ChatListController();
  _ConversationsViewState() : super(ChatListController()) {
    _con = ChatListController();
  }

  int active = 1;
  @override
  void initState() {
    super.initState();
    _con.myConversations(1);
    print("onlineUserIds ${chatRepo.onlineUserIds.value}");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/home');
        return Future.value(true);
      },
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: settingRepo.setting.value.bgColor,
          appBar: AppBar(
            elevation: 0,
            iconTheme: IconThemeData(
              size: 16,
              color: settingRepo.setting.value.textColor, //change your color here
            ),
            backgroundColor: settingRepo.setting.value.appbarColor,
            leading: InkWell(
              onTap: () {
                videoRepo.homeCon.value.showFollowingPage.value = false;
                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                videoRepo.homeCon.value.getVideos();
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: Icon(
                Icons.arrow_back,
                color: settingRepo.setting.value.iconColor,
              ),
            ),
            centerTitle: true,
            title: "Conversations".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
          ),
          body: ValueListenableBuilder(
              valueListenable: chatRepo.myConversationData,
              builder: (context, ConversationsModel _conversation, _) {
                return ValueListenableBuilder(
                    valueListenable: _con.showLoader,
                    builder: (context, bool loader, _) {
                      return ModalProgressHUD(
                        inAsyncCall: loader,
                        progressIndicator: Helper.showLoaderSpinner(
                          settingRepo.setting.value.textColor!,
                        ),
                        child: !_con.showLoading
                            ? SingleChildScrollView(
                                controller: _con.scrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      color: settingRepo.setting.value.bgShade,
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: 5, bottom: 5, right: MediaQuery.of(context).size.width * 0.02),
                                            child: Container(
                                              width: MediaQuery.of(context).size.width * 0.96,
                                              height: 40,
                                              child: TextField(
                                                controller: _con.searchController,
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 16.0,
                                                ),
                                                obscureText: false,
                                                keyboardType: TextInputType.text,
                                                onChanged: (String val) {
                                                  setState(() {
                                                    _con.searchKeyword = val;
                                                  });
                                                },
                                                onSubmitted: (String val) {
                                                  if (active == 1) {
                                                    _con.myConversations(1, showApiLoader: false);
                                                  } else {
                                                    _con.getPeople(1);
                                                  }
                                                },
                                                decoration: new InputDecoration(
                                                  fillColor: Colors.black38,
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius: BorderRadius.circular(50),
                                                  ),
                                                  hintText: "Search",
                                                  hintStyle: TextStyle(fontSize: 16.0, color: Colors.white54),
                                                  prefixIcon: Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/search.svg',
                                                      fit: BoxFit.contain,
                                                      color: Colors.white54,
                                                    ),
                                                  ),
                                                  contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                                  suffixIcon: IconButton(
                                                    padding: EdgeInsets.only(bottom: 0, right: 0),
                                                    onPressed: () {
                                                      setState(() {
                                                        _con.searchKeyword = "";
                                                        _con.searchController = TextEditingController();
                                                      });
                                                      if (active == 1) {
                                                        _con.myConversations(1, showApiLoader: false);
                                                      } else {
                                                        _con.getPeople(1);
                                                      }
                                                    },
                                                    icon: Icon(
                                                      Icons.clear,
                                                      color: (_con.searchKeyword.length > 0) ? settingRepo.setting.value.iconColor : Colors.transparent,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ValueListenableBuilder(
                                              valueListenable: chatRepo.onlineUsers,
                                              builder: (context, List<OnlineUsersModel> _onlineUsers, _) {
                                                _onlineUsers.toSet().toList();
                                                return _onlineUsers.length > 0
                                                    ? Container(
                                                        height: 65,
                                                        width: MediaQuery.of(context).size.width,
                                                        padding: EdgeInsets.symmetric(horizontal: 15),
                                                        child: ListView.builder(
                                                          itemCount: _onlineUsers.length,
                                                          shrinkWrap: true,
                                                          scrollDirection: Axis.horizontal,
                                                          padding: EdgeInsets.zero,
                                                          itemBuilder: (context, index) {
                                                            final onlineUserItem = _onlineUsers.elementAt(index);
                                                            return InkWell(
                                                              onTap: () {
                                                                OnlineUsersModel _onlineUsersModel = new OnlineUsersModel();
                                                                _onlineUsersModel.convId = 0;
                                                                _onlineUsersModel.id = onlineUserItem.id;
                                                                _onlineUsersModel.name = onlineUserItem.name;
                                                                _onlineUsersModel.userDp = onlineUserItem.userDp;
                                                                _onlineUsersModel.online = onlineUserItem.online;
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ChatView(userObj: _onlineUsersModel),
                                                                  ),
                                                                );
                                                              },
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    width: 40,
                                                                    height: 40,
                                                                    decoration: BoxDecoration(
                                                                      color: settingRepo.setting.value.accentColor,
                                                                      borderRadius: BorderRadius.circular(100),
                                                                    ),
                                                                    child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(100),
                                                                      child: onlineUserItem.userDp != ""
                                                                          ? CachedNetworkImage(
                                                                              imageUrl: onlineUserItem.userDp,
                                                                              memCacheHeight: 40,
                                                                              placeholder: (context, url) => Center(
                                                                                child: Helper.showLoaderSpinner(Colors.white),
                                                                              ),
                                                                              fit: BoxFit.cover,
                                                                              width: 40,
                                                                              height: 40,
                                                                            )
                                                                          : Image.asset(
                                                                              "assets/images/default-user.png",
                                                                              width: 40,
                                                                              height: 40,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                    ).p(3),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Container(
                                                                    width: 50,
                                                                    child: "${onlineUserItem.name}"
                                                                        .text
                                                                        .bold
                                                                        .size(12)
                                                                        .color(settingRepo.setting.value.textColor!.withOpacity(0.5))
                                                                        .ellipsis
                                                                        .make()
                                                                        .centered(),
                                                                  )
                                                                ],
                                                              ).pOnly(right: 15),
                                                            );
                                                          },
                                                        ),
                                                      ).pOnly(left: 10, top: 3)
                                                    : SizedBox(
                                                        height: 0,
                                                      );
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 20),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                active = 1;
                                                _con.searchKeyword = '';
                                                _con.searchController = TextEditingController();
                                              });
                                              _con.myConversations(1, showApiLoader: false);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: active == 1
                                                    ? Border(
                                                        bottom: BorderSide(
                                                          color: settingRepo.setting.value.accentColor!,
                                                          width: 2.5,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              child: "Chat"
                                                  .text
                                                  .uppercase
                                                  .bold
                                                  .size(16)
                                                  .color(active == 1 ? settingRepo.setting.value.accentColor! : settingRepo.setting.value.textColor!)
                                                  .make()
                                                  .pSymmetric(h: 15, v: 15),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                active = 2;
                                                _con.searchKeyword = '';
                                                _con.searchController = TextEditingController();
                                              });
                                              _con.getPeople(1);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: active == 2
                                                    ? Border(
                                                        bottom: BorderSide(
                                                          color: settingRepo.setting.value.accentColor!,
                                                          width: 2.5,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              child: "People"
                                                  .text
                                                  .uppercase
                                                  .bold
                                                  .size(16)
                                                  .color(active == 2 ? settingRepo.setting.value.accentColor! : settingRepo.setting.value.textColor!)
                                                  .make()
                                                  .pSymmetric(h: 15, v: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    active == 1
                                        ? ValueListenableBuilder(
                                            valueListenable: chatRepo.myConversationData,
                                            builder: (context, ConversationsModel _conversation, _) {
                                              return Container(
                                                width: MediaQuery.of(context).size.width,
                                                padding: EdgeInsets.symmetric(horizontal: 15),
                                                child: _conversation.data.length > 0
                                                    ? ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _conversation.data.length,
                                                        shrinkWrap: true,
                                                        itemExtent: 60,
                                                        scrollDirection: Axis.vertical,
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context, index) {
                                                          final item = _conversation.data.elementAt(index);
                                                          return ListTile(
                                                            onTap: () {
                                                              OnlineUsersModel _onlineUsersModel = new OnlineUsersModel();
                                                              _onlineUsersModel.convId = item.id;
                                                              _onlineUsersModel.id = item.userId;
                                                              _onlineUsersModel.name = item.personName;
                                                              _onlineUsersModel.userDp = item.userDp;
                                                              _onlineUsersModel.online = item.online;
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => ChatView(userObj: _onlineUsersModel),
                                                                ),
                                                              );
                                                            },
                                                            leading: Stack(
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    color: settingRepo.setting.value.accentColor,
                                                                    borderRadius: BorderRadius.circular(100),
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(100),
                                                                    child: item.userDp != ""
                                                                        ? CachedNetworkImage(
                                                                            imageUrl: item.userDp,
                                                                            memCacheHeight: 40,
                                                                            placeholder: (context, url) => Center(
                                                                              child: Helper.showLoaderSpinner(Colors.white),
                                                                            ),
                                                                            fit: BoxFit.cover,
                                                                          )
                                                                        : Image.asset(
                                                                            "assets/images/default-user.png",
                                                                            width: 50,
                                                                            height: 50,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                  ).p(2),
                                                                ),
                                                                Positioned(
                                                                  bottom: 10,
                                                                  right: 1,
                                                                  child: item.online || chatRepo.onlineUserIds.value.contains(item.userId)
                                                                      ? Container(
                                                                          width: 13,
                                                                          height: 13,
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Colors.white, width: 2),
                                                                            color: Colors.green,
                                                                            borderRadius: BorderRadius.circular(100),
                                                                          ),
                                                                        )
                                                                      : SizedBox(
                                                                          height: 0,
                                                                        ),
                                                                ),
                                                              ],
                                                            ),
                                                            title: "${item.personName}".text.size(16).color(settingRepo.setting.value.textColor!).make(),
                                                            subtitle: "${item.message}".text.size(13).ellipsis.maxLines(2).color(settingRepo.setting.value.textColor!.withOpacity(0.7)).make(),
                                                            trailing: "${item.time}".text.size(13).color(settingRepo.setting.value.textColor!.withOpacity(0.7)).make(),
                                                          );
                                                        },
                                                      )
                                                    : !loader
                                                        ? Container(
                                                            height: config.App(context).appHeight(40),
                                                            child: "No conversation yet.".text.size(17).color(settingRepo.setting.value.textColor!.withOpacity(0.5)).make(),
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          ),
                                              );
                                            })
                                        : ValueListenableBuilder(
                                            valueListenable: chatRepo.peopleData,
                                            builder: (context, FollowingModel _people, _) {
                                              return Container(
                                                width: MediaQuery.of(context).size.width,
                                                padding: EdgeInsets.symmetric(horizontal: 15),
                                                child: _people.users.length > 0
                                                    ? ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _people.users.length,
                                                        shrinkWrap: true,
                                                        itemExtent: 60,
                                                        scrollDirection: Axis.vertical,
                                                        padding: EdgeInsets.zero,
                                                        itemBuilder: (context, index) {
                                                          final item = _people.users.elementAt(index);
                                                          return ListTile(
                                                            onTap: () {
                                                              OnlineUsersModel _onlineUsersModel = new OnlineUsersModel();
                                                              _onlineUsersModel.convId = 0;
                                                              _onlineUsersModel.id = item.id;
                                                              _onlineUsersModel.name = item.firstName + " " + item.lastName;
                                                              _onlineUsersModel.userDp = item.dp;
                                                              _onlineUsersModel.online = item.online;
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => ChatView(userObj: _onlineUsersModel),
                                                                ),
                                                              );
                                                            },
                                                            leading: Stack(
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    color: settingRepo.setting.value.accentColor,
                                                                    borderRadius: BorderRadius.circular(100),
                                                                  ),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(100),
                                                                    child: item.dp != ""
                                                                        ? CachedNetworkImage(
                                                                            imageUrl: item.dp,
                                                                            memCacheHeight: 40,
                                                                            placeholder: (context, url) => Center(
                                                                              child: Helper.showLoaderSpinner(Colors.white),
                                                                            ),
                                                                            fit: BoxFit.cover,
                                                                          )
                                                                        : Image.asset(
                                                                            "assets/images/default-user.png",
                                                                            width: 50,
                                                                            height: 50,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                  ).p(2),
                                                                ),
                                                                Positioned(
                                                                  bottom: 2,
                                                                  right: 1,
                                                                  child: item.online
                                                                      ? Container(
                                                                          width: 13,
                                                                          height: 13,
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Colors.white, width: 2),
                                                                            color: Colors.green,
                                                                            borderRadius: BorderRadius.circular(100),
                                                                          ),
                                                                        )
                                                                      : SizedBox(
                                                                          height: 0,
                                                                        ),
                                                                ),
                                                              ],
                                                            ),
                                                            title: "${item.firstName} ${item.lastName}".text.size(16).color(settingRepo.setting.value.textColor!).make(),
                                                          );
                                                        },
                                                      )
                                                    : !loader
                                                        ? Container(
                                                            height: config.App(context).appHeight(40),
                                                            child: active == 1
                                                                ? "No conversation yet.".text.size(17).color(settingRepo.setting.value.textColor!.withOpacity(0.5)).make()
                                                                : "No people yet.".text.size(17).color(settingRepo.setting.value.textColor!.withOpacity(0.5)).make(),
                                                          )
                                                        : SizedBox(
                                                            height: 0,
                                                          ),
                                              );
                                            })
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 0,
                              ),
                      );
                    });
              }),
        ),
      ),
    );
  }
}
