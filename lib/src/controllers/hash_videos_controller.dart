import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leuke/src/models/search_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'dashboard_controller.dart';

class HashVideosController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> hashScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  PanelController pc = new PanelController();
  ScrollController scrollController = new ScrollController();
  ScrollController hashScrollController = new ScrollController();
  ScrollController videoScrollController = new ScrollController();
  ScrollController userScrollController = new ScrollController();
  ValueNotifier<bool> showLoader = ValueNotifier(false);
  bool showLoadMore = true;
  bool showLoadMoreHashTags = true;
  bool showLoadMoreUsers = true;
  bool showLoadMoreVideos = true;
  String searchKeyword = '';
  DashboardController homeCon = DashboardController();
  var searchController = TextEditingController();

  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  int hashesPage = 2;
  int videosPage = 2;
  int usersPage = 2;
  ValueNotifier<bool> showBannerAd = new ValueNotifier(false);
  late InterstitialAd _interstitialAd;
  late RewardedAd myRewarded;
  HashVideosController() {}

  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>();
    hashScaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    super.initState();
  }

  getAds() {
    appId = Platform.isAndroid ? hashRepo.adsData.value['android_app_id'] : hashRepo.adsData.value['ios_app_id'];
    bannerUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_banner_app_id'] : hashRepo.adsData.value['ios_banner_app_id'];
    screenUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_interstitial_app_id'] : hashRepo.adsData.value['ios_interstitial_app_id'];
    videoUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_video_app_id'] : hashRepo.adsData.value['ios_video_app_id'];
    bannerShowOn = hashRepo.adsData.value['banner_show_on'];
    interstitialShowOn = hashRepo.adsData.value['interstitial_show_on'];
    videoShowOn = hashRepo.adsData.value['video_show_on'];
    if (appId != "") {
      MobileAds.instance.initialize().then((value) async {
        if (bannerShowOn.indexOf("3") > -1) {
          showBannerAd.value = true;
          showBannerAd.notifyListeners();
        }
        if (interstitialShowOn.indexOf("3") > -1) {
          createInterstitialAd(screenUnitId);
        }
        if (videoShowOn.indexOf("3") > -1) {
          await createRewardedAd(videoUnitId);
        }
      });
    }
  }

  Future<void> createInterstitialAd(adUnit) async {
    _interstitialAd = InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      request: AdRequest(),
      listener: AdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) => print('Ad loaded.'),
        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {
          ad.dispose();
          print('Ad closed.');
        },
        // Called when an ad is in the process of leaving the application.
        onApplicationExit: (Ad ad) => print('Left application.'),
        // Called when a RewardedAd triggers a reward.
        onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
          print('Reward earned: $reward');
        },
      ),
    );
    Future<void>.delayed(Duration(seconds: 1), () => _interstitialAd.load());
    Future<void>.delayed(Duration(seconds: 3), () => _interstitialAd.show());
  }

  Future<void> createRewardedAd(adUnitId) async {
    myRewarded = RewardedAd(
      adUnitId: adUnitId,
      request: AdRequest(),
      listener: AdListener(
          onAdLoaded: (Ad ad) {
            print('${ad.runtimeType} loaded.');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('${ad.runtimeType} failed to load: $error');
            ad.dispose();

            createRewardedAd(adUnitId);
          },
          onAdOpened: (Ad ad) => print('${ad.runtimeType} onAdOpened.'),
          onAdClosed: (Ad ad) {
            print('${ad.runtimeType} closed.');
            ad.dispose();
          },
          onApplicationExit: (Ad ad) => print('${ad.runtimeType} onApplicationExit.'),
          onRewardedAdUserEarnedReward: (RewardedAd ad, RewardItem reward) {
            print(
              '$RewardedAd with reward $RewardItem(${reward.amount}, ${reward.type})',
            );
          }),
    );
    Future<void>.delayed(Duration(seconds: 1), () => myRewarded.load());
    Future<void>.delayed(Duration(seconds: 10), () => myRewarded.show());
  }

  Future getData(page) async {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value.userId = 0;
    homeCon.userVideoObj.value.videoId = 0;
    homeCon.userVideoObj.notifyListeners();
    // setState(() {
    showLoadMoreHashTags = true;
    showLoadMoreUsers = true;
    showLoadMoreVideos = true;
    hashesPage = 2;
    usersPage = 2;
    videosPage = 2;
    // });
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    hashRepo.getData(page, searchKeyword).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (value.videos.length == value.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (value.videos.length != value.totalRecords && showLoadMore) {
            page = page + 1;
            getData(page);
          }
        }
      });
    });
  }

  Future getHashData(page, hash) async {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value.userId = 0;
    homeCon.userVideoObj.value.videoId = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    hashRepo.getHashData(page, hash).then((value) {
      if (value != null) {
        showLoader.value = false;
        showLoader.notifyListeners();
        if (value.videos.length == value.totalRecords) {
          showLoadMore = false;
        }
        scrollController.addListener(() {
          if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
            if (value.videos.length != value.totalRecords && showLoadMore) {
              page = page + 1;
              getHashData(page, hash);
            }
          }
        });
      }
    });
  }

  Future getHashesData(searchKeyword) async {
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value.userId = 0;
      homeCon.userVideoObj.value.videoId = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      showLoader.value = true;
      showLoader.notifyListeners();
      hashScrollController = new ScrollController();
      hashRepo.getHashesData(hashesPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader.value = false;
          showLoader.notifyListeners();
          if (value.length == 0) {
            showLoadMoreHashTags = false;
          }
        }
      });
    }
  }

  Future getUsersData(searchKeyword) async {
    if (showLoadMoreHashTags) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value.userId = 0;
      homeCon.userVideoObj.value.videoId = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      showLoader.value = true;
      showLoader.notifyListeners();
      userScrollController = new ScrollController();
      hashRepo.getUsersData(usersPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader.value = false;
          showLoader.notifyListeners();
          if (value.length == 0) {
            showLoadMoreUsers = false;
          }
        }
      });
    }
  }

  Future getVideosData(searchKeyword) async {
    if (showLoadMoreVideos) {
      homeCon = videoRepo.homeCon.value;
      homeCon.userVideoObj.value.userId = 0;
      homeCon.userVideoObj.value.videoId = 0;
      homeCon.userVideoObj.notifyListeners();
      homeCon.notifyListeners();
      showLoader.value = true;
      showLoader.notifyListeners();
      videoScrollController = new ScrollController();
      hashRepo.getVideosData(videosPage, searchKeyword).then((value) {
        if (value != null) {
          showLoader.value = false;
          showLoader.notifyListeners();
          if (value.length > 0) {
            showLoadMoreVideos = false;
          }
        }
      });
    }
  }

  Future getSearchData(page) async {
    homeCon = videoRepo.homeCon.value;
    homeCon.userVideoObj.value.userId = 0;
    homeCon.userVideoObj.value.videoId = 0;
    homeCon.userVideoObj.notifyListeners();
    homeCon.notifyListeners();

    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    SearchModel value = await hashRepo.getSearchData(page, searchKeyword);
    showLoader.value = false;
    showLoader.notifyListeners();
    if (value.hashTags.length < 10) {
      // setState(() {
      showLoadMoreHashTags = false;
      // });
    } else {
      hashScrollController = new ScrollController();
      hashScrollController.addListener(() {
        if (hashScrollController.position.pixels >= hashScrollController.position.maxScrollExtent - 100) {
          if (showLoadMoreHashTags) {
            getHashesData(searchKeyword);
            // setState(() {
            hashesPage++;
            // });
          }
        }
      });
    }
    if (value.users.length < 10) {
      // setState(() {
      showLoadMoreUsers = false;
      // });
    } else {
      userScrollController = new ScrollController();
      userScrollController.addListener(() {
        if (userScrollController.position.pixels >= userScrollController.position.maxScrollExtent - 100) {
          if (showLoadMoreUsers) {
            getUsersData(searchKeyword);
            // setState(() {
            usersPage++;
            // });
          }
        }
      });
    }
    if (value.videos.length < 10) {
      // setState(() {
      showLoadMoreVideos = false;
      // });
    } else {
      videoScrollController = new ScrollController();
      videoScrollController.addListener(() {
        if (videoScrollController.position.pixels >= videoScrollController.position.maxScrollExtent - 100) {
          if (showLoadMoreVideos) {
            getVideosData(searchKeyword);
            // setState(() {
            videosPage++;
            // });
          }
        }
      });
    }
  }
}
