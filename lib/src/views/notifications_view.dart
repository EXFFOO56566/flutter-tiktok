import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/notification_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/notification_model.dart';
import '../models/videos_model.dart';
import '../repositories/notification_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'user_profile_view.dart';

class NotificationsView extends StatefulWidget {
  final int type;
  final int userId;
  NotificationsView({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends StateMVC<NotificationsView> {
  NotificationController _con = NotificationController();
  _NotificationsViewState() : super(NotificationController()) {
    _con = NotificationController();
  }

  @override
  void initState() {
    _con.notificationsList(1);
    super.initState();
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
      child: ValueListenableBuilder(
          valueListenable: notificationsData,
          builder: (context, NotificationModel _data, _) {
            return ValueListenableBuilder(
                valueListenable: _con.showLoader,
                builder: (context, bool loader, _) {
                  return ModalProgressHUD(
                    inAsyncCall: loader,
                    progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                    child: SafeArea(
                      child: Scaffold(
                        backgroundColor: settingRepo.setting.value.bgColor,
                        appBar: AppBar(
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
                          title: "Notifications".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                          centerTitle: true,
                        ),
                        body: !loader
                            ? ValueListenableBuilder(
                                valueListenable: _con.showMoreLoading,
                                builder: (context, bool loading, _) {
                                  return ModalProgressHUD(
                                    inAsyncCall: loading,
                                    progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                    child: SingleChildScrollView(
                                      controller: _con.scrollController,
                                      child: Container(
                                        width: config.App(context).appWidth(100),
                                        color: settingRepo.setting.value.bgColor,
                                        child: _data.notifications.length > 0
                                            ? ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemCount: _data.notifications.length,
                                                itemBuilder: (context, index) {
                                                  final item = _data.notifications.elementAt(index);
                                                  return ListTile(
                                                    onTap: () {
                                                      if (item.type == "L" || item.type == "C") {
                                                        videoRepo.homeCon.value.userVideoObj.value.videoId = item.videoId;
                                                        videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                                        videoRepo.homeCon.value.getVideos();
                                                        Navigator.of(context).pushNamed('/home');
                                                        if (item.type == "C") {
                                                          Timer(Duration(seconds: 2), () {
                                                            videoRepo.homeCon.value.hideBottomBar.value = true;
                                                            videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                                                            videoRepo.homeCon.value.videoIndex = 0;
                                                            videoRepo.homeCon.value.showBannerAd.value = false;
                                                            videoRepo.homeCon.value.showBannerAd.notifyListeners();
                                                            videoRepo.homeCon.value.pc.open();
                                                            Video videoObj = new Video();
                                                            videoObj.videoId = item.videoId;
                                                            videoRepo.homeCon.value.getComments(videoObj).whenComplete(() {
                                                              videoRepo.commentsLoaded.value = true;
                                                              videoRepo.commentsLoaded.notifyListeners();
                                                            });
                                                          });
                                                        }
                                                      } else if (item.type == "F") {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => UsersProfileView(
                                                              userId: item.userId,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                                                    dense: true,
                                                    leading: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(100),
                                                        boxShadow: [
                                                          BoxShadow(color: Theme.of(context).primaryColor, spreadRadius: 2),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(100),
                                                        child: item.photo != ''
                                                            ? CachedNetworkImage(
                                                                imageUrl: item.photo,
                                                                placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.buttonColor!),
                                                                fit: BoxFit.cover,
                                                              )
                                                            : Image.asset(
                                                                'assets/images/default-user.png',
                                                                width: 50,
                                                                height: 50,
                                                                fit: BoxFit.cover,
                                                              ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      item.msg,
                                                      style: TextStyle(
                                                        color: settingRepo.setting.value.textColor,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      item.sentOn,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: settingRepo.setting.value.textColor!.withOpacity(0.7),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: settingRepo.setting.value.bgColor,
                                                height: config.App(context).appHeight(100),
                                                width: config.App(context).appWidth(100),
                                                child: Center(
                                                  child: Text(
                                                    "There is no notification yet!",
                                                    style: TextStyle(
                                                      color: settingRepo.setting.value.textColor,
                                                      fontSize: 17,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                })
                            : SizedBox(
                                height: 0,
                              ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
