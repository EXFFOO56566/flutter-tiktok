import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:velocity_x/velocity_x.dart";

import '../helpers/global_keys.dart';
import '../helpers/helper.dart';
import '../models/gender.dart';
import '../models/login_model.dart';
import '../models/videos_model.dart';
import '../repositories/hash_repository.dart' as hashRepo;
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/complete_profile_view.dart';
import '../views/password_login_view.dart';
import '../views/reset_forgot_password_view.dart';
import '../views/verify_otp_screen.dart';
import 'dashboard_controller.dart';
import 'following_controller.dart';

class UserController extends ControllerMVC {
  List<Video> users = <Video>[];
  GlobalKey<ScaffoldState> userScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> otpScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> completeProfileScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> forgotPasswordScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> resetForgotPasswordScaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> editVideoScaffoldKey = GlobalKey<ScaffoldState>();

  ValueNotifier<bool> updateViewState = new ValueNotifier(false);
  ValueNotifier<int> userIdValue = new ValueNotifier(0);
  GlobalKey<FormState> formKey = new GlobalKey();
  GlobalKey<FormState> otpFormKey = new GlobalKey();
  GlobalKey<FormState> registerFormKey = new GlobalKey(debugLabel: "register");
  GlobalKey<FormState> completeProfileFormKey = new GlobalKey(debugLabel: "completeProfile");
  GlobalKey<FormState> resetForgotPassword = new GlobalKey(debugLabel: "resetForgotPassword");
  GlobalKey<FormState> editVideoFormKey = new GlobalKey(debugLabel: "editVideoForm");
  ValueNotifier<bool> showBannerAd = new ValueNotifier(false);
  Map userProfile = {};
  OverlayEntry loader = new OverlayEntry(builder: (context) {
    return Container();
  });
  DashboardController homeCon = DashboardController();
  String timezone = 'Unknown';
  bool showUserLoader = false;
  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  int page = 1;
  int followUserId = 0;
  String searchKeyword = '';
  bool showLoadMoreUsers = true;
  String largeProfilePic = '';
  String smallProfilePic = '';
  LoginData completeProfile = LoginData.fromJson({});
  int curIndex = 0;
  String otp = "";
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  bool videosLoader = false;
  bool showLoadMore = true;
  var searchController = TextEditingController();
  bool followUnfollowLoader = false;
  String followText = "Follow";
  ValueNotifier<int> countTimer = new ValueNotifier(60);
  bool bHideTimer = false;
  ValueNotifier<bool> reload = new ValueNotifier(false);
  String iosUuId = "";
  String iosEmail = "";
  late InterstitialAd _interstitialAd;
  late RewardedAd myRewarded;
  String appId = '';
  String bannerUnitId = '';
  String screenUnitId = '';
  String videoUnitId = '';
  String bannerShowOn = '';
  String interstitialShowOn = '';
  String videoShowOn = '';
  String fullName = "";
  String email = "";
  String userName = "";
  String password = "";
  String confirmPassword = "";
  PanelController pc = new PanelController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController profileUsernameController = TextEditingController();
  TextEditingController profileEmailController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController conDob = new TextEditingController();
  TextEditingController otpController = new TextEditingController();

