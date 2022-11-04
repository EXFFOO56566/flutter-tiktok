import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/user_repository.dart' as userRepo;
import 'user_repository.dart';

ValueNotifier<EditProfileModel> usersProfileData = new ValueNotifier(EditProfileModel());

Future<EditProfileModel> fetchLoggedInUserInformation() async {
  usersProfileData.value = EditProfileModel.fromJson({});
  usersProfileData.notifyListeners();

  Uri uri = Helper.getUri('user_information');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        usersProfileData.value = EditProfileModel.fromJson(json.decode(response.body)['content']);
        usersProfileData.notifyListeners();
        return usersProfileData.value;
      } else {
        return EditProfileModel.fromJson({});
      }
    } else {
      return EditProfileModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return EditProfileModel.fromJson({});
  }
}

Future<String> updateProfilePic(file) async {
  Uri uri = Helper.getUri('update_profile_pic');
  try {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "profile_pic": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response = await Dio().post(
      uri.toString(),
      options: Options(
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + currentUser.value.token,
        },
      ),
      data: formData,
    );
    print("updateProfilePicresponse ${response.data}");
    if (response.statusCode == 200) {
      if (response.data['status'] == 'success') {
        return json.encode(response.data);
      } else {
        return "";
      }
    } else {
      return "";
    }
  } catch (e) {
    print("profilePicError $e");
    return "";
  }
}

Future<String> update(data) async {
  if (data['mobile'] == null) {
    data['mobile'] = "";
  }
  Uri url = Helper.getUri('update_user_information');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(data),
  );
  if (response.statusCode == 200 && json.decode(response.body)['status'] == 'success') {
    await userRepo.setCurrentUser(response.body, true);
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> changePassword(data) async {
  Uri url = Helper.getUri('change-password');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(data),
  );
  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}
