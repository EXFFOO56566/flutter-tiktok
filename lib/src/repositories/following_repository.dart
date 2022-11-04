import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/following_model.dart';
import 'user_repository.dart';

ValueNotifier<FollowingModel> usersData = new ValueNotifier(FollowingModel());
ValueNotifier<FollowingModel> friendsData = new ValueNotifier(FollowingModel());

Future<FollowingModel> followingUsers(userId, page, searchKeyword) async {
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }

  Uri uri = Helper.getUri('following-users-list');
  uri = uri.replace(queryParameters: {'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword});
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
          usersData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          usersData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      } else {
        return FollowingModel.fromJson({});
      }
    } else {
      return FollowingModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return FollowingModel.fromJson({});
  }
}

Future<FollowingModel> followers(userId, page, searchKeyword) async {
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }

  Uri uri = Helper.getUri('followers-list');
  uri = uri.replace(queryParameters: {'user_id': userId.toString(), 'page': page.toString(), 'search': searchKeyword});
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
          usersData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          usersData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        usersData.notifyListeners();
        return usersData.value;
      } else {
        return FollowingModel.fromJson({});
      }
    } else {
      return FollowingModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return FollowingModel.fromJson({});
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
    body: json.encode({"follow_to": userId.toString()}),
  );

  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> removeFollower(userId) async {
  Uri url = Helper.getUri('remove-follower');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"remove_to": userId.toString()}),
  );

  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<FollowingModel> friendsList(page, searchKeyword) async {
  if (page == 1) {
    usersData.value = FollowingModel.fromJson({});
    usersData.notifyListeners();
  }
  Uri uri = Helper.getUri('friends-list');
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
          friendsData.value.users.addAll(FollowingModel.fromJson(json.decode(response.body)['data']).users);
        } else {
          friendsData.value = FollowingModel.fromJson(json.decode(response.body)['data']);
        }
        friendsData.notifyListeners();
        return friendsData.value;
      } else {
        return FollowingModel.fromJson({});
      }
    } else {
      return FollowingModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return FollowingModel.fromJson({});
  }
}
