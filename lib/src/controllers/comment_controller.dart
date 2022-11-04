import 'package:flutter/material.dart';
import 'package:leuke/src/helpers/global_keys.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/comment_model.dart';
import '../repositories/comment_repository.dart' as commentRepo;
import '../repositories/user_repository.dart' as userRepo;

class CommentController extends ControllerMVC {
  List<CommentData> comments = <CommentData>[];
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  // OverlayEntry loader;
  CommentData commentObj = new CommentData();
  ScrollController scrollController1 = new ScrollController();
  ScrollController scrollController2 = new ScrollController();
  int page = 1;
  bool showLoadMore = true;
  CommentController() {
    scrollController1 = new ScrollController();
    scrollController2 = new ScrollController();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    super.initState();
  }

  Future<void> getComments(int videoId) async {
    final Stream<CommentData> stream = await commentRepo.getComments(videoId, page);
    stream.listen((CommentData _comment) {
      setState(() {
        comments.add(_comment);
      });
    }, onError: (a) {
      print(a);
    }, onDone: () {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels == scrollController2.position.maxScrollExtent) {
          if (comments.length != 20 && showLoadMore) {
            loadMore(videoId);
          }
        }
      });

      scrollController1.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  Future<void> loadMore(int videoId) async {
    setState(() {
      page = page + 1;
    });
    final Stream<CommentData> stream = await commentRepo.getComments(videoId, page);
    stream.listen((CommentData _comment) {
      setState(() {
        comments.add(_comment);
      });
    }, onError: (a) {
      print(a);
    }, onDone: () {
      scrollController2.addListener(() {
        if (scrollController2.position.pixels == scrollController2.position.maxScrollExtent) {
          if (comments.length != 20 && showLoadMore) {
            loadMore(videoId);
          }
        }
      });

      scrollController1.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 500),
      );
    });
  }

  Future<void> addComment(int videoId) async {
    FocusScope.of(scaffoldKey.currentContext!).unfocus();
    commentObj.videoId = videoId;
    commentObj.userId = userRepo.currentUser.value.userId;
    commentObj.token = userRepo.currentUser.value.token;
    commentObj.userDp = userRepo.currentUser.value.userDP;
    commentObj.userName = userRepo.currentUser.value.userName;
    commentObj.time = 'just now';
    await commentRepo.addComment(commentObj).then((commentId) {
      commentObj.commentId = commentId;
      setState(() {
        comments.add(commentObj);
      });
    }).catchError((e) {
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There's some issue with the server"),
      ));
    });
  }
}
