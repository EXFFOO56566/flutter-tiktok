import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:laravel_chat/laravel_echo.dart';
import 'package:pusher_client/pusher_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../models/login_model.dart';
import '../models/user_profile_model.dart';
import '../models/videos_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;

ValueNotifier<VideoModel> usersData = new ValueNotifier(VideoModel());
ValueNotifier<BlockedModel> blockedUsersData = new ValueNotifier(BlockedModel());
ValueNotifier<LoginData> currentUser = new ValueNotifier(LoginData());
ValueNotifier<String> errorString = new ValueNotifier("");
ValueNotifier<LoginData> socialUserProfile = new ValueNotifier(LoginData());
ValueNotifier<UserProfileModel> userProfile = new ValueNotifier(UserProfileModel());
ValueNotifier<UserProfileModel> myProfile = new ValueNotifier(UserProfileModel());
ValueNotifier<UserProfileModel> userFavVideos = new ValueNotifier(UserProfileModel());
ValueNotifier<String> socketId = new ValueNotifier('');

Echo echoObj = Echo(client: "");
Future<bool> ifEmailExists(String email) async {
  Uri url = Helper.getUri('is-email-exist');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"email": email}),
  );
  if (response.statusCode == 200) {
    if (json.decode(response.body)['status'] == "success") {
      errorString.value = "";
      errorString.notifyListeners();

      if (json.decode(response.body)['isEmailExist'] == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    throw new Exception(response.body);
  }
}

Future<void> updateFCMTokenForUser() async {
  FirebaseMessaging.instance.getToken().then((value) {
    if (value != "" && value != null) {
      videoRepo.updateFcmToken(value);
    }
  });
}

Future<String> register(userProfile) async {
  Uri url = Helper.getUri('register');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  FormData formData = FormData.fromMap(userProfile);
  if (userProfile['profile_pic_file'] != null && userProfile['profile_pic_file'] != '') {
    String fileName = userProfile['profile_pic_file'].split('/').last;
    formData = FormData.fromMap({
      'fname': (userProfile['fname'] == '' || userProfile['fname'] == null) ? socialUserProfile.value.name.split(" ")[0] : userProfile['fname'],
      'lname': (userProfile['lname'] == '' || userProfile['lname'] == null) ? socialUserProfile.value.name.split(" ")[1] : userProfile['lname'],
      'email': (userProfile['email'] == '' || userProfile['email'] == null) ? socialUserProfile.value.email : userProfile['email'],
      'password': userProfile['password'],
      'confirm_password': userProfile['confirm_password'],
      'username': userProfile['username'],
      'time_zone': userProfile['time_zone'],
      'login_type': userProfile['login_type'],
      'gender': userProfile['gender'],
      'dob': userProfile['dob'],
      'profile_pic': userProfile['profile_pic'],
      "profile_pic_file": await MultipartFile.fromFile(userProfile['profile_pic_file'], filename: fileName),
    });
  }
  var response = await Dio().post(url.toString(),
      options: Options(
        headers: headers,
      ),
      data: formData);
  return json.encode(response.data);
}

checkIfAuthenticated() async {
  Uri uri = Helper.getUri('refresh');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var response = await http.post(uri, headers: headers);
  if (response.statusCode == 200) {
    return response.body;
  } else {
    return null;
  }
}

Future<bool> socialLogin(userProfile, timezone, type) async {
  Uri url = Helper.getUri('register-social');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final client = new http.Client();
  var profile = LoginData().toSocialLoginMap(userProfile, timezone, type);
  if (type == "FB" && profile["email"] == "") {
    errorString.value = "Your facebook profile does not provide email address. Please try with another method";
    errorString.notifyListeners();
    return false;
  }
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode(profile),
  );
  if (response.statusCode == 200) {
    print("SSSSSSSS");
    print(response.body);
    if (json.decode(response.body)['status'] == "success") {
      errorString.value = "";
      errorString.notifyListeners();
      setCurrentUser(response.body);
      updateFCMTokenForUser();
      currentUser.value = LoginData.fromJson(json.decode(response.body)['content']);
      currentUser.notifyListeners();
    } else {
      // errorString.value = "Your Account is deactivated";
      errorString.value = json.decode(response.body)['msg'];
      errorString.notifyListeners();
      return false;
    }
  } else {
    throw new Exception(response.body);
  }

  return true;
}

