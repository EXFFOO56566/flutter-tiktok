import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../models/verify_profile_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<EditProfileModel> usersProfileData = new ValueNotifier(EditProfileModel());

Future<VerifyProfileModel> fetchVerifyInformation() async {
  Uri uri = Helper.getUri('verify-status');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        return VerifyProfileModel.fromJSON(json.decode(response.body)['data']);
      } else {
        return VerifyProfileModel.fromJSON({});
      }
    } else {
      return VerifyProfileModel.fromJSON({});
    }
  } catch (e) {
    print(e.toString());
    return VerifyProfileModel.fromJSON({});
  }
}

Future<String> update(data) async {
  Uri url = Helper.getUri('user-verify');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
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
