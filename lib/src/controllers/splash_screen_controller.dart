import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/dashboard_controller.dart';
import '../models/login_model.dart';
import '../repositories/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<bool> processing = new ValueNotifier(true);
  DashboardController homeCon = DashboardController();
  String uniqueId = "";
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<void> initializeVideos() async {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> userUniqueId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    uniqueId = (pref.getString('unique_id') == null) ? "" : pref.getString('unique_id').toString();
    if (uniqueId == "") {
      userRepo.userUniqueId().then((value) {
        var jsonData = json.decode(value);
        uniqueId = jsonData['unique_token'];
      });
    }
  }

  Future<void> checkIfAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('current_user')) {
      String cu = prefs.get('current_user').toString();

      userRepo.currentUser.value = LoginData.fromJson(json.decode(cu));
    }
    if (userRepo.currentUser.value.token == '') {
      return;
    }
    var check = await userRepo.checkIfAuthenticated();
    if (check != null) {
      await userRepo.setCurrentUser(check);
    } else {
      userRepo.currentUser.value = new LoginData();

      await prefs.remove('current_user');
    }
  }
}
