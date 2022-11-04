import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/global_keys.dart';
import '../repositories/following_repository.dart' as followRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class FollowingController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  bool showLoadMore = true;
  int curIndex = 0;
  int followUserId = 0;
  String searchKeyword = '';
  bool followUnfollowLoader = false;
  var searchController = TextEditingController();
  DashboardController homeCon = DashboardController();
  UserController userCon = UserController();

  bool noRecord = false;
  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_loginPage');
    super.initState();
  }

  followingUsers(userId, page) async {
    homeCon = videoRepo.homeCon.value;
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    followRepo.followingUsers(userId, page, searchKeyword).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            followingUsers(userId, page);
          }
        }
      });
    });
  }

  Future<void> removeFollower(userId, i) async {
    userCon = UserController();
    followUnfollowLoader = true;
    followRepo.removeFollower(userId).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        followRepo.usersData.value.users.removeWhere((element) => element.id == userId);
        followRepo.usersData.notifyListeners();
        userCon.refreshMyProfile();
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
      }
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print("Follow Error $e");
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  followers(userId, page) async {
    homeCon = videoRepo.homeCon.value;
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    followRepo.followers(userId, page, searchKeyword).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            followingUsers(userId, page);
          }
        }
      });
    });
  }

  Future<void> followUnfollowUser(userId, i) async {
    userCon = UserController();
    followUnfollowLoader = true;
    followRepo.followUnfollowUser(userId).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      if (response['status'] == 'success') {
        followRepo.usersData.value.users[i].followText = response['followText'];
        followRepo.usersData.notifyListeners();
        userCon.refreshMyProfile();
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
      }
    }).catchError((e) {
      print("Follow Error $e");
      showLoader.value = false;
      showLoader.notifyListeners();
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  friendsList(page) async {
    // setState(() {});
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    followRepo.friendsList(page, searchKeyword).then((userValue) {
      if (userValue.totalRecords == 0 && searchKeyword != "") {
        noRecord = true;
      } else {
        noRecord = false;
      }
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            friendsList(page);
          }
        }
      });
    });
  }
}