Future<String> socialRegister(userProfile) async {
  Uri url = Helper.getUri('social-register');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  FormData formData = FormData.fromMap(userProfile);
  if (userProfile['profile_pic_file'] != null) {
    String fileName = userProfile['profile_pic_file'].split('/').last;
    formData = FormData.fromMap({
      'fname': (userProfile['fname'] == '' || userProfile['fname'] == null) ? socialUserProfile.value.name.split(" ")[0] : userProfile['fname'],
      'lname': (userProfile['lname'] == '' || userProfile['lname'] == null) ? socialUserProfile.value.name.split(" ")[1] : userProfile['lname'],
      'email': (userProfile['email'] == '' || userProfile['email'] == null) ? socialUserProfile.value.email : userProfile['email'],
      'password': userProfile['password'],
      'confirm_password': userProfile['confirm_password'],
      'username': userProfile['username'],
      'time_zone': userProfile['time_zone'],
      'login_type': userProfile['login_type'],
      'gender': userProfile['gender'],
      'profile_pic': userProfile['profile_pic'],
      "profile_pic_file": await MultipartFile.fromFile(userProfile['profile_pic_file'], filename: fileName),
    });
  }
  try {
    var response = await Dio().post(url.toString(),
        options: Options(
          headers: headers,
        ),
        data: formData,
        queryParameters: {"user_id": userRepo.currentUser.value.userId.toString(), "app_token": userRepo.currentUser.value.token});

    return json.encode(response.data);
  } catch (e) {
    return json.encode({'status': 'failed', 'msg': 'There is some error'});
  }
}

Future<String> getEulaAgreement() async {
  Uri uri = Helper.getUri('end-user-license-agreement');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };

  print("getEulaAgreement currentUser.value.token ${currentUser.value.token}");
  var response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success') {
      return json.encode(json.decode(response.body)['data']);
    } else {
      return "";
    }
  } else {
    return "";
  }
}

Future<bool> checkEulaAgreement() async {
  Uri uri = Helper.getUri('get-eula-agree');

  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var response = await http.get(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success') {
      if (jsonData['eulaAgree'] == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> agreeEula() async {
  Uri uri = Helper.getUri('update-eula-agree');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var response = await http.post(uri, headers: headers);
  print(response.body);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success') {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

Future<VideoModel> getUsers(page, searchKeyword) async {
  Uri uri = Helper.getUri('most-viewed-video-users');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
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
          usersData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          usersData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      } else {
        return VideoModel.fromJson({});
      }
    } else {
      return VideoModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return VideoModel.fromJson({});
  }
}

Future<String> followUnfollowUser(userId) async {
  Uri url = Helper.getUri('follow-unfollow-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"follow_to": userId.toString(), "app_token": userRepo.currentUser.value.token}),
  );

  if (response.statusCode == 200) {
    print(json.encode(json.decode(response.body)));
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> blockUser(userId) async {
  Uri url = Helper.getUri('block-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({
      "user_id": userId.toString(),
    }),
  );
  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<UserProfileModel> getUserProfile(userId, page) async {
  Uri uri = Helper.getUri('fetch-user-info');
  uri = uri.replace(queryParameters: {"user_id": userId.toString(), 'page': page.toString()});
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
          userProfile.value.userVideos.addAll(UserProfileModel.fromJson(json.decode(response.body)['data']).userVideos);
        } else {
          userProfile.value = UserProfileModel.fromJson(json.decode(response.body)['data']);
        }
        userProfile.notifyListeners();
        return userProfile.value;
      } else {
        return UserProfileModel.fromJson({});
      }
    } else {
      return UserProfileModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return UserProfileModel.fromJson({});
  }
}

Future<BlockedModel> getBlockedUsers(page) async {
  if (page == 1) {
    blockedUsersData.value = BlockedModel.fromJson({});
    blockedUsersData.notifyListeners();
  }

  Uri uri = Helper.getUri('blocked-users-list');
  uri = uri.replace(queryParameters: {
    'page': page.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          blockedUsersData.value.users.addAll(BlockedModel.fromJson(json.decode(response.body)['blockList']).users);
        } else {
          blockedUsersData.value = BlockedModel.fromJson(json.decode(response.body)['blockList']);
        }
        usersData.notifyListeners();
        return blockedUsersData.value;
      } else {
        return BlockedModel.fromJson({});
      }
    } else {
      return BlockedModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return BlockedModel.fromJson({});
  }
}

Future<UserProfileModel> getMyProfile(page) async {
  Uri uri = Helper.getUri('fetch-login-user-info');
  uri = uri.replace(queryParameters: {'page': page.toString()});
  // try {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  var response = await http.post(uri, headers: headers);
  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    if (jsonData['status'] == 'success') {
      if (page > 1) {
        myProfile.value.userVideos.addAll(UserProfileModel.fromJson(json.decode(response.body)['data']).userVideos);
      } else {
        myProfile.value = UserProfileModel.fromJson(json.decode(response.body)['data']);
      }
      myProfile.notifyListeners();
      return myProfile.value;
    } else {
      return UserProfileModel.fromJson({});
    }
  } else {
    return UserProfileModel.fromJson({});
  }
  /*} catch (e) {
    print("123123123123" + e.toString());
    return UserProfileModel.fromJson({});
  }*/
}

