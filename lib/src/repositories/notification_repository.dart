import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/notification_model.dart';
import '../repositories/video_repository.dart' as videoRepo;
import 'user_repository.dart';

ValueNotifier<NotificationSettingsModel> notificationSettings = new ValueNotifier(NotificationSettingsModel());
ValueNotifier<NotificationModel> notificationsData = new ValueNotifier(NotificationModel());

Future<NotificationModel> notificationsList(page) async {
  Uri uri = Helper.getUri('notifications-list');
  uri = uri.replace(queryParameters: {
    'page': page.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          notificationsData.value.notifications.addAll(NotificationModel.fromJson(json.decode(response.body)['data']).notifications);
        } else {
          videoRepo.notificationsCount.value = 0;
          videoRepo.notificationsCount.notifyListeners();
          notificationsData.value = NotificationModel.fromJson(json.decode(response.body)['data']);
        }
        notificationsData.notifyListeners();
        return notificationsData.value;
      } else {
        return NotificationModel.fromJson({});
      }
    } else {
      return NotificationModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return NotificationModel.fromJson({});
  }
}

updateNotificationSettings(NotificationSettingsModel data) async {
  Uri uri = Helper.getUri('update-notification-setting');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  await http.post(
    uri,
    headers: headers,
    body: json.encode({
      "follow": data.follow == true ? 1 : 0,
      "like": data.like == true ? 1 : 0,
      "comment": data.comment == true ? 1 : 0,
    }),
  );
}

Future<NotificationSettingsModel> getNotificationSettings() async {
  Uri uri = Helper.getUri('user-notification-setting');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var rs = await Dio().post(
    uri.toString(),
    options: Options(headers: headers),
  );
  if (rs.statusCode == 200) {
    if (rs.data['status'] && rs.data['data'] != null) {
      notificationSettings.value = NotificationSettingsModel.fromJSON(rs.data['data']);
      notificationSettings.notifyListeners();
      return notificationSettings.value;
    } else {
      return NotificationSettingsModel.fromJSON({});
    }
  } else {
    return NotificationSettingsModel.fromJSON({});
  }
}
