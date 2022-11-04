import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());

final navigatorKey = GlobalKey<NavigatorState>();

Future<Setting> initSettings() async {
  Setting _setting;
  Uri url = Helper.getUri('app-configration');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      if (json.decode(response.body)['data'] != null) {
        _setting = Setting.fromJSON(json.decode(response.body)['data']);
        setting.value = _setting;
        setting.notifyListeners();
      }
    } else {
      print("error in query ");
    }
  } catch (e) {
    print("error in query $e");
    return Setting.fromJSON({});
  }
  return setting.value;
}
