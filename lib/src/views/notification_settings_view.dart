import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:pedantic/pedantic.dart";
import "package:velocity_x/velocity_x.dart";

import '../controllers/notification_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_repository.dart' as notiRepo;
import '../repositories/settings_repository.dart' as settingRepo;

class NotificationSetting extends StatefulWidget {
  NotificationSetting({Key? key}) : super(key: key);
  @override
  _NotificationSettingState createState() => _NotificationSettingState();
}

class _NotificationSettingState extends StateMVC<NotificationSetting> {
  NotificationController _con = NotificationController();
  _NotificationSettingState() : super(NotificationController()) {
    _con = NotificationController();
  }
  bool isEdit = false;

  @override
  void initState() {
    _con.getNotificationSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () async {
        unawaited(updateNotificationSettings(notiRepo.notificationSettings.value));
        Navigator.of(context).pushReplacementNamed('/my-profile');
        return Future.value(true);
      },
      child: Container(
        color: settingRepo.setting.value.bgColor,
        child: SafeArea(
          child: Scaffold(
            key: _con.scaffoldKey,
            resizeToAvoidBottomInset: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(45.0),
              child: AppBar(
                iconTheme: IconThemeData(
                  color: settingRepo.setting.value.iconColor, //change your color here
                ),
                backgroundColor: settingRepo.setting.value.appbarColor,
                title: Text(
                  "Notifications Setting",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                    color: settingRepo.setting.value.textColor,
                  ),
                ),
                centerTitle: true,
              ),
            ),
            body: ValueListenableBuilder(
                valueListenable: _con.showLoader,
                builder: (context, bool loader, _) {
                  if (!loader) {
                    return ModalProgressHUD(
                      inAsyncCall: loader,
                      progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                      child: ValueListenableBuilder(
                          valueListenable: notiRepo.notificationSettings,
                          builder: (context, NotificationSettingsModel _data, _) {
                            return Container(
                              color: settingRepo.setting.value.bgColor,
                              height: config.App(context).appHeight(100),
                              width: config.App(context).appWidth(100),
                              child: SingleChildScrollView(
                                controller: _con.scrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 0.8,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            color: settingRepo.setting.value.bgShade,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      "Push Notification"
                                                          .text
                                                          .textStyle(Theme.of(context).textTheme.headline2!.copyWith(color: settingRepo.setting.value.textColor))
                                                          .make()
                                                          .pOnly(bottom: 5),
                                                      "Turn on all mobile notifications or select which to receive"
                                                          .text
                                                          .textStyle(Theme.of(context).textTheme.bodyText1!.copyWith(color: settingRepo.setting.value.textColor))
                                                          .make(),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Transform.scale(
                                                    scale: 0.6,
                                                    child: CupertinoSwitch(
                                                      activeColor: settingRepo.setting.value.accentColor,
                                                      value: (_data.follow && _data.like && _data.comment) ? true : false,
                                                      onChanged: (value) {
                                                        if (value) {
                                                          notiRepo.notificationSettings.value.follow = true;
                                                          notiRepo.notificationSettings.value.like = true;
                                                          notiRepo.notificationSettings.value.comment = true;
                                                          notiRepo.notificationSettings.notifyListeners();
                                                        } else {
                                                          notiRepo.notificationSettings.value.follow = false;
                                                          notiRepo.notificationSettings.value.like = false;
                                                          notiRepo.notificationSettings.value.comment = false;
                                                          notiRepo.notificationSettings.notifyListeners();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            color: settingRepo.setting.value.bgColor,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Row(
                                                    children: [
                                                      "User follow you".text.color(settingRepo.setting.value.textColor!).make(),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Transform.scale(
                                                    scale: 0.6,
                                                    child: CupertinoSwitch(
                                                      activeColor: settingRepo.setting.value.accentColor,
                                                      value: _data.follow,
                                                      onChanged: (value) {
                                                        notiRepo.notificationSettings.value.follow = !notiRepo.notificationSettings.value.follow;
                                                        notiRepo.notificationSettings.notifyListeners();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            color: settingRepo.setting.value.bgColor,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Row(
                                                    children: [
                                                      "Like on your video".text.color(settingRepo.setting.value.textColor!).make(),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Transform.scale(
                                                    scale: 0.6,
                                                    child: CupertinoSwitch(
                                                      activeColor: settingRepo.setting.value.accentColor,
                                                      value: _data.like,
                                                      onChanged: (value) {
                                                        notiRepo.notificationSettings.value.like = !notiRepo.notificationSettings.value.like;
                                                        notiRepo.notificationSettings.notifyListeners();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 1,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            color: settingRepo.setting.value.bgColor,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Row(
                                                    children: [
                                                      "Comment on your video.".text.color(settingRepo.setting.value.textColor!).make(),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Transform.scale(
                                                    scale: 0.6,
                                                    child: CupertinoSwitch(
                                                      activeColor: settingRepo.setting.value.accentColor,
                                                      value: _data.comment,
                                                      onChanged: (value) {
                                                        notiRepo.notificationSettings.value.comment = !notiRepo.notificationSettings.value.comment;
                                                        notiRepo.notificationSettings.notifyListeners();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  } else {
                    return Container(
                      color: settingRepo.setting.value.bgColor,
                      height: config.App(context).appHeight(100),
                      width: config.App(context).appWidth(100),
                      child: Center(
                        child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                      ),
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }
}
