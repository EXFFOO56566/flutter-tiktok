import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../helpers/app_config.dart' as config;
import '../repositories/settings_repository.dart' as settingRepo;

class InternetPage extends StatefulWidget {
  InternetPage({Key? key}) : super(key: key);

  @override
  _InternetPageState createState() => _InternetPageState();
}

class _InternetPageState extends StateMVC<InternetPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: settingRepo.setting.value.bgColor,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            color: settingRepo.setting.value.bgColor,
            height: config.App(context).appHeight(100),
            width: config.App(context).appWidth(100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/no-wifi.svg",
                  color: settingRepo.setting.value.iconColor,
                  width: 50,
                  height: 50,
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: "There is no network connection right now. check your internet connection".text.center.lineHeight(1.4).size(15).color(settingRepo.setting.value.textColor!).make().centered(),
                ),
                SizedBox(
                  height: 20,
                ),
                "Enable wifi or mobile data".text.uppercase.center.lineHeight(1.4).size(15).color(settingRepo.setting.value.textColor!).make().centered(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
