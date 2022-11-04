import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../models/search_model.dart';
import 'user_repository.dart';

ValueNotifier<HashVideosModel> hashData = new ValueNotifier(HashVideosModel());
ValueNotifier<HashVideosModel> hashVideoData = new ValueNotifier(HashVideosModel());
ValueNotifier<SearchModel> searchData = new ValueNotifier(SearchModel());
ValueNotifier<Map<String, dynamic>> adsData = new ValueNotifier({
  'android_app_id': '',
  'ios_app_id': '',
  'android_banner_app_id': '',
  'ios_banner_app_id': '',
  'android_interstitial_app_id': '',
  'ios_interstitial_app_id': '',
  'android_video_app_id': '',
  'ios_video_app_id': '',
  'video_show_on': '',
});

Future getData(page, searchKeyword) async {
  Uri uri = Helper.getUri('hash-tag-videos');
  uri = uri.replace(queryParameters: {
    'user_id': "0",
    'page': page.toString(),
    'search': searchKeyword,
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
          hashData.value.videos.addAll(HashVideosModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          hashData.value = HashVideosModel.fromJson(json.decode(response.body)['data']);
        }
        hashData.notifyListeners();
        return hashData.value;
      }
    }
  } catch (e) {
    print(e.toString());
    HashVideosModel.fromJson({});
  }
}

Future<List<dynamic>> getHashesData(page, searchKeyword) async {
  Uri uri = Helper.getUri('tag-search');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
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
          searchData.value.hashTags.addAll(SearchModel.fromJson(json.decode(response.body)).hashTags);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.hashTags;
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print(e.toString());
    return [];
  }
}

Future<List<dynamic>> getUsersData(page, searchKeyword) async {
  Uri uri = Helper.getUri('user-search');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
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
          searchData.value.users.addAll(SearchModel.fromJson(json.decode(response.body)).users);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.users;
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print(e.toString());

    return [];
  }
}

Future<List<Videos>> getVideosData(page, searchKeyword) async {
  Uri uri = Helper.getUri('video-search');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
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
          searchData.value.videos.addAll(SearchModel.fromJson(json.decode(response.body)).videos);
        } else {
          searchData.value = SearchModel.fromJson(json.decode(response.body)['data']);
        }
        searchData.notifyListeners();
        return searchData.value.videos;
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    print(e.toString());

    return [];
  }
}

Future<HashVideosModel> getHashData(page, hash) async {
  Uri uri = Helper.getUri('hash-videos');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'hash': hash});
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
          hashVideoData.value.videos.addAll(HashVideosModel.fromJson(json.decode(response.body)['data']).videos);
        } else {
          hashVideoData.value = HashVideosModel.fromJson(json.decode(response.body)['data']);
        }
        hashVideoData.notifyListeners();
        return hashVideoData.value;
      } else {
        return HashVideosModel.fromJson({});
      }
    } else {
      return HashVideosModel.fromJson({});
    }
  } catch (e) {
    print(e.toString());
    return HashVideosModel.fromJson({});
  }
}

Future<SearchModel> getSearchData(page, searchKeyword) async {
  Uri uri = Helper.getUri('search');
  uri = uri.replace(queryParameters: {'page': page.toString(), 'search': searchKeyword});
  // try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    print("getSearchData ${response.body}");
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        searchData.value = SearchModel.fromJson(json.decode(response.body));
        searchData.notifyListeners();
        print("${searchData.value.users.length}${searchData.value.hashTags.length}${searchData.value.videos.length}");
        return searchData.value;
      } else {
        return SearchModel.fromJson({});
      }
    } else {
      return SearchModel.fromJson({});
    }
  // } catch (e) {
  //   print("eeeee");
  //   print(e.toString());
  //   return SearchModel.fromJson({});
  // }
}

Future<String> getAds() async {
  Uri uri = Helper.getUri('get-ads');
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 'success') {
        return json.encode(json.decode(response.body));
      } else
        return "";
    } else
      return "";
  } catch (e) {
    print(e.toString());
    return "";
  }
}
