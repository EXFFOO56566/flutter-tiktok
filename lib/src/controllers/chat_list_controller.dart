import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/conversations_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;

class ChatListController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final msgController = TextEditingController();
  DateTime now = DateTime.now();
  ScrollController scrollController = new ScrollController();
  ValueNotifier<bool> loadMoreUpdateView = new ValueNotifier(false);
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  bool showLoading = false;
  bool loadMoreConversations = true;
  bool showLoad = false;
  int page = 1;
  var searchController = TextEditingController();
  String searchKeyword = '';

  ChatListController() {
    scrollController = new ScrollController();
  }

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> chatHistoryListing(page) async {
    if (page > 1) {
      showLoader.value = true;
      showLoader.notifyListeners();
    } else {
      showLoad = true;
    }
    chatRepo.chatHistoryListing(page).then((obj) {
      showLoad = false;
      if (page > 1) {
        showLoader.value = false;
        showLoader.notifyListeners();
        loadMoreUpdateView.value = true;
        loadMoreUpdateView.notifyListeners();
      }
      if (obj.totalChat == obj.chatMessages.length) {
        loadMoreConversations = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == 0) {
          if (obj.chatMessages.length != obj.totalChat && loadMoreConversations) {
            page = page + 1;
            chatHistoryListing(page);
          }
        }
      });
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print(e);
    });
  }

  Future<void> myConversations(page, {showApiLoader = true}) async {
    if (page > 1) {
      if (showApiLoader) {
        showLoad = true;
      }
    } else {
      if (showApiLoader) {
        showLoader.value = true;
        showLoader.notifyListeners();
        showLoading = true;
      }
      scrollController = new ScrollController();
    }
    if (!showApiLoader) {
      showLoader.value = true;
      showLoader.notifyListeners();
      showLoading = false;
    }
    ConversationsModel obj = await chatRepo.myConversations(page, searchKeyword);
    showLoad = false;
    showLoader.value = false;
    showLoading = false;
    showLoader.notifyListeners();

    if (obj.total == obj.data.length) {
      loadMoreConversations = false;
    }
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (obj.data.length != obj.total && loadMoreConversations) {
          page = page + 1;
          myConversations(page);
        }
      }
    });
  }

  Future<void> getPeople(page) async {
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    chatRepo.getPeople(page, searchKeyword).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.users.length == userValue.totalRecords) {
        loadMoreConversations = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && loadMoreConversations) {
            page = page + 1;
            getPeople(page);
          }
        }
      });
    });
  }
}