Future<UserProfileModel> getLikedVideos(page) async {
  Uri uri = Helper.getUri('fetch-login-user-fav-videos');
  uri = uri.replace(queryParameters: {'page': page.toString()});
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
          userFavVideos.value.userVideos.addAll(UserProfileModel.fromJson(json.decode(response.body)['data']).userVideos);
        } else {
          userFavVideos.value = UserProfileModel.fromJson(json.decode(response.body)['data']);
        }
        userFavVideos.notifyListeners();
        return userFavVideos.value;
      } else {
        return UserProfileModel.fromJson({});
      }
    } else {
      return UserProfileModel.fromJson({});
    }
  } catch (e) {
    return UserProfileModel.fromJson({});
  }
}

Future logout() async {
  echoObj.disconnect();
  if (currentUser.value.loginType == 'FB') {
    FacebookAuth.instance.logOut();
  } else if (currentUser.value.loginType == 'G') {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  Map<String, String> headers = {
    'Accept': 'application/json;',
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ${currentUser.value.token}',
  };
  Uri uri = Helper.getUri('logout');
  /* Helper.printUserLog(*/ print(uri.toString());

  try {
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
    );
    print("Logout response ${response.body}");
    if (response.statusCode != 200) {
      // Fluttertoast.showToast(msg: "error_while_action".trParams({"action": "updating".tr, "entity": "profile".tr}), backgroundColor: Get.theme.errorColor);
    } else {
      print("Success response ${response.body}");
    }
  } catch (e) {
    // Fluttertoast.showToast(msg: "error_while_action".trParams({"action": "updating".tr, "entity": "profile".tr}), backgroundColor: Get.theme.errorColor);
    print("files error $e");
  }
  currentUser.value = new LoginData();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  await prefs.remove('EULA_agree');
  myProfile.value = UserProfileModel.fromJson({});
  myProfile.notifyListeners();
  currentUser.notifyListeners();
}

Future<void> setCurrentUser(jsonString, [bool isEdit = false]) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (json.encode(json.decode(jsonString)['content']) != null) {
      await prefs.setString('current_user', json.encode(json.decode(jsonString)['content']));
      currentUser.value = LoginData.fromJson(json.decode(jsonString)['content']);
      currentUser.notifyListeners();
      if (!isEdit) {
        pusherEchoConnection();
        chatRepo.joinSocketUser();
      }
    }
  } catch (e) {
    print("Login error: $e");
  }
}

Future<String> userUniqueId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Uri uri = Helper.getUri('get-unique-id');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        prefs.setString("unique_id", jsonData['unique_token']);
        return json.encode(json.decode(response.body));
      } else {
        return "";
      }
    } else {
      return "";
    }
  } catch (e) {
    print(e.toString());
    return "";
  }
}

Future<String> login(data) async {
  Uri url = Helper.getUri('login');
  final client = new http.Client();
  final response = await client.post(
    url,
    body: data,
  );
  return response.body;
}

Future<String> forgotPassword(data) async {
  Uri url = Helper.getUri('forgot-password');
  final client = new http.Client();
  final response = await client.post(
    url,
    body: data,
  );
  return response.body;
}

Future<String> updateForgotPassword(data) async {
  Uri url = Helper.getUri('update-forgot-password');
  final client = new http.Client();
  final response = await client.post(
    url,
    body: data,
  );
  return response.body;
}

Future<String> verifyOtp(data) async {
  Uri url = Helper.getUri('verify-otp');
  final client = new http.Client();
  print("verify Otp $data");
  final response = await client.post(
    url,
    body: data,
  );
  return response.body;
}

Future<String> resendOtp(data) async {
  Uri url = Helper.getUri('resend-otp');
  final client = new http.Client();
  final response = await client.post(
    url,
    body: data,
  );
  return json.encode(json.decode(response.body));
}

pusherEchoConnection() {
  PusherOptions options = PusherOptions(
    encrypted: true,
    cluster: "ap3",
    auth: PusherAuth(
      '${GlobalConfiguration().get('base_url')}api/broadcasting/auth',
      headers: {
        'Authorization': 'Bearer ${currentUser.value.token}',
      },
    ),
  );
  PusherClient pusherClient = PusherClient(
    GlobalConfiguration().get('pusher_key'),
    options,
    autoConnect: true,
    enableLogging: true,
  );
  echoObj = new Echo(
    broadcaster: EchoBroadcasterType.Pusher,
    client: pusherClient,
    options: {
      'auth': {
        'headers': {
          'Authorization': 'Bearer ${currentUser.value.token}',
        },
      },
      'authEndpoint': '${GlobalConfiguration().get('base_url')}api/broadcasting/auth',
    },
  );
}
