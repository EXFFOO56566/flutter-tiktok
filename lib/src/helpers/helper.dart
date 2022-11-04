import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:global_configuration/global_configuration.dart';

import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;

class Helper {
  late BuildContext context;
  DateTime currentBackPressTime = DateTime.now();

  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  static getData(data) {
    return data!['data'] ?? [];
  }

  static int getIntData(Map<String, dynamic> data) {
    return (data['data'] as int);
  }

  static bool getBoolData(Map<String, dynamic> data) {
    return (data['data'] as bool);
  }

  static getObjectData(Map<String, dynamic> data) {
    return data['data'] ?? new Map<String, dynamic>();
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  static String formatter(String currentBalance) {
    try {
      // suffix = {' ', 'k', 'M', 'B', 'T', 'P', 'E'};
      double value = double.parse(currentBalance);

      if (value < 0) {
        // less than a thousand
        return "0";
      } else if (value < 1000) {
        // less than a thousand
        return value.toStringAsFixed(0);
      } else if (value >= 1000 && value < (1000 * 100 * 10)) {
        // less than a million
        double result = value / 1000;
        return result.toStringAsFixed(1) + "k";
      } else if (value >= 1000000 && value < (1000000 * 10 * 100)) {
        // less than 100 million
        double result = value / 1000000;
        return result.toStringAsFixed(1) + "M";
      } else if (value >= (1000000 * 10 * 100) && value < (1000000 * 10 * 100 * 100)) {
        // less than 100 billion
        double result = value / (1000000 * 10 * 100);
        return result.toStringAsFixed(1) + "B";
      } else if (value >= (1000000 * 10 * 100 * 100) && value < (1000000 * 10 * 100 * 100 * 100)) {
        // less than 100 trillion
        double result = value / (1000000 * 10 * 100 * 100);
        return result.toStringAsFixed(1) + "T";
      } else {
        return "0";
      }
    } catch (e) {
      return "";
      print(e);
    }
  }

  static showLoaderSpinner(Color color) {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  static String limitString(String text, {int limit = 24, String hiddenText = "..."}) {
    return text.substring(0, min<int>(limit, text.length)) + (text.length > limit ? hiddenText : '');
  }

  static String getCreditCardNumber(String number) {
    String result = '';
    if (number != null && number.isNotEmpty && number.length == 16) {
      result = number.substring(0, 4);
      result += ' ' + number.substring(4, 8);
      result += ' ' + number.substring(8, 12);
      result += ' ' + number.substring(12, 16);
    }
    return result;
  }

  static Uri getUri(String path) {
    String _path = Uri.parse(GlobalConfiguration().get('base_url')).path;
    if (!_path.endsWith('/')) {
      _path += '/';
    }
    Uri uri = Uri(
        scheme: Uri.parse(GlobalConfiguration().get('base_url')).scheme,
        host: Uri.parse(GlobalConfiguration().get('base_url')).host,
        port: Uri.parse(GlobalConfiguration().get('base_url')).port,
        path: _path + "api/v1/" + path);
    print("URI");
    print(uri.toString());

    print("Current User Credentials");
    print(userRepo.currentUser.value.userId.toString());
    print(userRepo.currentUser.value.token);

    return uri;
  }

  static String getApiUser() {
    String apiUser = GlobalConfiguration().get('api_user');
    return apiUser.toString();
  }

  static String getApiKey() {
    print("getApiKey");
    print(GlobalConfiguration().get('api_key'));
    String apiKey = GlobalConfiguration().get('api_key');
    return apiKey;
  }

  Color getColorFromHex(String hex) {
    if (hex.contains('#')) {
      return Color(int.parse(hex.replaceAll("#", "0xFF")));
    } else {
      return Color(int.parse("0xFF" + hex));
    }
  }

  static BoxFit getBoxFit(String boxFit) {
    switch (boxFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'fit_height':
        return BoxFit.fitHeight;
      case 'fit_width':
        return BoxFit.fitWidth;
      case 'none':
        return BoxFit.none;
      case 'scale_down':
        return BoxFit.scaleDown;
      default:
        return BoxFit.cover;
    }
  }

  static AlignmentDirectional getAlignmentDirectional(String alignmentDirectional) {
    switch (alignmentDirectional) {
      case 'top_start':
        return AlignmentDirectional.topStart;
      case 'top_center':
        return AlignmentDirectional.topCenter;
      case 'top_end':
        return AlignmentDirectional.topEnd;
      case 'center_start':
        return AlignmentDirectional.centerStart;
      case 'center':
        return AlignmentDirectional.topCenter;
      case 'center_end':
        return AlignmentDirectional.centerEnd;
      case 'bottom_start':
        return AlignmentDirectional.bottomStart;
      case 'bottom_center':
        return AlignmentDirectional.bottomCenter;
      case 'bottom_end':
        return AlignmentDirectional.bottomEnd;
      default:
        return AlignmentDirectional.bottomEnd;
    }
  }

  static toast(String msg, Color color) {
    msg = removeTrailing("\n", msg);
    return SnackBar(
      duration: const Duration(seconds: 4),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      content: Text(
        msg,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  static OverlayEntry overlayLoader(context, [Color? color]) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: color != null ? color : Theme.of(context).primaryColor.withOpacity(0.85),
          child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader.remove();
      } catch (e) {}
    });
  }

  static String removeTrailing(String pattern, String from) {
    int i = from.length;
    while (from.startsWith(pattern, i - pattern.length)) i -= pattern.length;
    return from.substring(0, i);
  }

  static fSafeChar(var data) {
    if (data == null) {
      return "";
    } else {
      return data;
    }
  }

  static fSafeNum(var data) {
    if (data == null) {
      return 0;
    } else {
      return data;
    }
  }

  static Future<bool> isIpad() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    if (info.name.toLowerCase().contains("ipad")) {
      return true;
    }
    return false;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      // Fluttertoast.showToast(msg: "Tap again to exit an app.");
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  static DateTime getYourCountryTime(DateTime datetime) {
    DateTime dateTime = DateTime.now();
    Duration timezone = dateTime.timeZoneOffset;
    return datetime.add(timezone);
  }

  imageLoaderWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), blurRadius: 15, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Image.asset('assets/images/loading.gif', fit: BoxFit.fill),
      ),
    );
  }

  static Color? getColor(String colorCode) {
    colorCode = colorCode.replaceAll("#", "");

    try {
      if (colorCode.length == 6) {
        return Color(int.parse("0xFF" + colorCode));
      } else if (colorCode.length == 8) {
        return Color(int.parse("0x" + colorCode));
      } else {
        return Color(0xFFCCCCCC).withOpacity(1);
      }
    } catch (e) {
      print("printColor error $e");
      return Color(0xFFCCCCCC).withOpacity(1);
    }
  }

  static List<int> parsePusherEventData(var data) {
    List<int> ids = [];
    if (Platform.isAndroid) {
      String tempData = data.replaceAll('[', '').replaceAll(']', '');
      List tempIds = tempData.split(',');
      if (tempIds.length > 0) {
        tempIds.forEach((element) {
          if (element.indexOf('User id=') > -1) {
            if (!ids.contains(int.parse(element.replaceAll("User id=", "").trim()))) {
              ids.add(int.parse(element.replaceAll("User id=", "").trim()));
            }
          }
        });
      }
    } else {
      var temp = jsonDecode(data);
      if (temp['presence']['ids'] != null) {
        String tempData = temp['presence']['ids'].toString().replaceAll('[', '').replaceAll(']', '');
        List tempIds = tempData.split(',');
        if (tempIds.length > 0) {
          tempIds.forEach((element) {
            if (!ids.contains(int.parse(element))) {
              ids.add(int.parse(element));
            }
          });
        }
      }
    }
    print("IDSsss $ids");
    return ids;
  }

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
