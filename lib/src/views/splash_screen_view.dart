import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:uni_links/uni_links.dart';

import '../controllers/splash_screen_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/global_keys.dart';
import '../models/users_model.dart';
import '../models/videos_model.dart';
import '../repositories/chat_repository.dart' as chatRepo;
import '../repositories/notification_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'chat_view.dart';
import 'user_profile_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> with WidgetsBindingObserver {
  static const platform = const MethodChannel('com.flutter.epic/epic');
  String dataShared = "No Data";
  SplashScreenController _con = SplashScreenController();
  late BuildContext context;
  double _height = 0.0;
  double _width = 0.0;
  late StreamSubscription _sub;
  double percent = 0.0;
  late Timer timer;
  ValueNotifier<bool> redirection = new ValueNotifier(true);
  bool isInternetOn = true;
  bool firstTimeLoad = false;
  // final Connectivity _connectivity = Connectivity();
  // StreamSubscription<ConnectivityResult> _connectivitySubscription;
  SplashScreenState() : super(SplashScreenController()) {
    _con = SplashScreenController();
  }

  @override
  void initState() {
    initializing();
    super.initState();
  }

  pushNotifications() {
    print("pushNotifications");
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print("pushNotifications3333 $message");
      if (message != null) {
        notificationAction(message.data);
        setState(() {
          redirection.value = false;
          redirection.notifyListeners();
        });
      }
    });
    print("pushNotifications2");
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      print("pushNotifications3");
      RemoteNotification notification = message!.notification!;
      print("djsadagdgsdgd ${message.data}");
      //AndroidNotification android = message.notification?.android;
      if (notification != null) {
        String type = message.data['type'];
        int id = int.parse(message.data['id']);
        if (type == "chat") {
          if (id != chatRepo.convId) {
            chatRepo.myConversations(1, '');
            ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
              SnackBar(
                backgroundColor: settingRepo.setting.value.buttonColor,
                action: SnackBarAction(
                  label: 'Open',
                  textColor: settingRepo.setting.value.textColor,
                  onPressed: () {
                    notificationAction(message.data);
                  },
                ),
                content: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    notification.title! + " " + notification.body!,
                    style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 16),
                  ),
                ),
                duration: Duration(seconds: 5),
                width: config.App(GlobalVariable.navState.currentContext).appWidth(90), // Width of the SnackBar.
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, // Inner padding for SnackBar content.
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
            SnackBar(
              backgroundColor: settingRepo.setting.value.buttonColor,
              action: SnackBarAction(
                label: 'Open',
                textColor: settingRepo.setting.value.textColor,
                onPressed: () {
                  notificationAction(message.data);
                },
              ),
              content: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  notification.title! + " " + notification.body!,
                  style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 16),
                ),
              ),
              duration: Duration(seconds: 5),
              width: config.App(GlobalVariable.navState.currentContext).appWidth(90), // Width of the SnackBar.
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0, // Inner padding for SnackBar content.
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      if (type == "chat") {
        if (id != chatRepo.convId) {
          chatRepo.myConversations(1, '');
          notificationAction(message.data);
        }
      } else {
        notificationAction(message.data);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('B new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      print("ConvIDS ${chatRepo.convId}  ------ ${message.data}");
      if (type == "chat") {
        if (id != chatRepo.convId) {
          print("iFFF");
          chatRepo.myConversations(1, '');
          // notificationAction(message.data);
        }
      } else {
        print("ELSEEEE");
        // notificationAction(message.data);
      }
    });

    FirebaseMessaging.onBackgroundMessage((message) {
      print('C new onMessageOpenedApp event was published!');
      String type = message.data['type'];
      int id = int.parse(message.data['id']);
      if (type == "chat") {
        if (id != chatRepo.convId) {
          chatRepo.myConversations(1, '');
          return notificationAction(message.data);
        } else {
          return notificationsList(1);
        }
      } else {
        return notificationAction(message.data);
      }
    });
  }

  notificationAction(message) {
    String type = message['type'];
    int id = int.parse(message['id']);
    if (type == "like" || type == "comment" || type == "video") {
      videoRepo.homeCon.value.userVideoObj.value.videoId = id;
      videoRepo.homeCon.value.userVideoObj.notifyListeners();
      videoRepo.homeCon.value.getVideos();
      Navigator.of(GlobalVariable.navState.currentContext!).pushNamed('/home');
      if (type == "comment") {
        Timer(Duration(seconds: 2), () {
          videoRepo.homeCon.value.hideBottomBar.value = true;
          videoRepo.homeCon.value.hideBottomBar.notifyListeners();
          videoRepo.homeCon.value.videoIndex = 0;
          videoRepo.homeCon.value.showBannerAd.value = false;
          videoRepo.homeCon.value.showBannerAd.notifyListeners();
          videoRepo.homeCon.value.pc.open();
          Video videoObj = new Video();
          videoObj.videoId = id;
          videoRepo.homeCon.value.getComments(videoObj).whenComplete(() {
            videoRepo.commentsLoaded.value = true;
            videoRepo.commentsLoaded.notifyListeners();
          });
        });
      }
    } else if (type == "follow") {
      Navigator.pushReplacement(
        GlobalVariable.navState.currentContext!,
        MaterialPageRoute(
          builder: (context) => UsersProfileView(
            userId: id,
          ),
        ),
      );
    } else if (type == "chat") {
      int userId = int.parse(message['user_id']);
      String personName = message['person_name'];
      String userDp = message['user_dp'];
      OnlineUsersModel _onlineUsersModel = new OnlineUsersModel();
      _onlineUsersModel.convId = id;
      _onlineUsersModel.id = userId;
      _onlineUsersModel.name = personName;
      _onlineUsersModel.userDp = userDp;

      Navigator.pushReplacement(
        GlobalVariable.navState.currentContext!,
        MaterialPageRoute(
          builder: (context) => ChatView(userObj: _onlineUsersModel),
        ),
      );
    }
  }

  initializing() async {
    // await initConnectivity();
    // _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    if (isInternetOn) {
      loadData();
      timer = Timer.periodic(Duration(milliseconds: 200), (_) {
        print('Percent Update');
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          setState(() {
            percent += 1;
            if (percent >= 100) {
              timer.cancel();
              // percent=0;
            }
          });
        });
      });
    }
  }
  //
  // Future<void> initConnectivity() async {
  //   firstTimeLoad = true;
  //   ConnectivityResult result = ConnectivityResult.none;
  //   try {
  //     result = await _connectivity.checkConnectivity();
  //     if (result != ConnectivityResult.wifi && result != ConnectivityResult.mobile) {
  //       _updateConnectionStatus(result);
  //       isInternetOn = false;
  //     }
  //   } on PlatformException catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Future<void> _updateConnectionStatus(ConnectivityResult result) async {
  //   switch (result) {
  //     case ConnectivityResult.wifi:
  //       print("Internet (wifi)");
  //       isInternetOn = true;
  //       if (!firstTimeLoad && isInternetOn) {
  //         videoRepo.homeCon.value.getVideos();
  //         Navigator.of(GlobalVariable.navState.currentContext).pushNamed('/home');
  //       }
  //       break;
  //     case ConnectivityResult.mobile:
  //       print("Internet (mobile)");
  //       isInternetOn = true;
  //       if (!firstTimeLoad && isInternetOn) {
  //         Navigator.pop(GlobalVariable.navState.currentContext);
  //       }
  //       break;
  //     case ConnectivityResult.none:
  //       Navigator.pushReplacement(
  //         GlobalVariable.navState.currentContext,
  //         MaterialPageRoute(
  //           builder: (context) => InternetPage(),
  //         ),
  //       );
  //       isInternetOn = false;
  //       print("Internet (closed)");
  //       break;
  //     default:
  //       Navigator.pushReplacement(
  //         GlobalVariable.navState.currentContext,
  //         MaterialPageRoute(
  //           builder: (context) => InternetPage(),
  //         ),
  //       );
  //       isInternetOn = false;
  //       print("Internet (def)");
  //       break;
  //   }
  //   firstTimeLoad = false;
  // }

  printHashKeyOnConsoleLog() async {
    try {
      await platform.invokeMethod("printHashKeyOnConsoleLog");
    } catch (e) {
      print(e);
    }
  }

  Future<void> initUniLinks() async {
    _sub = uriLinkStream.listen((Uri? uri) {
      var id;
      if (Platform.isIOS) {
        var urlList = uri.toString().split("/");
        String encodedId = urlList.last;
        Codec<String, String> stringToBase64 = utf8.fuse(base64);
        id = stringToBase64.decode(encodedId);
      } else {
        id = uri!.queryParameters['id'];
      }
      if (id != "" && id != null && redirection.value == true) {
        videoRepo.homeCon.value.userVideoObj.value.videoId = int.parse(id);
        videoRepo.homeCon.value.userVideoObj.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/home', arguments: 0);
      }
    }, onError: (err) {});
    if (!_sub.isPaused && redirection.value == true) {
      try {
        final initialLink = await getInitialLink();
        if (initialLink != null) {
          var id;
          if (Platform.isIOS) {
            var urlList = Uri.parse(initialLink).toString().split("/");
            String encodedId = urlList.last;
            Codec<String, String> stringToBase64 = utf8.fuse(base64);
            id = stringToBase64.decode(encodedId);
          } else {
            id = Uri.parse(initialLink).queryParameters['id'];
          }
          if (id != "" && id != null) {
            videoRepo.homeCon.value.userVideoObj.value.videoId = int.parse(id);
            videoRepo.homeCon.value.userVideoObj.notifyListeners();
            videoRepo.homeCon.value.getVideos();
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            videoRepo.homeCon.value.getVideos();
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          videoRepo.homeCon.value.showFollowingPage.value = false;
          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
          videoRepo.homeCon.value.getVideos();
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } on PlatformException {
        print("Error.....");
      }
    }
  }

  Future<void> addGuestUserForFCMToken() async {
    String? platformId = await PlatformDeviceId.getDeviceId;
    FirebaseMessaging.instance.getToken().then((value) {
      if (value != "" && value != null) {
        videoRepo.addGuestUser(value, platformId);
      }
    });
  }

  Future<void> updateFCMTokenForUser() async {
    FirebaseMessaging.instance.getToken().then((value) {
      if (value != "" && value != null) {
        videoRepo.updateFcmToken(value);
      }
    });
  }

  void loadData() async {
    printHashKeyOnConsoleLog();
    await settingRepo.initSettings();
    await _con.userUniqueId();
    await _con.checkIfAuthenticated();
    if (userRepo.currentUser.value == null || userRepo.currentUser.value.token == '') {
      addGuestUserForFCMToken();
    } else {
      updateFCMTokenForUser();
    }
    if (mounted) {
      pushNotifications();
      initUniLinks();
      unawaited(videoRepo.homeCon.value.preCacheVideos());
      setState(() {
        percent = 100;
        timer.cancel();
      });
    }
  }

  DateTime currentBackPressTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    setState(() => this.context = context);
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      body: WillPopScope(
        onWillPop: () {
          DateTime now = DateTime.now();
          // Navigator.pop(context);
          if (currentBackPressTime == null || now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Tap again to exit an app.");
            return Future.value(false);
          }
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          return Future.value(true);
        },
        child: Container(
          height: _height,
          width: _width,
          color: settingRepo.setting.value.bgColor,
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: settingRepo.setting.value.bgColor,
                  height: 40,
                  child: LiquidLinearProgressIndicator(
                    value: percent / 100,
                    valueColor: AlwaysStoppedAnimation(settingRepo.setting.value.accentColor!),
                    backgroundColor: settingRepo.setting.value.bgColor,
                    borderColor: settingRepo.setting.value.textColor!,
                    borderWidth: 5.0,
                    borderRadius: 12.0,
                    direction: Axis.horizontal,
                    center: Text(
                      percent.toString() + "%",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: settingRepo.setting.value.textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: settingRepo.setting.value.textColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
