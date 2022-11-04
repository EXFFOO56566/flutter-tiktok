import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/comment_model.dart';
import 'user_repository.dart';

Future<Stream<CommentData>> getComments(int videoId, int page) async {
  Uri uri = Helper.getUri('fetch-video-comments');
  uri = uri.replace(queryParameters: {
    "page": page.toString(),
    "video_id": videoId.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    http.Request request = new http.Request("post", uri);
    request.headers.clear();
    request.headers.addAll(headers);

    final streamedRest = await request.send();
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return CommentData.fromJson(data);
    });
  } catch (e) {
    print(e.toString());
    return new Stream.value(new CommentData.fromJson({}));
  }
}

Future<int> addComment(CommentData obj) async {
  Uri uri = Helper.getUri('add-comment');
  uri = uri.replace(queryParameters: {"video_id": obj.videoId.toString(), "comment": obj.comment.toString()});

  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    return json.decode(response.body)['comment_id'];
  } catch (e) {
    print(e.toString());
    return 0;
  }
}

Future<int> editComment(CommentData obj) async {
  Uri uri = Helper.getUri('edit-comment');
  uri = uri.replace(queryParameters: {
    "user_id": obj.userId.toString(),
    "comment_id": obj.commentId.toString(),
    "app_token": obj.token,
    "video_id": obj.videoId.toString(),
    "comment": obj.comment.toString(),
  });
  try {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ' + currentUser.value.token,
    };
    var response = await http.post(uri, headers: headers);
    return json.decode(response.body);
  } catch (e) {
    print("error $e");
    return 0;
  }
}
