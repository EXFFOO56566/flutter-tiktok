import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:leuke/src/models/user_video_args.dart';
import 'package:like_button/like_button.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:share/share.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/dashboard_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../repositories/video_repository.dart';
import '../views/notifications_view.dart';
import '../widgets/AdsWidget.dart';
import '../widgets/VideoDescription.dart';
import '../widgets/VideoPlayer.dart';
import 'my_profile_view.dart';
import 'password_login_view.dart';
import 'user_profile_view.dart';

class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends StateMVC<DashboardView> with SingleTickerProviderStateMixin, RouteAware {
  DashboardController _con = DashboardController();
  double hgt = 0;
  late AnimationController musicAnimationController;
  DateTime currentBackPressTime = DateTime.now();
  @override
  Future<void> didChangeMetrics() async {
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != videoRepo.homeCon.value.textFieldMoveToUp) {
      setState(() {
        videoRepo.homeCon.value.textFieldMoveToUp = newValue;
      });
    }
  }

  @override
  void initState() {
    videoRepo.isOnHomePage.value = true;
    videoRepo.isOnHomePage.notifyListeners();
    _con = videoRepo.homeCon.value;
    _con.scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: "_dashboardPage");
    musicAnimationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 10),
    );
    musicAnimationController.repeat();
    if (userRepo.currentUser.value.email != '') {
      Timer(Duration(milliseconds: 300), () {
        _con.checkEulaAgreement();
      });
    }
    _con.getAds();
    super.initState();
  }

  waitForSometime() {
    Future.delayed(Duration(seconds: 2));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state.toString() == "AppLifecycleState.paused" ||
        state.toString() == "AppLifecycleState.inactive" ||
        state.toString() == "AppLifecycleState.detached" ||
        state.toString() == "AppLifecycleState.suspending ") {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
        }
      } else {
        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
        }
      }
    } else {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        _con.playController(videoRepo.homeCon.value.swiperIndex);
      } else {
        _con.playController2(videoRepo.homeCon.value.swiperIndex);
      }
    }
  }

  @override
  dispose() async {
    musicAnimationController.dispose();
    if (!videoRepo.homeCon.value.showFollowingPage.value && videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
      if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
      }
    } else if (videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2) != null) {
      if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
      }
    }
    if (!videoRepo.firstLoad.value) {
      int count = 0;
      if (videoRepo.homeCon.value.videoControllers.length > 0) {
        videoRepo.homeCon.value.videoControllers.forEach((key, value) async {
          await value!.dispose();
          videoRepo.homeCon.value.videoControllers.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.value.initializeVideoPlayerFutures.remove(videoRepo.videosData.value.videos.elementAt(count).url);
          videoRepo.homeCon.notifyListeners();
          count++;
        });
      }
      int count1 = 0;
      if (videoRepo.homeCon.value.videoControllers2.length > 0) {
        videoRepo.homeCon.value.videoControllers2.forEach((key, value) async {
          await value!.dispose();
          videoRepo.homeCon.value.videoControllers2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          videoRepo.homeCon.value.initializeVideoPlayerFutures2.remove(videoRepo.followingUsersVideoData.value.videos.elementAt(count1));
          count1++;
        });
      }
    } else {
      videoRepo.firstLoad.value = false;
      videoRepo.firstLoad.notifyListeners();
      videoRepo.homeCon.value.playController(0);
    }
    super.dispose();
  }

  validateForm(Video videoObj, context) {
    if (videoRepo.homeCon.value.formKey.currentState!.validate()) {
      videoRepo.homeCon.value.formKey.currentState!.save();
      videoRepo.homeCon.value.submitReport(videoObj, context);
    }
  }

  reportLayout(context, Video videoObj) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder(
            valueListenable: videoRepo.homeCon.value.showReportMsg,
            builder: (context, bool showMsg, _) {
              return AlertDialog(
                backgroundColor: settingRepo.setting.value.buttonColor,
                title: showMsg
                    ? Text("REPORT SUBMITTED!",
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ))
                    : Text("REPORT",
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 16,
                        )),
                insetPadding: EdgeInsets.zero,
                content: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: videoRepo.homeCon.value.formKey,
                  child: !showMsg
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: settingRepo.setting.value.accentColor,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    hint: new Text(
                                      "Select Type",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.7)),
                                    ),
                                    iconEnabledColor: settingRepo.setting.value.iconColor,
                                    style: new TextStyle(
                                      color: settingRepo.setting.value.textColor,
                                      fontSize: 15.0,
                                    ),
                                    value: videoRepo.homeCon.value.selectedType,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        videoRepo.homeCon.value.selectedType = newValue!;
                                      });
                                    },
                                    validator: (value) => value == null ? 'This field is required!' : null,
                                    items: videoRepo.homeCon.value.reportType.map((String val) {
                                      return new DropdownMenuItem(
                                        value: val,
                                        child: new Text(
                                          val,
                                          style: new TextStyle(color: settingRepo.setting.value.textColor),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            TextFormField(
                              maxLines: 4,
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontSize: 15.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(
                                  color: settingRepo.setting.value.textColor!.withOpacity(0.8),
                                  fontSize: 15.0,
                                ),
                              ),
                              onChanged: (String val) {
                                setState(() {
                                  _con.description = val;
                                });
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    WidgetsBinding.instance!.addPostFrameCallback((_) async {
                                      setState(() {
                                        if (!videoRepo.homeCon.value.showReportLoader.value) {
                                          validateForm(videoObj, context);
                                        }
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(color: settingRepo.setting.value.accentColor),
                                    child: ValueListenableBuilder(
                                        valueListenable: videoRepo.homeCon.value.showReportLoader,
                                        builder: (context, bool reportLoader, _) {
                                          return Center(
                                            child: (!reportLoader)
                                                ? Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: settingRepo.setting.value.buttonTextColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11,
                                                      fontFamily: 'RockWellStd',
                                                    ),
                                                  )
                                                : Helper.showLoaderSpinner(settingRepo.setting.value.textColor!),
                                          );
                                        }),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                      _con.videoController(videoRepo.homeCon.value.swiperIndex).play();
                                    } else {
                                      _con.videoController2(videoRepo.homeCon.value.swiperIndex2).play();
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 30,
                                    width: 60,
                                    decoration: BoxDecoration(color: settingRepo.setting.value.accentColor),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: settingRepo.setting.value.buttonTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Center(
                                child: Text(
                                  "Thanks for reporting. If we find this content to be in violation of our Guidelines, we will remove it.",
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              );
            });
      },
    );
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: settingRepo.setting.value.bgColor,
    ));
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.bgColor, statusBarIconBrightness: Brightness.light),
    );
    final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio);
    if (viewInsets.bottom == 0.0) {
      if (_con.bannerShowOn.indexOf("1") > -1) {
        _con.paddingBottom = Platform.isAndroid ? 0 : 80.0;
      } else {
        _con.paddingBottom = 0;
      }
    } else {
      _con.paddingBottom = 0;
    }
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (videoRepo.homeCon.value != null && videoRepo.homeCon.value.pc != null && videoRepo.homeCon.value.pc.isPanelOpen) {
          videoRepo.homeCon.value.pc.close();
          return Future.value(false);
        }
        if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          Fluttertoast.showToast(msg: "Tap again to exit an app.");
          return Future.value(false);
        }
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return Future.value(true);
      },
      child: Container(
        color: Colors.black12,
        child: Scaffold(
          key: _con.scaffoldKey,
          backgroundColor: settingRepo.setting.value.bgColor,
          body: ValueListenableBuilder(
              valueListenable: _con.isVideoInitialized,
              builder: (context, bool isVideoInitialized, _) {
                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () {
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                          }
                        } else {
                          if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                          }
                        }
                        Navigator.of(context).pushReplacementNamed('/home');
                        return _con.getVideos();
                      },
                      child: Container(
                        padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom),
                        child: homeWidget(),
                      ),
                    ),
                    !isVideoInitialized
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          )
                        : Container(),
                    Positioned(
                      bottom: Platform.isAndroid ? 0 : 15,
                      child: ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showBannerAd,
                        builder: (context, bool adLoader, _) {
                          return adLoader ? Center(child: Container(width: MediaQuery.of(context).size.width, child: BannerAdWidget(AdSize.banner))) : Container();
                        },
                      ),
                    ),
                  ],
                );
              }),
          bottomNavigationBar: !videoRepo.homeCon.value.hideBottomBar.value
              ? ConvexAppBar(
                  elevation: 0,
                  color: Colors.transparent,
                  backgroundColor: settingRepo.setting.value.navBgColor,
                  curveSize: 110,

                  top: -20,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      settingRepo.setting.value.buttonColor!,
                      settingRepo.setting.value.buttonColor!,
                    ],
                  ),
                  items: [
                    TabItem(
                      icon: ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showHomeLoader,
                        builder: (context, bool homeLoader, _) {
                          return !homeLoader
                              ? SvgPicture.asset(
                                  'assets/icons/home.svg',
                                  width: 28.0,
                                  color: settingRepo.setting.value.iconColor,
                                )
                              : Helper.showLoaderSpinner(settingRepo.setting.value.dashboardIconColor!);
                        },
                      ),
                    ),
                    TabItem(
                      icon: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/hash-tag.svg',
                          width: 35.0,
                          color: settingRepo.setting.value.iconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                            }
                          } else {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                            }
                          }

                          Navigator.pushReplacementNamed(
                            context,
                            '/hash-videos',
                          );
                        },
                      ),
                    ),
                    TabItem(
                      icon: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/create-video.svg',
                          width: 50.0,
                          color: settingRepo.setting.value.iconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          setState(() {
                            videoRepo.homeCon.value.paddingBottom = 0.0;
                          });
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                            }
                          } else {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                            }
                          }
                          if (currentUser.value.token != '') {
                            videoRepo.isOnRecordingPage.value = true;
                            videoRepo.isOnRecordingPage.notifyListeners();
                            Navigator.pushReplacementNamed(context, '/video-recorder');
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordLoginView(userId: 0),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    TabItem(
                        icon: ValueListenableBuilder(
                            valueListenable: videoRepo.unreadMessageCount,
                            builder: (context, int _messageCount, _) {
                              print("_messageCount $_messageCount");
                              return Stack(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    icon: SvgPicture.asset(
                                      'assets/icons/chat.svg',
                                      width: 30.0,
                                      color: settingRepo.setting.value.iconColor,
                                    ),
                                    onPressed: () async {
                                      videoRepo.isOnHomePage.value = false;
                                      videoRepo.isOnHomePage.notifyListeners();
                                      if (!_con.showFollowingPage.value) {
                                        _con.videoController(_con.swiperIndex).pause();
                                      } else {
                                        _con.videoController2(_con.swiperIndex2).pause();
                                      }
                                      if (currentUser.value.token != '') {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/conversation",
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PasswordLoginView(userId: 0),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _messageCount > 0
                                        ? Transform.translate(
                                            offset: Offset(-2, -6),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                                              decoration: BoxDecoration(
                                                color: settingRepo.setting.value.textColor,
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _messageCount.toString(),
                                                  style: TextStyle(
                                                    color: settingRepo.setting.value.accentColor,
                                                    fontSize: 8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                  ),
                                ],
                              );
                            })),
                    TabItem(
                      icon: IconButton(
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/user.svg',
                          width: 30.0,
                          color: settingRepo.setting.value.dashboardIconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          if (!_con.showFollowingPage.value) {
                            if (_con.videoController(_con.swiperIndex) != null) {
                              _con.videoController(_con.swiperIndex).pause();
                            }
                          } else {
                            if (_con.videoController2(_con.swiperIndex2) != null) {
                              _con.videoController2(_con.swiperIndex2).pause();
                            }
                          }
                          setState(() {
                            videoRepo.homeCon.value.paddingBottom = 0.0;
                          });
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                              }
                            }
                          } else {
                            if (videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2) != null) {
                              if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                              }
                            }
                          }
                          if (currentUser.value.token != '') {
                            Navigator.pushReplacementNamed(
                              context,
                              "/my-profile",
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordLoginView(userId: 0),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                  initialActiveIndex: 2, //optional, default as 0
                  activeColor: Colors.transparent,
                  onTap: (int i) async {
                    if (i == 0) {
                      if (!videoRepo.homeCon.value.showHomeLoader.value) {
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                            }
                          }
                        } else {
                          if (videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2) != null) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                            }
                          }
                        }
                        videoRepo.homeCon.value.userVideoObj.value.userId = 0;
                        videoRepo.homeCon.value.userVideoObj.value.videoId = 0;
                        videoRepo.homeCon.value.userVideoObj.value.name = "";
                        videoRepo.homeCon.value.userVideoObj.notifyListeners();
                        videoRepo.homeCon.value.showHomeLoader.value = true;
                        videoRepo.homeCon.value.showHomeLoader.notifyListeners();
                        await Future.delayed(
                          Duration(seconds: 2),
                        );

                        Navigator.of(context).pushReplacementNamed('/home');
                        _con.getVideos();
                      }
                    } else if (i == 1) {
                      videoRepo.isOnHomePage.value = false;
                      videoRepo.isOnHomePage.notifyListeners();
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        }
                      } else {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                      }

                      Navigator.pushReplacementNamed(
                        context,
                        '/hash-videos',
                      );
                    } else if (i == 2) {
                      videoRepo.isOnHomePage.value = false;
                      videoRepo.isOnHomePage.notifyListeners();
                      setState(() {
                        videoRepo.homeCon.value.paddingBottom = 0.0;
                      });
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        }
                      } else {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                      }
                      if (currentUser.value.token != '') {
                        videoRepo.isOnRecordingPage.value = true;
                        videoRepo.isOnRecordingPage.notifyListeners();
                        Navigator.pushReplacementNamed(context, '/video-recorder');
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordLoginView(userId: 0),
                          ),
                        );
                      }
                    } else if (i == 3) {
                      videoRepo.isOnHomePage.value = false;
                      videoRepo.isOnHomePage.notifyListeners();
                      if (!_con.showFollowingPage.value) {
                        _con.videoController(_con.swiperIndex).pause();
                      } else {
                        _con.videoController2(_con.swiperIndex2).pause();
                      }
                      Navigator.pushReplacementNamed(
                        context,
                        "/conversation",
                      );
                    } else if (i == 4) {
                      videoRepo.isOnHomePage.value = false;
                      videoRepo.isOnHomePage.notifyListeners();
                      if (!_con.showFollowingPage.value) {
                        _con.videoController(_con.swiperIndex).pause();
                      } else {
                        _con.videoController2(_con.swiperIndex2).pause();
                      }
                      setState(() {
                        videoRepo.homeCon.value.paddingBottom = 0.0;
                      });
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        }
                      } else {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                      }
                      if (currentUser.value.token != '') {
                        Navigator.pushReplacementNamed(
                          context,
                          "/my-profile",
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PasswordLoginView(userId: 0),
                          ),
                        );
                      }
                    }
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget bottomToolbarWidget(index, PanelController pc3, PanelController pc2) {
    {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showHomeLoader,
                        builder: (context, bool homeLoader, _) {
                          return IconButton(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.all(0),
                            icon: SvgPicture.asset(
                              homeLoader ? 'assets/icons/reloading.gif' : 'assets/icons/home.svg',
                              width: 28.0,
                              color: settingRepo.setting.value.dashboardIconColor,
                            ),
                            onPressed: () async {
                              if (!homeLoader) {
                                if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                  if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                  }
                                } else {
                                  if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                                  }
                                }
                                videoRepo.homeCon.value.userVideoObj.value.userId = 0;
                                videoRepo.homeCon.value.userVideoObj.value.videoId = 0;
                                videoRepo.homeCon.value.userVideoObj.value.name = "";
                                videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                videoRepo.homeCon.value.showHomeLoader.value = true;
                                videoRepo.homeCon.value.showHomeLoader.notifyListeners();
                                await Future.delayed(
                                  Duration(seconds: 2),
                                );

                                Navigator.of(context).pushReplacementNamed('/home');
                                _con.getVideos();
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/hash-tag.svg',
                          width: 30.0,
                          color: settingRepo.setting.value.dashboardIconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                            }
                          } else {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                            }
                          }

                          Navigator.pushReplacementNamed(
                            context,
                            '/hash-videos',
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.all(0),
                      icon: SvgPicture.asset(
                        'assets/icons/create-video.svg',
                        width: 20.0,
                        color: settingRepo.setting.value.dashboardIconColor,
                      ),
                      onPressed: () async {
                        videoRepo.isOnHomePage.value = false;
                        videoRepo.isOnHomePage.notifyListeners();
                        setState(() {
                          videoRepo.homeCon.value.paddingBottom = 0.0;
                        });
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                          }
                        } else {
                          if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                            videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                          }
                        }
                        if (currentUser.value.token != '') {
                          videoRepo.isOnRecordingPage.value = true;
                          videoRepo.isOnRecordingPage.notifyListeners();
                          Navigator.pushReplacementNamed(context, '/video-recorder');
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordLoginView(userId: 0),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/chat.svg',
                          width: 30.0,
                          color: settingRepo.setting.value.dashboardIconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          if (!_con.showFollowingPage.value) {
                            _con.videoController(_con.swiperIndex).pause();
                          } else {
                            _con.videoController2(_con.swiperIndex2).pause();
                          }

                          setState(() {
                            _con.paddingBottom = 0.0;
                          });

                          if (currentUser.value.token != '') {
                            Navigator.pushReplacementNamed(
                              context,
                              "/user-chats",
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordLoginView(userId: 0),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.all(0),
                        icon: SvgPicture.asset(
                          'assets/icons/user.svg',
                          width: 30.0,
                          color: settingRepo.setting.value.dashboardIconColor,
                        ),
                        onPressed: () async {
                          videoRepo.isOnHomePage.value = false;
                          videoRepo.isOnHomePage.notifyListeners();
                          if (!_con.showFollowingPage.value) {
                            _con.videoController(_con.swiperIndex).pause();
                          } else {
                            _con.videoController2(_con.swiperIndex2).pause();
                          }
                          setState(() {
                            videoRepo.homeCon.value.paddingBottom = 0.0;
                          });
                          if (!videoRepo.homeCon.value.showFollowingPage.value) {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                            }
                          } else {
                            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                            }
                          }
                          if (currentUser.value.token != '') {
                            Navigator.pushReplacementNamed(
                              context,
                              "/my-profile",
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordLoginView(userId: 0),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  bool _keyboardVisible = false;
  Widget homeWidget() {
    {
      _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
      videoRepo.homeCon.value.loadMoreUpdateView.addListener(() {
        if (videoRepo.homeCon.value.loadMoreUpdateView.value) {
          if (mounted) setState(() {});
        }
      });

      Video? videoObj = Video();
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
      } else {
        videoObj = (followingUsersVideoData.value.videos.length > 0) ? followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : videoObj;

        if (videoObj == Video()) {
          videoObj = (videosData.value.videos.length > 0) ? videosData.value.videos.elementAt(videoRepo.homeCon.value.videoIndex) : null;
        }
      }
      Widget commentField(editCommentIndex) {
        return TextFormField(
          style: TextStyle(
            color: settingRepo.setting.value.textColor,
            fontSize: 16.0,
          ),
          obscureText: false,
          focusNode: videoRepo.homeCon.value.inputNode,
          keyboardType: TextInputType.text,
          controller: videoRepo.homeCon.value.commentController,
          onSaved: (String? val) {
            videoRepo.homeCon.value.commentValue = val!;
          },
          onChanged: (String? val) {
            videoRepo.homeCon.value.commentValue = val!;
          },
          onTap: () {
            setState(() {
              if (_con.bannerShowOn.indexOf("1") > -1) {
                _con.paddingBottom = 0;
              }
              videoRepo.homeCon.value.textFieldMoveToUp = true;
              videoRepo.homeCon.value.loadMoreUpdateView.value = true;
              videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
              Timer(
                  Duration(milliseconds: 200),
                  () => setState(() {
                        hgt = EdgeInsets.fromWindowPadding(WidgetsBinding.instance!.window.viewInsets, WidgetsBinding.instance!.window.devicePixelRatio).bottom;
                      }));
            });
          },
          decoration: new InputDecoration(
            fillColor: settingRepo.setting.value.bgShade,
            filled: true,
            contentPadding: EdgeInsets.only(left: 20, top: 0),
            errorStyle: TextStyle(
              color: Color(0xFF210ed5),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              wordSpacing: 2.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            hintText: "Add a comment",
            hintStyle: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.5), fontSize: 14),
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  videoRepo.homeCon.value.textFieldMoveToUp = false;
                });
                if (videoRepo.homeCon.value.commentValue.trim() != '' && videoRepo.homeCon.value.commentValue != null) {
                  editCommentIndex > 0
                      ? videoRepo.homeCon.value.editComment(videoRepo.homeCon.value.editedComment.value - 1, videoObj!.videoId, context)
                      : videoRepo.homeCon.value.addComment(videoObj!.videoId, context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10, right: 15),
                child: SvgPicture.asset(
                  'assets/icons/send.svg',
                  width: 15,
                  height: 15,
                  fit: BoxFit.fill,
                  color: settingRepo.setting.value.accentColor,
                ),
              ),
            ),
          ),
        );
      }

      return (videoObj != null)
          ? SlidingUpPanel(
              controller: videoRepo.homeCon.value.pc,
              minHeight: 0,
              backdropEnabled: true,
              color: Colors.black,
              backdropColor: Colors.white,
              padding: EdgeInsets.only(top: 20, bottom: 0),
              header: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            LikeButton(
                              size: 25,
                              circleColor: CircleColor(start: Colors.transparent, end: Colors.transparent),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: videoObj.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                                dotSecondaryColor: videoObj.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                              ),
                              likeBuilder: (bool isLiked) {
                                return SvgPicture.asset(
                                  'assets/icons/liked.svg',
                                  width: 28.0,
                                  color: videoObj!.isLike ? Color(0xffee1d52) : settingRepo.setting.value.dashboardIconColor,
                                );
                              },
                              onTap: onLikeButtonTapped,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              Helper.formatter(videoObj.totalLikes.toString()),
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/chat.svg',
                              width: 25,
                              color: settingRepo.setting.value.iconColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              Helper.formatter(videoObj.totalComments.toString()),
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/views.svg',
                              width: 25,
                              color: settingRepo.setting.value.iconColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              Helper.formatter(videoObj.totalViews.toString()),
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            Codec<String, String> stringToBase64 = utf8.fuse(base64);
                            String vId = stringToBase64.encode(videoObj!.videoId.toString());
                            Share.share('${GlobalConfiguration().get('base_url')}$vId');
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/share.svg',
                                width: 35,
                                color: settingRepo.setting.value.iconColor,
                              ),
                              Text(
                                "0",
                                style: TextStyle(
                                  color: settingRepo.setting.value.textColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: .5,
                    color: Colors.white,
                  )
                ],
              ),
              maxHeight: config.App(context).appHeight(_keyboardVisible ? 50 : 70),
              onPanelOpened: () async {
                if (_con.bannerShowOn.indexOf("1") > -1) {
                  setState(() {
                    _con.paddingBottom = 0;
                  });
                }
              },
              onPanelClosed: () {
                videoRepo.homeCon.value.showBannerAd.value = false;
                videoRepo.homeCon.value.showBannerAd.notifyListeners();
                setState(() {
                  if (_con.bannerShowOn.indexOf("1") > -1) {
                    _con.paddingBottom = Platform.isAndroid ? 50.0 : 80.0;
                  }
                });
                videoRepo.homeCon.value.textFieldMoveToUp = false;
                FocusScope.of(context).unfocus();
                // setState(() {
                videoRepo.homeCon.value.hideBottomBar.value = false;
                videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                videoRepo.homeCon.value.comments = [];
                // });
                videoRepo.homeCon.notifyListeners();
                videoRepo.homeCon.value.commentController = new TextEditingController(text: "");
                videoRepo.homeCon.value.loadMoreUpdateView.value = false;
                videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
              },
              panel: Padding(
                padding: const EdgeInsets.only(top: 55, bottom: 0),
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.editedComment,
                    builder: (context, int editCommentIndex, _) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: ValueListenableBuilder(
                                  valueListenable: videoRepo.homeCon.value.commentsLoader,
                                  builder: (context, bool loader, _) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: settingRepo.setting.value.bgColor,
                                          ),
                                          child: (videoRepo.homeCon.value.comments.length > 0)
                                              ? Padding(
                                                  padding: videoRepo.homeCon.value.comments.length > 5
                                                      ? currentUser.value.token != ''
                                                          ? EdgeInsets.only(bottom: 10)
                                                          : EdgeInsets.zero
                                                      : EdgeInsets.zero,
                                                  child: ListView.separated(
                                                    controller: videoRepo.homeCon.value.scrollController,
                                                    padding: EdgeInsets.zero,
                                                    scrollDirection: Axis.vertical,
                                                    itemCount: videoRepo.homeCon.value.comments.length,
                                                    itemBuilder: (context, i) {
                                                      return Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: config.App(context).appWidth(25),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  videoRepo.isOnHomePage.value = false;
                                                                  videoRepo.isOnHomePage.notifyListeners();
                                                                  videoRepo.homeCon.value.hideBottomBar.value = false;
                                                                  videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                                                                  videoRepo.homeCon.notifyListeners();
                                                                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                                    if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                                                      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                                                    }
                                                                  } else {
                                                                    if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                                                      videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                                                                    }
                                                                  }
                                                                  Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => videoRepo.homeCon.value.comments.elementAt(i).userId == userRepo.currentUser.value.userId
                                                                          ? MyProfileView()
                                                                          : UsersProfileView(
                                                                              userId: videoRepo.homeCon.value.comments.elementAt(i).userId,
                                                                            ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  width: 60.0,
                                                                  height: 60.0,
                                                                  decoration: new BoxDecoration(
                                                                    border: Border.all(color: settingRepo.setting.value.textColor!, width: 2),
                                                                    shape: BoxShape.circle,
                                                                    image: new DecorationImage(
                                                                      fit: BoxFit.cover,
                                                                      image: videoRepo.homeCon.value.comments.elementAt(i).userDp.isNotEmpty
                                                                          ? CachedNetworkImageProvider(
                                                                              videoRepo.homeCon.value.comments.elementAt(i).userDp,
                                                                              maxWidth: 120,
                                                                              maxHeight: 120,
                                                                            )
                                                                          : AssetImage(
                                                                              "assets/images/video-logo.png",
                                                                            ) as ImageProvider,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      InkWell(
                                                                        onTap: () {
                                                                          videoRepo.isOnHomePage.value = false;
                                                                          videoRepo.isOnHomePage.notifyListeners();
                                                                          videoRepo.isOnHomePage.value = false;
                                                                          videoRepo.isOnHomePage.notifyListeners();
                                                                          videoRepo.homeCon.value.hideBottomBar.value = false;
                                                                          videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                                                                          videoRepo.homeCon.notifyListeners();
                                                                          Navigator.pushReplacement(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => videoRepo.homeCon.value.comments.elementAt(i).userId == userRepo.currentUser.value.userId
                                                                                  ? MyProfileView()
                                                                                  : UsersProfileView(
                                                                                      userId: videoRepo.homeCon.value.comments.elementAt(i).userId,
                                                                                    ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Text(
                                                                              videoRepo.homeCon.value.comments.elementAt(i).userName,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                color: settingRepo.setting.value.textColor,
                                                                                fontSize: 18.0,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            videoRepo.homeCon.value.comments.elementAt(i).isVerified == true
                                                                                ? Icon(
                                                                                    Icons.verified,
                                                                                    color: settingRepo.setting.value.accentColor,
                                                                                    size: 16,
                                                                                  )
                                                                                : Container(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      userRepo.currentUser.value.userId == videoRepo.homeCon.value.comments.elementAt(i).userId ||
                                                                              userRepo.currentUser.value.userId == videoObj!.userId
                                                                          ? Container(
                                                                              width: 50,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  Container(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                    child: Text(
                                                                                      videoRepo.homeCon.value.comments.elementAt(i).time,
                                                                                      style: TextStyle(
                                                                                        color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                                                                        fontSize: 12.0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    height: 20,
                                                                                    width: 18,
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                                                                    child: Center(
                                                                                      child: PopupMenuButton<int>(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                                          color: settingRepo.setting.value.bgShade,
                                                                                          icon: Icon(
                                                                                            Icons.more_vert,
                                                                                            size: 18,
                                                                                            color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                                                                          ),
                                                                                          onSelected: (int) {
                                                                                            if (int == 0) {
                                                                                              homeCon.value.onEditComment(i + 1, context);
                                                                                            } else {
                                                                                              _con.showDeleteAlert(context, "Delete Confirmation", "Do you realy want to delete this comment",
                                                                                                  videoRepo.homeCon.value.comments.elementAt(i).commentId, videoObj!.videoId);
                                                                                            }
                                                                                          },
                                                                                          itemBuilder: (context) {
                                                                                            return userRepo.currentUser.value.userId == videoRepo.homeCon.value.comments.elementAt(i).userId
                                                                                                ? [
                                                                                                    PopupMenuItem(
                                                                                                      height: 15,
                                                                                                      value: 0,
                                                                                                      child: Padding(
                                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                                        child: Text(
                                                                                                          "Edit",
                                                                                                          style: TextStyle(
                                                                                                            color: settingRepo.setting.value.textColor,
                                                                                                            // fontFamily: 'RockWellStd',
                                                                                                            fontSize: 12,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    PopupMenuItem(
                                                                                                      height: 15,
                                                                                                      value: 1,
                                                                                                      child: Padding(
                                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                                        child: Text(
                                                                                                          "Delete",
                                                                                                          style: TextStyle(
                                                                                                            color: settingRepo.setting.value.textColor,
                                                                                                            fontSize: 12,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                  ]
                                                                                                : [
                                                                                                    PopupMenuItem(
                                                                                                      height: 15,
                                                                                                      value: 1,
                                                                                                      child: Text(
                                                                                                        "Delete",
                                                                                                        style: TextStyle(
                                                                                                          color: settingRepo.setting.value.textColor,
                                                                                                          // fontFamily: 'RockWellStd',
                                                                                                          fontSize: 12,
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                  ];
                                                                                          }),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                                                              child: Text(
                                                                                videoRepo.homeCon.value.comments.elementAt(i).time,
                                                                                style: TextStyle(
                                                                                  color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                                                                  fontSize: 12.0,
                                                                                ),
                                                                              ),
                                                                            )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    videoRepo.homeCon.value.comments.elementAt(i).comment,
                                                                    style: TextStyle(
                                                                      color: settingRepo.setting.value.textColor,
                                                                      fontSize: 12.0,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder: (context, index) {
                                                      return Divider(
                                                        color: Colors.white,
                                                        thickness: 0.1,
                                                      );
                                                    },
                                                  ),
                                                )
                                              : (videoObj!.totalComments > 0)
                                                  ? SkeletonLoader(
                                                      builder: Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 10,
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            CircleAvatar(
                                                              backgroundColor: settingRepo.setting.value.textColor,
                                                              radius: 18,
                                                            ),
                                                            SizedBox(width: 20),
                                                            Expanded(
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Align(
                                                                    alignment: Alignment.topLeft,
                                                                    child: Container(
                                                                      height: 8,
                                                                      width: 80,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  Container(
                                                                    width: double.infinity,
                                                                    height: 8,
                                                                    color: Colors.white,
                                                                  ),
                                                                  SizedBox(height: 4),
                                                                  Container(
                                                                    width: double.infinity,
                                                                    height: 8,
                                                                    color: Colors.white,
                                                                  ),
                                                                  SizedBox(height: 15),
                                                                  Align(
                                                                    alignment: Alignment.topLeft,
                                                                    child: Container(
                                                                      width: 50,
                                                                      height: 9,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      items: videoObj.totalComments > 3 ? 3 : videoObj.totalComments,
                                                      period: Duration(seconds: 1),
                                                      highlightColor: Colors.white60,
                                                      direction: SkeletonDirection.ltr,
                                                    )
                                                  : Center(
                                                      child: Text(
                                                        "No comment available",
                                                        style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.5), fontSize: 17, fontWeight: FontWeight.w500),
                                                      ),
                                                    ),
                                        ),
                                        loader
                                            ? Helper.showLoaderSpinner(Colors.white)
                                            : SizedBox(
                                                height: 0,
                                              )
                                      ],
                                    );
                                  })),
                          Container(
                            height: 0.1,
                            color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                          ),
                          currentUser.value.token != ''
                              ? Container(
                                  padding: EdgeInsets.only(bottom: 20),
                                  height: 100,
                                  width: config.App(context).appWidth(100),
                                  child: Center(
                                    child: ValueListenableBuilder(
                                        valueListenable: videoRepo.homeCon.value.editedComment,
                                        builder: (context, int editCommentIndex, _) {
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: config.App(context).appWidth(25),
                                                child: Center(
                                                  child: Container(
                                                    width: 40.0,
                                                    height: 40.0,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: userRepo.currentUser.value.userDP != null && userRepo.currentUser.value.userDP != ""
                                                          ? CachedNetworkImage(
                                                              imageUrl: userRepo.currentUser.value.userDP,
                                                              placeholder: (context, url) => Center(
                                                                child: Helper.showLoaderSpinner(Colors.white),
                                                              ),
                                                              fit: BoxFit.fill,
                                                            )
                                                          : Image.asset(
                                                              "assets/images/video-logo.png",
                                                              width: 40,
                                                              height: 40,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: config.App(context).appWidth(70),
                                                  child: commentField(editCommentIndex),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                )
                              : SizedBox(
                                  height: 0,
                                ),
                        ],
                      );
                    }),
              ),
              body: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.showFollowingPage,
                  builder: (context, bool show, _) {
                    return !show
                        ? ValueListenableBuilder(
                            valueListenable: videosData,
                            builder: (context, VideoModel video, _) {
                              return Stack(
                                children: <Widget>[
                                  Swiper(
                                    controller: videoRepo.homeCon.value.swipeController as SwiperController,
                                    loop: false,
                                    index: videoRepo.homeCon.value.swiperIndex,
                                    control: new SwiperControl(
                                      color: Colors.transparent,
                                    ),
                                    onIndexChanged: (index) {
                                      print("onIndexChanged $index");
                                      if (videoRepo.homeCon.value.swiperIndex > index) {
                                        print("Prev Code");
                                        videoRepo.homeCon.value.previousVideo(index);
                                      } else {
                                        print("Next Code");
                                        videoRepo.homeCon.value.nextVideo(index);
                                      }
                                      videoRepo.homeCon.value.updateSwiperIndex(index);
                                      if (video.videos.length - index == 3) {
                                        videoRepo.homeCon.value.listenForMoreVideos().whenComplete(() => unawaited(videoRepo.homeCon.value.preCacheVideos()));
                                      }
                                    },
                                    itemBuilder: (BuildContext context, int index) {
                                      print("Swiper index $index");
                                      return GestureDetector(
                                          onTap: () {
                                            print("click Played");
                                            setState(() {
                                              _con.onTap = true;
                                              videoRepo.homeCon.notifyListeners();
                                              if (_con.videoController(_con.swiperIndex).value.isPlaying) {
                                                _con.videoController(_con.swiperIndex).pause();
                                              } else {
                                                // If the video is paused, play it.
                                                _con.videoController(_con.swiperIndex).play();
                                              }
                                            });
                                          },
                                          child: Stack(
                                            fit: StackFit.loose,
                                            children: <Widget>[
                                              Container(
                                                height: MediaQuery.of(context).size.height,
                                                width: MediaQuery.of(context).size.width,
                                                child: Center(
                                                  child: Container(
                                                    color: settingRepo.setting.value.bgColor,
                                                    child: VideoPlayerWidget(videoRepo.homeCon.value.videoController(index), video.videos.elementAt(index),
                                                        videoRepo.homeCon.value.initializeVideoPlayerFutures[video.videos.elementAt(index).url]!),
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  // Top section
                                                  // Middle expanded
                                                  Container(
                                                    padding: new EdgeInsets.only(
                                                      bottom: videoRepo.homeCon.value.paddingBottom + MediaQuery.of(context).padding.bottom,
                                                    ),
                                                    child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                                                      VideoDescription(
                                                        video.videos.elementAt(index),
                                                        videoRepo.homeCon.value.pc3,
                                                      ),
                                                      sidebar(index, video)
                                                    ]),
                                                  ),
                                                  SizedBox(
                                                    height: 70.0,
                                                  ),
                                                ],
                                              ),
                                              (videoRepo.homeCon.value.swiperIndex == 0 && !videoRepo.homeCon.value.initializePage)
                                                  ? SafeArea(
                                                      child: Container(
                                                        height: MediaQuery.of(context).size.height / 4,
                                                        width: MediaQuery.of(context).size.width,
                                                        color: Colors.transparent,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ));
                                      // }
                                    },
                                    itemCount: video.videos.length,
                                    scrollDirection: Axis.vertical,
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: videoRepo.homeCon.value.userVideoObj,
                                      builder: (context, UserVideoArgs value, _) {
                                        return (value.userId == 0 || value.userId == 0) && (value.videoId == 0 || value.videoId == 0)
                                            ? topSection(video)
                                            : Padding(
                                                padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 0,
                                                        child: IconButton(
                                                          icon: Icon(
                                                            Icons.arrow_back_ios,
                                                            color: Colors.white,
                                                          ),
                                                          onPressed: () async {
                                                            if (value.videoId != 0 && value.userId == 0) {
                                                              videoRepo.homeCon.value.userVideoObj.value.userId = 0;
                                                              videoRepo.homeCon.value.userVideoObj.value.videoId = 0;
                                                              videoRepo.homeCon.value.userVideoObj.value.name = '';
                                                              videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                                              Navigator.of(context).pop();
                                                            } else {
                                                              videoRepo.homeCon.value.userVideoObj.value.userId = 0;
                                                              videoRepo.homeCon.value.userVideoObj.value.videoId = 0;
                                                              videoRepo.homeCon.value.userVideoObj.value.name = '';
                                                              videoRepo.homeCon.value.userVideoObj.notifyListeners();
                                                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                                if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                                                }
                                                              } else {
                                                                if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                                                                }
                                                              }
                                                              // await videoRepo.homeCon.value.getFollowingUserVideos();
                                                              Navigator.of(context).pushReplacementNamed('/home');
                                                              _con.getVideos();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Transform.translate(
                                                          offset: Offset(-10, 0),
                                                          child: Text(
                                                            value.name != ""
                                                                ? value.name + " Videos"
                                                                : value.userId != 0
                                                                    ? "My Videos"
                                                                    : "",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                      }),
                                ],
                              );
                            },
                          )
                        : ValueListenableBuilder(
                            valueListenable: followingUsersVideoData,
                            builder: (context, VideoModel video, _) {
                              return Stack(
                                children: <Widget>[
                                  (video.videos.length > 0)
                                      ? Swiper(
                                          controller: videoRepo.homeCon.value.swipeController2 as SwiperController,
                                          loop: false,
                                          index: videoRepo.homeCon.value.swiperIndex2,
                                          control: new SwiperControl(
                                            color: Colors.transparent,
                                          ),
                                          onIndexChanged: (index) {
                                            if (videoRepo.homeCon.value.swiperIndex2 > index) {
                                              videoRepo.homeCon.value.previousVideo2(index);
                                            } else {
                                              videoRepo.homeCon.value.nextVideo2(index);
                                            }
                                            videoRepo.homeCon.value.updateSwiperIndex2(index);
                                            if (video.videos.length - index == 3) {
                                              videoRepo.homeCon.value.listenForMoreUserFollowingVideos();
                                            }
                                          },
                                          itemBuilder: (BuildContext context, int index) {
                                            print("Swiper index $index");
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  // If the video is playing, pause it.
                                                  if (_con.videoController2(_con.swiperIndex2).value.isPlaying) {
                                                    _con.videoController2(_con.swiperIndex2).pause();
                                                  } else {
                                                    // If the video is paused, play it.
                                                    _con.videoController2(_con.swiperIndex2).play();
                                                  }
                                                });
                                              },
                                              child: new Stack(
                                                fit: StackFit.loose,
                                                children: <Widget>[
                                                  Center(
                                                    child: Container(
                                                      color: Colors.black,
                                                      constraints: BoxConstraints(minWidth: 100, maxWidth: 500),
                                                      child: VideoPlayerWidget(videoRepo.homeCon.value.videoController2(index), video.videos.elementAt(index),
                                                          videoRepo.homeCon.value.initializeVideoPlayerFutures2[video.videos.elementAt(index).url]!),
                                                    ),
                                                  ),
                                                  Stack(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: <Widget>[
                                                          // Top section
                                                          // Middle expanded
                                                          Container(
                                                            padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom + MediaQuery.of(context).padding.bottom),
                                                            child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                                                              VideoDescription(
                                                                video.videos.elementAt(index),
                                                                videoRepo.homeCon.value.pc3,
                                                              ),
                                                              sidebar(index, video)
                                                            ]),
                                                          ),
                                                          SizedBox(
                                                            height: 70.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  (videoRepo.homeCon.value.swiperIndex2 == 0 && !videoRepo.homeCon.value.initializePage)
                                                      ? SafeArea(
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                  context,
                                                                ).size.height /
                                                                4,
                                                            width: MediaQuery.of(
                                                              context,
                                                            ).size.width,
                                                            color: Colors.transparent,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            );
                                            // }
                                          },
                                          itemCount: video.videos.length,
                                          scrollDirection: Axis.vertical,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(color: Colors.black87),
                                          height: MediaQuery.of(context).size.height,
                                          width: MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                  if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                                  }
                                                } else {
                                                  if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                                                  }
                                                }
                                                if (currentUser.value.token != '') {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/users',
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => PasswordLoginView(userId: 0),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.all(10),
                                                      padding: EdgeInsets.all(5),
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(width: 2, color: Colors.white)),
                                                      child: Icon(
                                                        Icons.person,
                                                        color: Colors.white,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "This is your feed of user you follow.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      "You can follow people or subscribe to hashtags.",
                                                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Icon(Icons.person_add, color: Colors.white, size: 45),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  topSection(video),
                                ],
                              );
                            },
                          );
                  }),
            )
          : Container(
              decoration: BoxDecoration(color: Colors.black87),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Container(
                    height: 111,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Following",
                            style: TextStyle(
                              color: settingRepo.setting.value.textColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.0,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 18,
                            width: 2,
                            color: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            child: Text(
                              "Featured",
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                              ),
                            ),
                            onTap: () async {
                              if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                }
                              } else {
                                videoRepo.homeCon.value.showFollowingPage.value = false;
                                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                                  videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                                }
                              }

                              Navigator.of(context).pushReplacementNamed('/home');
                              _con.getVideos();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Center(
                      child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                    ),
                  ),
                ],
              ),
            );
    }
  }

  Widget topSection(video) {
    return SafeArea(
      child: Container(
        color: Colors.black12,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(top: 25.0, bottom: 0),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showFollowingPage,
                        builder: (context, bool show, _) {
                          return Text("Following",
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                                fontWeight: show ? FontWeight.bold : FontWeight.w400,
                                fontSize: 16.0,
                              ));
                        }),
                    onTap: () async {
                      videoRepo.homeCon.value.showFollowingPage.value = true;
                      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        }
                      } else {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                      }
                      Navigator.of(context).pushReplacementNamed('/home');
                      videoRepo.homeCon.value.getFollowingUserVideos();
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 18,
                    width: 1,
                    color: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: ValueListenableBuilder(
                        valueListenable: videoRepo.homeCon.value.showFollowingPage,
                        builder: (context, bool show, _) {
                          return Text(
                            "Featured",
                            style: TextStyle(
                              color: settingRepo.setting.value.textColor,
                              fontWeight: show ? FontWeight.w400 : FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          );
                        }),
                    onTap: () async {
                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        }
                      } else {
                        videoRepo.homeCon.value.showFollowingPage.value = false;
                        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                      }
                      Navigator.of(context).pushReplacementNamed('/home');
                      _con.getVideos();
                    },
                  ),
                ],
              ),
              Positioned(
                right: 0,
                child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsView(),
                        ),
                      );
                    },
                    child: ValueListenableBuilder(
                        valueListenable: videoRepo.notificationsCount,
                        builder: (context, int _notificationsCount, _) {
                          return Stack(
                            children: [
                              Container(
                                width: config.App(context).appWidth(15),
                                child: SvgPicture.asset(
                                  "assets/icons/notification.svg",
                                  color: settingRepo.setting.value.iconColor,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 10,
                                child: _notificationsCount > 0
                                    ? Transform.translate(
                                        offset: Offset(-2, -6),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: settingRepo.setting.value.accentColor,
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _notificationsCount.toString(),
                                              style: TextStyle(
                                                color: settingRepo.setting.value.textColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(
                                        height: 0,
                                      ),
                              ),
                            ],
                          );
                        })),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMusicPlayerAction(index, video) {
    Video videoObj = video.videos.elementAt(index);
    return GestureDetector(
      onTap: () async {
        if (currentUser.value.token != '') {
          if (!videoRepo.homeCon.value.showFollowingPage.value) {
            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
            }
          } else {
            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
            }
          }
          videoRepo.homeCon.value.soundShowLoader.value = true;
          videoRepo.homeCon.value.soundShowLoader.notifyListeners();
          SoundData sound = await soundRepo.getSound(videoObj.soundId);
          soundRepo.selectSound(sound).whenComplete(() {
            videoRepo.homeCon.value.soundShowLoader.value = false;
            videoRepo.homeCon.value.soundShowLoader.notifyListeners();
            videoRepo.isOnRecordingPage.value = true;
            videoRepo.isOnRecordingPage.notifyListeners();
            Navigator.pushReplacementNamed(
              context,
              "/video-recorder",
            );
          });
        } else {
          if (!videoRepo.homeCon.value.showFollowingPage.value) {
            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
            }
          } else {
            if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
              videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
            }
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordLoginView(userId: 0),
            ),
          );
        }
      },
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(musicAnimationController),
        child: Container(
          margin: EdgeInsets.only(top: 10.0),
          width: 50,
          height: 50,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: settingRepo.setting.value.accentColor,
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
                child: ValueListenableBuilder(
                    valueListenable: videoRepo.homeCon.value.soundShowLoader,
                    builder: (context, bool loader, _) {
                      return (!loader)
                          ? Container(
                              height: 45.0,
                              width: 45.0,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: videoObj.soundImageUrl != ""
                                    ? CachedNetworkImage(
                                        imageUrl: videoObj.soundImageUrl,
                                        memCacheHeight: 50,
                                        memCacheWidth: 50,
                                        errorWidget: (a, b, c) {
                                          return Image.asset(
                                            "assets/images/splash.png",
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        "assets/images/splash.png",
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            )
                          : Helper.showLoaderSpinner(Colors.white);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    if (currentUser.value.token != '') {
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        setState(() {
          videoRepo.homeCon.value.likeVideo(videoRepo.homeCon.value.swiperIndex);
        });
      } else {
        setState(() {
          videoRepo.homeCon.value.likeFollowingVideo(videoRepo.homeCon.value.swiperIndex2);
        });
      }
    } else {
      videoRepo.homeCon.value.hideBottomBar.value = false;
      videoRepo.homeCon.value.hideBottomBar.notifyListeners();
      if (!videoRepo.homeCon.value.showFollowingPage.value) {
        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
        }
      } else {
        if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
        }
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordLoginView(userId: 0),
        ),
      );
    }

    return !isLiked;
  }

  Widget sidebar(index, video) {
    videoRepo.commentsLoaded.addListener(() {
      if (videoRepo.commentsLoaded.value == true) {
        Timer(Duration(seconds: 1), () => setState(() {}));
      }
    });
    Video videoObj = video.videos.elementAt(index);

    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    videoRepo.homeCon.value.encodedVideoId = stringToBase64.encode(videoRepo.homeCon.value.encKey + videoObj.videoId.toString());
    return Container(
      padding: new EdgeInsets.only(bottom: videoRepo.homeCon.value.paddingBottom - 30 > 0 ? videoRepo.homeCon.value.paddingBottom - 30 : 20),
      width: 70.0,
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Column(
          children: [
            LikeButton(
              size: 28,
              circleColor: CircleColor(start: Colors.transparent, end: Colors.transparent),
              bubblesColor: BubblesColor(
                dotPrimaryColor: videoObj.isLike ? Color(0xffee1d52) : Color(0xffffffff),
                dotSecondaryColor: videoObj.isLike ? Color(0xffee1d52) : Color(0xffffffff),
              ),
              likeBuilder: (bool isLiked) {
                return SvgPicture.asset(
                  'assets/icons/liked.svg',
                  width: 28.0,
                  color: videoObj.isLike ? Color(0xffee1d52) : settingRepo.setting.value.dashboardIconColor,
                );
              },
              onTap: onLikeButtonTapped,
            ),
            Text(
              Helper.formatter(videoObj.totalLikes.toString()),
              style: TextStyle(
                color: settingRepo.setting.value.textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 50.0,
                  width: 50.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 9, bottom: 6, left: 5.0, right: 5.0),
                    icon: SvgPicture.asset(
                      'assets/icons/comments.svg',
                      width: 28.0,
                      color: settingRepo.setting.value.iconColor,
                    ),
                    onPressed: () {
                      if (_con.bannerShowOn.indexOf("1") > -1) {
                        setState(() {
                          _con.paddingBottom = 0;
                        });
                      }
                      videoRepo.homeCon.value.hideBottomBar.value = true;
                      videoRepo.homeCon.value.hideBottomBar.notifyListeners();
                      videoRepo.homeCon.value.videoIndex = index;
                      videoRepo.homeCon.value.showBannerAd.value = false;
                      videoRepo.homeCon.value.showBannerAd.notifyListeners();
                      videoRepo.homeCon.value.pc.open();
                      videoRepo.homeCon.value.getComments(videoObj).whenComplete(() {
                        Timer(Duration(seconds: 1), () => setState(() {}));
                      });
                    },
                  ),
                ),
                Text(
                  Helper.formatter(videoObj.totalComments.toString()),
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 35.0,
                  width: 50.0,
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.only(top: 0, bottom: 0, left: 5.0, right: 5.0),
                    icon: SvgPicture.asset(
                      'assets/icons/views.svg',
                      width: 32.0,
                      color: settingRepo.setting.value.iconColor,
                    ),
                    onPressed: () {},
                  ),
                ),
                Text(
                  Helper.formatter(videoObj.totalViews.toString()),
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50.0,
              width: 50.0,
              child: ValueListenableBuilder(
                  valueListenable: videoRepo.homeCon.value.shareShowLoader,
                  builder: (context, bool shareLoader, _) {
                    return (!shareLoader)
                        ? IconButton(
                            alignment: Alignment.topCenter,
                            icon: SvgPicture.asset(
                              'assets/icons/share.svg',
                              width: 35.0,
                              color: settingRepo.setting.value.iconColor,
                            ),
                            onPressed: () async {
                              Codec<String, String> stringToBase64 = utf8.fuse(base64);
                              String vId = stringToBase64.encode(videoObj.videoId.toString());
                              Share.share('${GlobalConfiguration().get('base_url')}$vId');
                            },
                          )
                        : Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!);
                  }),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 50.0,
              width: 50.0,
              child: IconButton(
                alignment: Alignment.topCenter,
                icon: SvgPicture.asset(
                  'assets/icons/report.svg',
                  width: 32.0,
                  color: settingRepo.setting.value.iconColor,
                ),
                onPressed: () async {
                  if (currentUser.value.token != '') {
                    videoRepo.homeCon.value.showReportMsg.value = false;
                    videoRepo.homeCon.value.showReportMsg.notifyListeners();
                    reportLayout(context, videoObj);
                  } else {
                    if (!videoRepo.homeCon.value.showFollowingPage.value) {
                      if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex) != null) {
                        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                      }
                    } else {
                      if (videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2) != null) {
                        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex2).pause();
                      }
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordLoginView(userId: 0),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        (videoObj.soundId > 0)
            ? _getMusicPlayerAction(index, video)
            : SizedBox(
                height: 0,
              ),
        (videoObj.soundId > 0)
            ? Divider(
                color: Colors.transparent,
                height: 5.0,
              )
            : SizedBox(
                height: 0,
              ),
      ]),
    );
  }
}
