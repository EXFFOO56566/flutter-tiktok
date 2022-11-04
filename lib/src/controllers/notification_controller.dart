import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repositories/notification_repository.dart' as notiRepo;

class NotificationController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = new ScrollController();
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  ValueNotifier<bool> showMoreLoading = new ValueNotifier(false);
  int page = 1;
  bool showLoadMore = true;
  NotificationController() {
    scrollController = new ScrollController();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getNotificationSettings() async {
    showLoader.value = true;
    showLoader.notifyListeners();
    await notiRepo.getNotificationSettings();
    showLoader.value = false;
    showLoader.notifyListeners();
  }

  Future notificationsList(page) async {
    if (page == 1) {
      showLoader.value = true;
      showLoader.notifyListeners();
    } else {
      showMoreLoading.value = true;
      showMoreLoading.notifyListeners();
    }
    if (page == 1) {
      scrollController = new ScrollController();
    }

    notiRepo.notificationsList(page).then((userValue) {
      if (page == 1) {
        showLoader.value = false;
        showLoader.notifyListeners();
      } else {
        showMoreLoading.value = false;
        showMoreLoading.notifyListeners();
      }
      if (userValue.notifications.length == userValue.total) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.notifications.length != userValue.total && showLoadMore) {
            page = page + 1;
            notificationsList(page);
          }
        }
      });
    });
  }
}
