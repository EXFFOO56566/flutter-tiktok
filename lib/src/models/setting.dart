// import 'dart:ui';

import 'package:flutter/material.dart';

import '../helpers/helper.dart';

class Setting {
  Color? bgColor = Colors.black;
  Color? accentColor = Colors.white;
  Color? textColor = Colors.white;
  Color? buttonColor = Colors.white;
  Color? buttonTextColor = Colors.white;
  Color? inactiveButtonColor = Colors.white;
  Color? inactiveButtonTextColor = Colors.white;
  Color? senderMsgColor = Colors.white;
  Color? senderMsgTextColor = Colors.white;
  Color? myMsgColor = Colors.white;
  Color? myMsgTextColor = Colors.white;
  Color? headingColor = Colors.white;
  Color? subHeadingColor = Colors.white;
  Color? iconColor = Colors.white;
  Color? dashboardIconColor = Colors.white;
  Color? gridItemBorderColor = Colors.white;
  double gridBorderRadius = 10;
  Color? dividerColor = Colors.white;
  Color? dpBorderColor = Colors.white;
  Color? appbarColor = Colors.white;
  Color? navBgColor = Colors.white;
  Color? bgShade = Colors.white;
  List<String> videoTimeLimits = [];

  Setting();
  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      bgColor = Helper.getColor(jsonMap['bgColor'] ?? '#000000');
      accentColor = Helper.getColor(jsonMap['accentColor'] ?? '#cecece');
      textColor = Helper.getColor(jsonMap['textColor'] ?? '#fafafa');
      buttonColor = Helper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      buttonTextColor = Helper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      inactiveButtonColor = Helper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      inactiveButtonTextColor = Helper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      senderMsgColor = Helper.getColor(jsonMap['senderMsgColor'] ?? '#9e0202');
      senderMsgTextColor = Helper.getColor(jsonMap['senderMsgTextColor'] ?? '#ffe5e5');
      myMsgColor = Helper.getColor(jsonMap['myMsgColor'] ?? '#a4dded');
      myMsgTextColor = Helper.getColor(jsonMap['myMsgTextColor'] ?? '#ffffff');
      headingColor = Helper.getColor(jsonMap['headingColor'] ?? '#e25822');
      subHeadingColor = Helper.getColor(jsonMap['subHeadingColor'] ?? '#ffffff');
      iconColor = Helper.getColor(jsonMap['iconColor'] ?? '#ffc0cb');
      dashboardIconColor = Helper.getColor(jsonMap['dashboardIconColor'] ?? '#fc9797');
      gridItemBorderColor = Helper.getColor(jsonMap['gridItemBorderColor'] ?? '#6cf58e');
      gridBorderRadius = jsonMap['gridBorderRadius'] == null ? 0 : double.parse(jsonMap['gridBorderRadius']);
      dividerColor = Helper.getColor(jsonMap['dividerColor'] ?? '#70ff94');
      dpBorderColor = Helper.getColor(jsonMap['accentColor'] ?? '#ffffff');
      appbarColor = Helper.getColor(jsonMap['headerBgColor'] ?? '#ffffff');
      navBgColor = Helper.getColor(jsonMap['bottomNav'] ?? '#ffffff');
      bgShade = Helper.getColor(jsonMap['bgShade'] ?? '#ffffff');

      videoTimeLimits = jsonMap['videoTimeLimits'] != null ? jsonMap['videoTimeLimits'].split(',') : ["15", "30", "60"];
    } catch (e) {
      print("error in fetching settings $e");
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["bgColor"] = bgColor = Colors.white;
    map["accentColor"] = accentColor = Colors.white;
    map["textColor"] = textColor = Colors.white;
    map["buttonColor"] = buttonColor = Colors.white;
    map["buttonTextColor"] = buttonTextColor = Colors.white;
    map["inactiveButtonColor"] = inactiveButtonColor = Colors.white;
    map["inactiveButtonTextColor"] = inactiveButtonTextColor = Colors.white;
    map["senderMsgColor"] = senderMsgColor = Colors.white;
    map["senderMsgTextColor"] = senderMsgTextColor = Colors.white;
    map["myMsgColor"] = myMsgColor = Colors.white;
    map["myMsgTextColor"] = myMsgTextColor = Colors.white;
    map["headingColor"] = headingColor = Colors.white;
    map["subHeadingColor"] = subHeadingColor = Colors.white;
    map["iconColor"] = iconColor = Colors.white;
    map["dashboardIconColor"] = dashboardIconColor = Colors.white;
    map["gridItemBorderColor"] = gridItemBorderColor = Colors.white;
    map["gridBorderRadiusColor"] = gridBorderRadius;
    map["dividerColor"] = dividerColor = Colors.white;
    map["dpBorderColor"] = dpBorderColor = Colors.white;
    map["videoTimeLimit"] = videoTimeLimits.join(',');
    return map;
  }
}
