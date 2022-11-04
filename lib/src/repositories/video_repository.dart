import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/user_repository.dart' as userRepo;

ValueNotifier<DashboardController> homeCon = new ValueNotifier(DashboardController());
ValueNotifier<bool> dataLoaded = new ValueNotifier(false);
ValueNotifier<bool> firstLoad = new ValueNotifier(true);
ValueNotifier<VideoModel> videosData = new ValueNotifier(VideoModel());
ValueNotifier<List<String>> watchedVideos = new ValueNotifier([]);
ValueNotifier<VideoModel> followingUsersVideoData = new ValueNotifier(VideoModel());
ValueNotifier<bool> isOnHomePage = new ValueNotifier(true);
ValueNotifier<bool> isOnRecordingPage = new ValueNotifier(false);
ValueNotifier<bool> commentsLoaded = new ValueNotifier(false);
ValueNotifier<int> notificationsCount = new ValueNotifier(0);
ValueNotifier<int> unreadMessageCount = new ValueNotifier(0);

Future<VideoModel> getVideos(page, [obj]) async {
  Uri uri = Helper.getUri('get-videos');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "user_id": obj != null
        ? (obj['userId'] == null)
            ? '0'
            : obj['userId'].toString()
        : '0',
    "video_id": obj != null
        ? (obj['videoId'] == null)
            ? '0'
            : obj['videoId'].toString()
        : '0'
  });

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    print("response.statusCode ${response.statusCode} ${json.decode(response.body)['data']}");
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("get videos ${jsonData['messagesCount']}");
      if (jsonData['status'] == 'success') {
        unreadMessageCount.value = jsonData['messagesCount'] ?? 0;
        unreadMessageCount.notifyListeners();
        if (page > 1) {
          videosData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          // videosData.value = VideoModel.fromJson({});
          // videosData.notifyListeners();
          videosData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        videosData.notifyListeners();
        return videosData.value;
      } else {
        print("asdsadasd1");
        return VideoModel.fromJson({});
      }
    } else {
      print("asdsadasd2");
      return VideoModel.fromJson({});
    }
  } catch (e) {
    print("asdsadasd3");
    print(e.toString());
    return VideoModel.fromJson({});
  }
}

Future<VideoModel> getFollowingUserVideos(page) async {
  Uri uri = Helper.getUri('get-videos');
  uri = uri.replace(queryParameters: {
    "page_size": '10',
    "page": page.toString(),
    "following": '1',
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        if (page > 1) {
          followingUsersVideoData.value.videos.addAll(VideoModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          followingUsersVideoData.value = VideoModel.fromJson({});
          followingUsersVideoData.notifyListeners();
          followingUsersVideoData.value = VideoModel.fromJson(json.decode(response.body)['data']);
        }
        followingUsersVideoData.notifyListeners();
        return followingUsersVideoData.value;
      } else {
        return VideoModel.fromJson({});
      }
    } else {
      return VideoModel.fromJson({});
    }
  } catch (e) {
    print("ERRORSSS: " + e.toString());

    return VideoModel.fromJson({});
  }
}

Future<bool> updateLike(int videoId) async {
  Uri uri = Helper.getUri('video-like');
  uri = uri.replace(queryParameters: {"video_id": videoId.toString()});

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    await http.post(uri, headers: headers);
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<String> followUnfollowUser(Video videoObj) async {
  Uri url = Helper.getUri('follow-unfollow-user');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({
      "follow_to": videoObj.userId.toString(),
    }),
  );

  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> submitReport(Video videoObj, selectedType, description) async {
  Uri url = Helper.getUri('submit-report');
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
  };
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: headers,
    body: json.encode({"video_id": videoObj.videoId.toString(), "type": selectedType, "description": description}),
  );

  if (response.statusCode == 200) {
    return json.encode(json.decode(response.body));
  } else {
    throw new Exception(response.body);
  }
}

Future<String> incVideoViews(Video videoObj) async {
  String userVideoId = userRepo.currentUser.value.userId != null ? userRepo.currentUser.value.userId.toString() : "";
  String userVideo = videoObj.videoId.toString() + userVideoId;
  if (!watchedVideos.value.contains(userVideo)) {
    watchedVideos.value.add(userVideo);
    watchedVideos.notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uniqueToken = prefs.getString("unique_id")!;
    Uri url = Helper.getUri('video-views');
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    Map<String, dynamic> data = {};
    data["unique_token"] = uniqueToken;
    data["video_id"] = videoObj.videoId.toString();
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      if (!homeCon.value.showFollowingPage.value) {
        videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalViews = json.decode(response.body)['total_views'];
        videosData.notifyListeners();
      } else {
        followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalViews = json.decode(response.body)['total_views'];
        followingUsersVideoData.notifyListeners();
      }
      return json.encode(
        json.decode(response.body),
      );
    } else {
      return "";
      throw new Exception(response.body);
    }
  } else {
    return "";
  }
}

addGuestUser(token, platformId) async {
  Uri uri = Helper.getUri('add-guest-user');
  uri = uri.replace(queryParameters: {"fcm_token": token.toString(), "platform_id": platformId.toString()});
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
  } catch (e) {
    print("ADD GUEST USER" + e.toString());
  }
}

updateFcmToken(token) async {
  Uri uri = Helper.getUri('update-fcm-token');
  uri = uri.replace(queryParameters: {
    "fcm_token": token.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print("updateFcmToken $jsonData");
      notificationsCount.value = jsonData['count'] ?? 0;
      notificationsCount.notifyListeners();
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<String> getWatermark() async {
  Uri uri = Helper.getUri('get-watermark');
  String watermark = "";
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        watermark = jsonData['watermark'];
      }
    }
  } catch (e) {
    print(e.toString());
  }
  return watermark;
}

deleteVideo(videoId) async {
  Uri uri = Helper.getUri('delete-video');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var body = json.encode({
      "video_id": videoId,
    });
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        userRepo.myProfile.value.userVideos.removeWhere((item) => item.videoId == videoId);
        userRepo.myProfile.notifyListeners();
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

deleteComment(commentId, videoId) async {
  Uri uri = Helper.getUri('delete-comment');

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var body = json.encode({
      "comment_id": commentId,
      "video_id": videoId,
    });
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        homeCon.value.comments.removeWhere((item) => item.commentId == commentId);
        homeCon.value.loadMoreUpdateView.value = true;
        homeCon.value.loadMoreUpdateView.notifyListeners();
        if (!homeCon.value.showFollowingPage.value) {
          videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalComments = videosData.value.videos.elementAt(homeCon.value.swiperIndex).totalComments - 1;
        } else {
          followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalComments = followingUsersVideoData.value.videos.elementAt(homeCon.value.swiperIndex2).totalComments - 1;
        }
        homeCon.notifyListeners();
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<String> editVideo(videoId, videoDescription, privacy) async {
  Uri uri = Helper.getUri('update-video-description');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
    };
    var body = json.encode({
      "video_id": videoId,
      "description": videoDescription,
      "privacy": privacy,
    });
    final client = new http.Client();
    final response = await client.post(
      uri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        await userRepo.getMyProfile(1);
        return "Yes";
      } else {
        return "No";
      }
    } else {
      return "No";
    }
  } catch (e) {
    print(e.toString());
    return "No";
  }
}
