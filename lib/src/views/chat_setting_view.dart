import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/notification_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/settings_repository.dart' as settingRepo;

class ChatSetting extends StatefulWidget {
  ChatSetting({
    Key? key,
  }) : super(key: key);
  @override
  _ChatSettingState createState() => _ChatSettingState();
}

class _ChatSettingState extends StateMVC<ChatSetting> {
  NotificationController _con = NotificationController();
  _ChatSettingState() : super(NotificationController()) {
    _con = NotificationController();
  }
  bool isEdit = false;

  @override
  void initState() {
    chatRepo.getChatSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return Container(
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
                "Chat Setting",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: settingRepo.setting.value.textColor,
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    chatRepo.updateChatSetting();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: settingRepo.setting.value.accentColor,
                    ),
                    child: "Update".text.size(10).uppercase.center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 8, v: 0),
                  ).pSymmetric(h: 15, v: 8),
                )
              ],
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
                        valueListenable: chatRepo.chatSettings,
                        builder: (context, String _data, _) {
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
                                                    "My followers only".text.color(settingRepo.setting.value.textColor!).make(),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Transform.scale(
                                                  scale: 0.6,
                                                  child: CupertinoSwitch(
                                                    activeColor: settingRepo.setting.value.accentColor,
                                                    value: _data == "FW" ? true : false,
                                                    onChanged: (value) {
                                                      chatRepo.chatSettings.value = value ? "FW" : "";
                                                      chatRepo.chatSettings.notifyListeners();
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
                                                    "Two way followings".text.color(settingRepo.setting.value.textColor!).make(),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Transform.scale(
                                                  scale: 0.6,
                                                  child: CupertinoSwitch(
                                                    activeColor: settingRepo.setting.value.accentColor,
                                                    value: _data == "FL" ? true : false,
                                                    onChanged: (value) {
                                                      chatRepo.chatSettings.value = value ? "FL" : "";
                                                      chatRepo.chatSettings.notifyListeners();
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
    );
  }
}