  String url = '${GlobalConfiguration().get('node_url')}';
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    "https://www.googleapis.com/auth/userinfo.profile",
  ]);
  bool showSendOtp = false;
  ScrollController scrollController = new ScrollController();
  String profileUsername = '';
  DateTime profileDOB = DateTime.now();
  String profileDOBString = '';
  final picker = ImagePicker();
  File selectedDp = File("");
  String loginType = '';
  List<Gender> gender = <Gender>[const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')];
  String selectedGender = "";
  bool visibleSocialButtons = true;
  GlobalKey<ScaffoldState> myProfileScaffoldKey = GlobalKey<ScaffoldState>();
  String description = "";
  int privacy = 0;

  @override
  void initState() {
    userScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_loginPage');
    otpScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_otpPage');
    completeProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_completeProfilePage');
    forgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_ForgotPasswordPage');
    resetForgotPasswordScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_resetForgotPasswordScaffoldPage');
    myProfileScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_myProfileScaffoldPage');
    editVideoScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editVideoScaffoldPage');
    scrollController = new ScrollController();
    initPlatformState();
    super.initState();
  }

  String validDob(String year, String month, String day) {
    if (day.length == 1) {
      day = "0" + day;
    }
    if (month.length == 1) {
      month = "0" + month;
    }
    return year + "-" + month + "-" + day;
  }

  Future<void> initPlatformState() async {
    String timezone;
    try {
      timezone = await FlutterNativeTimezone.getLocalTimezone();
    } on PlatformException {
      timezone = 'Failed to get the timezone.';
    }
    setState(() {
      timezone = timezone;
    });
  }

  Future<void> getAds() async {
    appId = Platform.isAndroid ? hashRepo.adsData.value['android_app_id'] : hashRepo.adsData.value['ios_app_id'];
    bannerUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_banner_app_id'] : hashRepo.adsData.value['ios_banner_app_id'];
    screenUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_interstitial_app_id'] : hashRepo.adsData.value['ios_interstitial_app_id'];
    videoUnitId = Platform.isAndroid ? hashRepo.adsData.value['android_video_app_id'] : hashRepo.adsData.value['ios_video_app_id'];
    bannerShowOn = hashRepo.adsData.value['banner_show_on'];
    interstitialShowOn = hashRepo.adsData.value['interstitial_show_on'];
    videoShowOn = hashRepo.adsData.value['video_show_on'];

    if (appId != "") {
      MobileAds.instance.initialize().then((value) async {
        if (bannerShowOn.indexOf("2") > -1) {
          showBannerAd.value = true;
          showBannerAd.notifyListeners();
        }

        if (interstitialShowOn.indexOf("2") > -1) {
          createInterstitialAd(screenUnitId);
        }

        if (videoShowOn.indexOf("2") > -1) {
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
    ;
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
            // createRewardedAd(adUnitId);
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

  getUuId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      iosUuId = pref.getString("ios_uuid") == null ? "" : pref.getString("ios_uuid").toString();
      iosEmail = pref.getString("ios_email") == null ? "" : pref.getString("ios_email").toString();
    });
    print("iosUuId $iosUuId");
    print("iosEmail $iosEmail");
  }

  signInWithApple() async {
    showLoader.value = true;
    showLoader.notifyListeners();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId: 'com.leuke.applogin',
          redirectUri: Uri.parse(
            'https://smiling-abrupt-screw.glitch.me/callbacks/sign_in_with_apple',
          ),
        ),
      );

      var firstName = credential.givenName;
      var lastName = credential.familyName;
      var email = credential.email;
      var userDp = "";
      var gender = "";
      var dob = "";
      var mobile = "";
      var country = "";
      if (iosUuId == "") {
        if (Platform.isIOS) {
          String uuid;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          uuid = credential.userIdentifier!; //UUID for iOS
          print("uuid $uuid");
          final Map<String, String> userInfo = {
            'first_name': firstName != null ? firstName : "",
            'last_name': lastName != null ? lastName : "",
            'email': email != null ? email : "",
            'mobile': mobile != null ? mobile : "",
            'gender': gender != null ? gender : "",
            'user_dp': userDp != null ? userDp : "",
            'dob': dob != null ? dob : "",
            'country': country != null ? country : "",
            'languages': "",
            'player_id': "",
            'time_zone': timezone,
            'login_type': "A",
            'ios_email': email!,
            'ios_uuid': uuid,
          };
          userRepo
              .socialLogin(
            userInfo,
            timezone,
            'A',
          )
              .then((value) {
            if (value != null) {
              if (value) {
                Helper.hideLoader(loader);
                videoRepo.homeCon.value.showFollowingPage.value = false;
                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
                videoRepo.homeCon.value.getVideos();
              } else {
                if (userRepo.errorString.value != "") {
                  Helper.hideLoader(loader);
                  ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text(userRepo.errorString.value)));
                }
              }
            }
          }).catchError((e) {
            print(e.toString());
            Helper.hideLoader(loader);
            ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text('Sign In with Apple failed!')));
          });
        }
      } else {
        final Map<String, String> userInfo = {
          'first_name': firstName != null ? firstName : "",
          'last_name': lastName != null ? lastName : "",
          'email': email != null ? email : "",
          'mobile': mobile != null ? mobile : "",
          'gender': gender != null ? gender : "",
          'user_dp': userDp != null ? userDp : "",
          'dob': dob != null ? dob : "",
          'country': country != null ? country : "",
          'languages': "",
          'player_id': "",
          'time_zone': timezone,
          'login_type': "A",
          'ios_uuid': iosUuId,
          'ios_email': iosEmail,
        };
        userRepo
            .socialLogin(
          userInfo,
          timezone,
          'A',
        )
            .then((value) {
          if (value != null) {
            if (value) {
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
              videoRepo.homeCon.value.getVideos();
            } else {
              if (userRepo.errorString.value != "") {
                Helper.hideLoader(loader);
                ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
                  content: Text(userRepo.errorString.value),
                ));
              }
            }
          }
        }).catchError((e) {
          Helper.hideLoader(loader);
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text('Sign In with Apple failed!')));
        });
      }

      showLoader.value = false;
      showLoader.notifyListeners();
    } catch (e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (e.toString().contains("Unsupported platform")) {
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
          Helper.toast("Unsupported platform iOS version. Please try some other login method.", Colors.redAccent),
        );
      } else {
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(
          Helper.toast(
            e.toString() + " Please try Again with some other method.",
            Colors.redAccent,
          ),
        );
      }
    }
  }

  loginWithFB() async {
    final LoginResult fBResult = await FacebookAuth.instance.login();
    switch (fBResult.status) {
      case LoginStatus.success:
        final AccessToken accessToken = fBResult.accessToken!;
        // OverlayEntry loader = Helper.overlayLoader(GlobalVariable.navState.currentContext);
        // Overlay.of(GlobalVariable.navState.currentContext).insert(loader);
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,email,first_name,last_name,picture.width(720).height(720),birthday,gender,languages,location{location}&access_token=${accessToken.token}'));
        final profile = jsonDecode(graphResponse.body);
        userRepo.socialLogin(profile, timezone, 'FB').then((value) async {
          if (value != null) {
            if (value) {
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
              videoRepo.homeCon.value.getVideos();
            } else {
              if (userRepo.errorString.value != "") {
                Helper.hideLoader(loader);
                ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text(userRepo.errorString.value)));
              }
            }
          }
        }).catchError((e) {
          print(e);
          Helper.hideLoader(loader);
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Facebook login failed!")));
        });
        break;
      case LoginStatus.cancelled:
        break;
      case LoginStatus.failed:
        break;
    }
  }

  loginWithGoogle() async {
    await googleSignIn.signIn();
    // OverlayEntry loader = Helper.overlayLoader(GlobalVariable.navState.currentContext!);
    // Overlay.of(GlobalVariable.navState.currentContext!)!.insert(loader);

    if (googleSignIn.currentUser != null) {
      await getGoogleInfo(googleSignIn).then((profile) {
        userRepo.socialLogin(profile, timezone, 'G').then((value) {
          if (value != null) {
            if (value) {
              Helper.hideLoader(loader);
              videoRepo.homeCon.value.showFollowingPage.value = false;
              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
              Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
              videoRepo.homeCon.value.getVideos();
            } else {
              Helper.hideLoader(loader);
              if (userRepo.errorString.value != "") {
                Helper.hideLoader(loader);
                ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text(userRepo.errorString.value)));
              }
            }
          }
        }).catchError((e) {
          Helper.hideLoader(loader);
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Google login failed!")));
        });
      });
    } else {
      Helper.hideLoader(loader);
    }
  }

  Future getGoogleInfo(googleSignIn) async {
    List name = googleSignIn.currentUser.displayName.split(' ');
    final Map<String, String> userInfo = {
      'first_name': name[0],
      'last_name': name[name.length - 1],
      'email': googleSignIn.currentUser.email,
      'user_dp': googleSignIn.currentUser.photoUrl != null ? googleSignIn.currentUser.photoUrl.replaceAll('=s96-c', '=s512-c') : "",
      'time_zone': timezone,
      'login_type': "G",
    };
    return userInfo;
  }

  Future getUsers(page) async {
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController1 = new ScrollController();
    userRepo.getUsers(page, searchKeyword).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (value.videos.length == value.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (value.videos.length != value.totalVideos && showLoadMore) {
            page = page + 1;
            getUsers(page);
          }
        }
      });
    });
  }

  Future<void> followUnfollowUser(userId, index) async {
    FollowingController followCon = FollowingController();
    setState(() {
      followUserId = userId;
    });
    showLoader.value = true;
    showLoader.notifyListeners();

    userRepo.followUnfollowUser(userId).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      var response = json.decode(value);
      if (response['status'] == 'success') {
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
        followCon.friendsList(1);
        setState(() {
          userRepo.usersData.value.videos.elementAt(index).followText = response['followText'];
          userRepo.usersData.notifyListeners();
        });
      }
    }).catchError((e) {
      print("Follow Error $e");
      showLoader.value = false;
      showLoader.notifyListeners();
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("There are som error")));
    });
  }

  Future<void> followUnfollowUserFromUserProfile(userId) async {
    // setState(() {});
    followUnfollowLoader = true;
    userRepo.followUnfollowUser(userId).then((value) {
      followUnfollowLoader = false;
      var response = json.decode(value);
      print(response);
      if (response['status'] == 'success') {
        videoRepo.homeCon.value.loadMoreUpdateView.value = true;
        videoRepo.homeCon.value.loadMoreUpdateView.notifyListeners();
        for (var item in videoRepo.videosData.value.videos) {
          if (userId == item.userId) {
            item.isFollowing = response['followText'] == 'Follow' ? 0 : 1;
          }
        }
        videoRepo.homeCon.value.getFollowingUserVideos();
        videoRepo.homeCon.notifyListeners();
        userRepo.userProfile.value.followText = response['followText'];
        userRepo.userProfile.value.totalFollowers = response['totalFollowers'].toString();
        userRepo.userProfile.notifyListeners();
      }
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print("Follow Error $e");
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("There are som error")));
    });
  }

  Future getUsersProfile(userId, page) async {
    print("getUsersProfile page $page");
    homeCon = videoRepo.homeCon.value;
    if (page == 1) {
      showLoader.value = true;
      showLoader.notifyListeners();
    }

    scrollController1 = new ScrollController();
    userRepo.getUserProfile(userId, page).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.userVideos.length == userValue.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (userValue.userVideos.length != userValue.totalVideos && showLoadMore) {
            page = page + 1;
            getUsersProfile(userId, page);
          }
        }
      });
    });
  }

  launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getMyProfile(page, [bool showLoaderOp = true]) async {
    homeCon = videoRepo.homeCon.value;
    if (showLoaderOp) {
      showLoader.value = true;
      showLoader.notifyListeners();
    }
    videosLoader = true;
    scrollController1 = new ScrollController();
    userRepo.getMyProfile(page).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      videosLoader = false;
      if (userValue.userVideos.length == userValue.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (userValue.userVideos.length != userValue.totalVideos && showLoadMore) {
            page = page + 1;
            getMyProfile(page);
          }
        }
      });
    });
  }

  Future getLikedVideos(page) async {
    homeCon = videoRepo.homeCon.value;
    showLoadMore = true;
    videosLoader = true;
    scrollController1 = new ScrollController();
    userRepo.getLikedVideos(page).then((userValue) {
      videosLoader = false;
      if (userValue.userVideos.length == userValue.totalVideos) {
        showLoadMore = false;
      }
      scrollController1.addListener(() {
        if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
          if (userValue.userVideos.length != userValue.totalVideos && showLoadMore) {
            page = page + 1;
            getLikedVideos(page);
          }
        }
      });
    });
  }

  Future<void> refreshUserProfile() async {
    if (userIdValue.value > 0) {
      await getUsersProfile(userIdValue.value, 1);
    }
    return Future.value();
  }

  Future<void> refreshMyProfile() async {
    await getMyProfile(1);
    return Future.value();
  }

  blockUser(userId) async {
    homeCon = videoRepo.homeCon.value;
    showLoader.value = true;
    showLoader.notifyListeners();
    userRepo.blockUser(userId).then((value) async {
      showLoader.value = false;
      showLoader.notifyListeners();
      videoRepo.homeCon.value.showFollowingPage.value = false;
      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
      Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
      videoRepo.homeCon.value.getVideos();
      var response = json.decode(value);
      if (response['status'] == 'success') {
        userRepo.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userRepo.userProfile.notifyListeners();
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text(response['msg'])));
        videoRepo.homeCon.value.getVideos().whenComplete(() {
          videoRepo.homeCon.notifyListeners();
          Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
        });
      } else {
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("There are some error")));
      }
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        content: Wrap(
      children: [
        Align(
            alignment: Alignment.center,
            child: Text(
              "Loading...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'RockWellStd',
              ),
            )),
      ],
    ));
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  validateField(String value, String field) {
    Pattern pattern = r'^[0-9A-Za-z.\-_]*$';
    RegExp regex = new RegExp(pattern.toString());

    if (value.length == 0) {
      return "$field is required!";
    } else if (field == "Confirm Password" && value != password) {
      return "Confirm Password doesn't match!";
    } else if (field == "Username" && !regex.hasMatch(value)) {
      return "It must contain only _ . and alphanumeric";
    } else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value!);
    if (value.length == 0) {
      return "Email field is required!";
    } else if (!emailValid) {
      return "Email field is not valid!";
    } else {
      return null;
    }
  }

  Future<bool> register() async {
    if (completeProfileFormKey.currentState!.validate()) {
      showLoader.value = true;
      showLoader.notifyListeners();

      List name = fullName.split(' ');
      final Map<String, String> userProfile = {
        'fname': name[0],
        'lname': name[name.length - 1],
        'email': email,
        'password': password,
        'username': userName,
        'time_zone': timezone,
        'gender': selectedGender,
        'dob': profileDOBString,
        'login_type': "O",
        'profile_pic_file': selectedDp != null ? selectedDp.path : "",
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var value = await userRepo.register(userProfile);
      showLoader.value = false;
      showLoader.notifyListeners();
      if (value != null) {
        showLoader.value = false;
        showLoader.notifyListeners();
        var response = json.decode(value);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          showAlertDialog(errorTitle: "Error Registering User", errorString: msg, fromLogin: false);
          return Future.value(false);
        } else {
          var content = json.decode(json.encode(response['content']));
          prefs.setString("otp_user_id", content['user_id'].toString());
          prefs.setString("otp_app_token", content['app_token']);
          Navigator.push(
            completeProfileFormKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => VerifyOTPView(),
            ),
          );
          return Future.value(true);
        }
      } else {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<bool> registerSocial() async {
    if (completeProfileFormKey.currentState!.validate()) {
      completeProfileFormKey.currentState!.save();
      showLoader.value = true;
      showLoader.notifyListeners();
      List name = completeProfile.name.split(' ');
      final Map<String, String> userProfile = {
        'fname': name[0],
        'lname': name[name.length - 1],
        'email': completeProfile.email == '' || completeProfile.email == null ? email : completeProfile.email,
        'password': password,
        'confirm_password': confirmPassword,
        'username': userName,
        'gender': selectedGender,
        'time_zone': timezone,
        'login_type': loginType,
        'profile_pic': completeProfile.userDP,
      };
      if (selectedDp != null) {
        userProfile['profile_pic_file'] = selectedDp.path;
      } else {
        userProfile['profile_pic'] = completeProfile.userDP;
      }
      userRepo.socialRegister(userProfile).then((value) async {
        showLoader.value = false;
        showLoader.notifyListeners();
        if (value != null) {
          showLoader.value = false;
          showLoader.notifyListeners();
          var response = json.decode(value);
          if (response['status'] != 'success') {
            String msg = response['msg'];
            showAlertDialog(errorTitle: "Error Registering User", errorString: msg, fromLogin: false);
            return Future.value(false);
          } else {
            userRepo.setCurrentUser(value);
            userRepo.currentUser.value = LoginData.fromJson(json.decode(value)['content']);
            userRepo.currentUser.value.auth = true;
            userRepo.currentUser.notifyListeners();
            videoRepo.homeCon.value.showFollowingPage.value = false;
            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
            Navigator.of(completeProfileScaffoldKey.currentContext!).pushReplacementNamed('/home');
            videoRepo.homeCon.value.getVideos();
          }
        }
      });
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  Future<String> login() async {
    if (registerFormKey.currentState!.validate()) {
      registerFormKey.currentState!.save();
      showLoader.value = true;
      showLoader.notifyListeners();
      final Map<String, String> userProfile = {
        'email': email,
        'password': password,
        'time_zone': timezone,
        'login_type': "O",
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var value = await userRepo.login(userProfile);
      showLoader.value = false;
      showLoader.notifyListeners();
      print("value $value");
      var resp = json.encode(json.decode(value));
      var response = json.decode(resp);

      if (response["status"] != true) {
        showLoader.value = false;
        showLoader.notifyListeners();
        if (response['status'] == 'email_not_verified') {
          var content = json.decode(json.encode(response['content']));
          prefs.setString("otp_user_id", content['user_id'].toString());
          prefs.setString("otp_app_token", content['app_token']);
          String msg = response['msg'];
          setState(() {
            showSendOtp = true;
          });
          showAlertDialog(errorTitle: 'Error Logging OTP', errorString: msg, fromLogin: true, showSendOtp: true);
          return "Otp";
        } else if (response['content'] != null) {
          userRepo.setCurrentUser(value);
          userRepo.updateFCMTokenForUser();
          userRepo.currentUser.value = LoginData.fromJson(response['content']);
          userRepo.currentUser.value.auth = true;
          userRepo.currentUser.notifyListeners();
          videoRepo.homeCon.value.showFollowingPage.value = false;
          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
          Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
          videoRepo.homeCon.value.getVideos();
          return "Done";
        } else {
          String msg = response['msg'];
          showAlertDialog(errorTitle: 'Error', errorString: msg, fromLogin: true, showSendOtp: false);
          return "Error";
        }
      } else {
        return "Error";
      }
    } else {
      return "Error";
    }
  }

  verifyOtp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("otp_user_id")!;
    String userToken = prefs.getString("otp_app_token")!;
    showLoader.value = true;
    showLoader.notifyListeners();
    final Map<String, String> data = {
      'user_id': userId,
      'app_token': userToken,
      'otp': otp,
    };
    var value = await userRepo.verifyOtp(data);
    showLoader.value = false;
    showLoader.notifyListeners();
    var resp = json.encode(json.decode(value));
    showLoader.value = false;
    showLoader.notifyListeners();
    var response = json.decode(resp);
    if (response['status'] != 'success') {
      String msg = response['msg'];
      showAlertDialog(errorTitle: 'Error Verifying OTP', errorString: msg, fromLogin: false);
    } else {
      userRepo.setCurrentUser(value);
      userRepo.updateFCMTokenForUser();
      print("response['content'] ${response['content']}");
      userRepo.currentUser.value = LoginData.fromJson(response['content']);
      userRepo.currentUser.notifyListeners();
      videoRepo.homeCon.value.showFollowingPage.value = false;
      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
      Navigator.of(GlobalVariable.navState.currentContext!).pushReplacementNamed('/home');
      videoRepo.homeCon.value.getVideos();
    }
  }

  resendOtp({verifyPage}) async {
    if (verifyPage != null) {
      startTimer();

      bHideTimer = true;
      reload.value = true;
      reload.notifyListeners();
      countTimer.value = 60;
      countTimer.notifyListeners();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("otp_user_id")!;
    String userToken = prefs.getString("otp_app_token")!;
    showLoader.value = true;
    showLoader.notifyListeners();

    final Map<String, String> data = {
      'user_id': userId,
      'app_token': userToken,
    };
    userRepo.resendOtp(data).then((value) async {
      showLoader.value = false;
      showLoader.notifyListeners();
      var response = json.decode(value);
      if (response['status'] != 'success') {
        String msg = response['msg'];
        setState(() {
          showSendOtp = true;
        });
        showAlertDialog(errorTitle: 'Error Verifying OTP', errorString: msg, fromLogin: false, showSendOtp: true);
      } else {
        if (verifyPage == null) {
          Navigator.of(GlobalVariable.navState.currentContext!).pushNamed(
            '/verify-otp-screen',
          );
        }
      }
    });
  }

  showAlertDialog({errorTitle, errorString, fromLogin, showSendOtp = false}) {
    AwesomeDialog(
      dialogBackgroundColor: settingRepo.setting.value.buttonColor,
      context: GlobalVariable.navState.currentContext!,
      animType: AnimType.SCALE,
      dialogType: DialogType.WARNING,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: settingRepo.setting.value.textColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            showSendOtp
                ? Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!);
                            Navigator.pop(GlobalVariable.navState.currentContext!);
                            setState(() {
                              showSendOtp = false;
                            });
                            if (fromLogin) {
                              resendOtp();
                            } else {
                              resendOtp(verifyPage: true);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: settingRepo.setting.value.accentColor,
                            ),
                            child: "Resend OTP".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: settingRepo.setting.value.accentColor,
                            ),
                            child: "Ok".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                          ),
                        ),
                      ),
                    ],
                  )
                : InkWell(
                    onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Ok".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  )
          ],
        ),
      ),
    )..show();
  }

  startTimer() {
    Timer.periodic(new Duration(seconds: 1), (timer) {
      // setState(() {
      countTimer.value--;
      countTimer.notifyListeners();
      if (countTimer.value == 0) {
        bHideTimer = false;

        reload.value = true;
        reload.notifyListeners();
      }
      if (countTimer.value <= 0) timer.cancel();
      // });
    });
  }

  getLoginPageData() {
    showLoader.value = true;
    showLoader.notifyListeners();
    loginRepo.fetchLoginPageInfo().then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
    });
  }

  Future ifEmailExists(String email) async {
    showLoader.value = true;
    showLoader.notifyListeners();
    print("ifEmailExists $email");
    userRepo.ifEmailExists(email).then((value) {
      if (value != null) {
        showLoader.value = false;
        showLoader.notifyListeners();
        if (value == true) {
          AwesomeDialog(
            dialogBackgroundColor: settingRepo.setting.value.buttonColor,
            context: GlobalVariable.navState.currentContext!,
            animType: AnimType.SCALE,
            dialogType: DialogType.WARNING,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Email Already Exists',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: settingRepo.setting.value.textColor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Use another email to register or login using existing email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Ok".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  )
                ],
              ),
            ),
          )..show();
          return false;
        } else {
          print("email :$email");
          Navigator.push(
            userScaffoldKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => CompleteProfileView(
                loginType: "O",
                email: email,
                fullName: fullName,
              ),
            ),
          );
          return true;
        }
      } else {
        return false;
      }
    }).catchError((e) {
      return false;
    });
  }

  getImageOption(bool isCamera) async {
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          selectedDp = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      setState(() {
        if (pickedFile != null) {
          selectedDp = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  sendPasswordResetOTP() async {
    if (formKey.currentState!.validate()) {
      showLoader.value = true;
      showLoader.notifyListeners();
      formKey.currentState!.save();
      final Map<String, String> data = {
        'email': email,
      };
      userRepo.forgotPassword(data).then((value) async {
        showLoader.value = false;
        showLoader.notifyListeners();
        var resp = json.encode(json.decode(value));

        var response = json.decode(resp);
        if (response['status'] != 'success') {
          AwesomeDialog(
            dialogBackgroundColor: settingRepo.setting.value.buttonColor,
            context: GlobalVariable.navState.currentContext!,
            animType: AnimType.SCALE,
            dialogType: DialogType.INFO,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Sorry this email account does not exists.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Ok".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  )
                ],
              ),
            ),
          )..show();
        } else {
          FocusScope.of(forgotPasswordScaffoldKey.currentContext!).requestFocus(FocusNode());
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("An OTP is sent to your email please check your email.")));
          await Future.delayed(
            Duration(seconds: 2),
          );
          Navigator.of(forgotPasswordScaffoldKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ResetForgotPasswordView(
                email: email,
              ),
            ),
          );
        }
      });
    }
  }

  updateForgotPassword() async {
    if (resetForgotPassword.currentState!.validate()) {
      showLoader.value = true;
      showLoader.notifyListeners();
      resetForgotPassword.currentState!.save();
      final Map<String, String> data = {
        'email': email,
        'otp': otp,
        'password': password,
        'confirm_password': confirmPassword,
      };
      userRepo.updateForgotPassword(data).then((value) async {
        showLoader.value = false;
        showLoader.notifyListeners();

        var resp = json.encode(json.decode(value));

        var response = json.decode(resp);
        if (response['status'] != 'success') {
          AwesomeDialog(
            dialogBackgroundColor: settingRepo.setting.value.buttonColor,
            context: GlobalVariable.navState.currentContext!,
            animType: AnimType.SCALE,
            dialogType: DialogType.INFO,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'Some error to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Ok".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  )
                ],
              ),
            ),
          )..show();
        } else {
          FocusScope.of(resetForgotPasswordScaffoldKey.currentContext!).requestFocus(FocusNode());
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Password updated Successfully")));
          await Future.delayed(
            Duration(seconds: 2),
          );
          Navigator.of(resetForgotPasswordScaffoldKey.currentContext!).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PasswordLoginView(),
            ),
          );
        }
      });
    }
  }

  deleteVideo(videoId) async {
    videoRepo.deleteVideo(videoId).then((value) async {
      if (value != null) {
        showLoader.value = false;
        showLoader.notifyListeners();
        var response = json.decode(value);
        if (response['status'] != 'success') {
          String msg = response['msg'];
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Video deleted Successfully")));
        } else {
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("There's some error deleting video")));
        }
      }
    });
  }

  showDeleteAlert(errorTitle, errorString, videoId) {
    AwesomeDialog(
      dialogBackgroundColor: settingRepo.setting.value.buttonColor,
      context: GlobalVariable.navState.currentContext!,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: settingRepo.setting.value.textColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  errorString,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: settingRepo.setting.value.textColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(GlobalVariable.navState.currentContext!),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "No".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      deleteVideo(videoId);
                      Navigator.of(GlobalVariable.navState.currentContext!, rootNavigator: true).pop("Discard");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Yes".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )..show();
  }

  void editVideo(videoId, videoDescription, privacy) {
    showLoader.value = true;
    showLoader.notifyListeners();
    videoRepo.editVideo(videoId, videoDescription, privacy).then((value) async {
      if (value != null) {
        showLoader.value = false;
        showLoader.notifyListeners();
        if (value == "Yes") {
          ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Video Updated Successfully")));
          await Future.delayed(
            Duration(seconds: 1),
          );
          Navigator.of(editVideoScaffoldKey.currentContext!).pop();
        }
      }
    });
  }
}
