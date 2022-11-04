import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/sound_model.dart';
import '../repositories/sound_repository.dart' as soundRepo;

class SoundListController extends ControllerMVC {
  int currentIndex = 0;
  String currentFile = "";
  final AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer.withId("4234234323asdsad");
  GlobalKey<ScaffoldState> soundScaffoldKey = GlobalKey<ScaffoldState>();
  var jsonData;
  var getSoundResult;
  var getFavSoundResult;
  bool allPaused = true;
  int userId = 0;
  int videoId = 0;
  List<SoundData> sounds = [];
  var textController1 = TextEditingController();
  var textController2 = TextEditingController();
  String searchKeyword = '';
  String searchKeyword1 = '';
  String searchKeyword2 = '';
  String catSearchKeyword = '';
  Map<dynamic, dynamic> map = {};
  ValueNotifier<bool> showLoader = new ValueNotifier(true);
  ScrollController scrollController = new ScrollController();
  ScrollController scrollController1 = new ScrollController();
  ScrollController catScrollController = new ScrollController();
  int page = 1;
  bool moreResults = true;
  Color loaderBGColor = Colors.black;
  bool showLoadMore = true;
  int favPage = 1;
  int catPage = 1;

  @override
  void initState() {
    soundScaffoldKey = new GlobalKey();
    super.initState();
  }

  showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  selectSound(SoundData sound) {
    soundRepo.selectSound(sound);
  }

  Future getSounds([searchKeyword]) async {
    showLoader.value = true;
    showLoader.notifyListeners();

    scrollController = new ScrollController();
    if (page > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getData(page, searchKeyword).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();

      if (value.data!.isNotEmpty) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (showLoadMore) {
            setState(() {
              page = page + 1;
            });
            getSounds();
          }
        }
      });
    });
  }

  Future<dynamic> setFavSounds(soundId, set) async {
    return soundRepo.setFavSound(soundId, set);
  }

  Future getFavSounds([searchKeyword]) async {
    if (searchKeyword == null) {
      searchKeyword = "";
    }
    showLoader.value = true;
    showLoader.notifyListeners();
    if (favPage == 1 && searchKeyword == '') {
      scrollController1 = new ScrollController();
    }

    if (favPage > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getFavData(favPage, searchKeyword).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (value.data!.isNotEmpty) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController.position.maxScrollExtent) {
          if (showLoadMore) {
            setState(() {
              favPage = favPage + 1;
            });
            getFavSounds();
          }
        }
      });
    });
  }

  Future getCatSounds(catId, [searchKeyword]) async {
    if (searchKeyword == null) {
      searchKeyword = "";
    }

    showLoader.value = true;
    showLoader.notifyListeners();
    catScrollController = new ScrollController();
    if (favPage > 1) {
      setState(() {
        loaderBGColor = Colors.black26;
      });
    }
    soundRepo.getCatData(catId, catPage, searchKeyword).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (value.data!.isNotEmpty) {
        showLoadMore = true;
      } else {
        showLoadMore = false;
      }
      catScrollController.addListener(() {
        if (catScrollController.position.pixels == catScrollController.position.maxScrollExtent) {
          if (showLoadMore) {
            setState(() {
              catPage = catPage + 1;
            });
            getCatSounds(catId);
          }
        }
      });
    });
  }
}
