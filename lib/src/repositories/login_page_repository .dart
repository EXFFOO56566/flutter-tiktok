import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/login_screen_model.dart';
import 'user_repository.dart';

ValueNotifier<LoginScreenData> LoginPageData = new ValueNotifier(LoginScreenData());

Future<LoginScreenData> fetchLoginPageInfo() async {
  print("fetchLoginPageInfo");
  Uri uri = Helper.getUri('app-login');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    print("response ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        LoginPageData.value = LoginScreenData.fromJSON(json.decode(response.body)['data']);
        LoginPageData.notifyListeners();
        return LoginPageData.value;
      } else {
        return LoginScreenData.fromJSON({});
      }
    } else {
      return LoginScreenData.fromJSON({});
    }
  } catch (e) {
    print("fetchLoginPageInfo error" + e.toString());
    return LoginScreenData.fromJSON({});
  }
}

Future<String> update(data) async {
  Uri url = Helper.getUri('user-verify');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  String fileName1 = data['document1'].split('/').last;
  Map<String, dynamic> submitData = {
    "name": data['name'],
    "address": data['address'],
    "document1": await MultipartFile.fromFile(data['document1'], filename: fileName1),
  };
  if (data['document2'] != null) {
    String fileName2 = data['document2'].split('/').last;
    submitData["document2"] = await MultipartFile.fromFile(data['document2'], filename: fileName2);
  }

  FormData formData = FormData.fromMap(submitData);
  var response = await Dio().post(url.toString(),
      options: Options(
        headers: headers,
      ),
      data: formData);
  if (response.statusCode == 200) {
    return json.encode(response.data);
  } else {
    print("error here");
    throw new Exception(response.data);
  }
}
