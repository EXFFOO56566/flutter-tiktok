import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../widgets/AdsWidget.dart';
import '../widgets/GridViewLayout.dart';
import 'password_login_view.dart';

class UsersProfileView extends StatefulWidget {
  final int userId;
  UsersProfileView({Key? key, this.userId = 0}) : super(key: key);

  @override
  _UsersProfileViewState createState() => _UsersProfileViewState();
}

class _UsersProfileViewState extends StateMVC<UsersProfileView> {
  UserController _con = UserController();
  _UsersProfileViewState() : super(UserController()) {
    _con = UserController();
  }

  int page = 1;
  @override
  void initState() {
    _con.getUsersProfile(widget.userId, page);
    _con.getAds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: userProfile,
            builder: (context, UserProfileModel _userProfile, _) {
              return Scaffold(
                backgroundColor: settingRepo.setting.value.bgColor,
                key: _con.myProfileScaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: settingRepo.setting.value.appbarColor,
                  leading: InkWell(
                    onTap: () {
                      videoRepo.homeCon.value.showFollowingPage.value = false;
                      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                      Navigator.of(context).pushReplacementNamed('/home');
                      videoRepo.homeCon.value.getVideos();
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: settingRepo.setting.value.iconColor,
                    ),
                  ),
                  actions: [
                    currentUser.value.token != ''
                        ? PopupMenuButton<int>(
                            color: settingRepo.setting.value.bgShade,
                            icon: SvgPicture.asset(
                              'assets/icons/setting.svg',
                              width: 25.0,
                              color: settingRepo.setting.value.iconColor,
                            ),
                            onSelected: (int) {
                              _con.blockUser(widget.userId);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                height: 20,
                                value: 1,
                                child: Text(
                                  _userProfile.blocked == 'yes' ? 'Unblock' : 'Block',
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ],
                ),
                body: WillPopScope(
                  onWillPop: () async {
                    if (videoRepo.homeCon.value.showFollowingPage.value) {
                      await videoRepo.homeCon.value.getFollowingUserVideos();
                    } else {
                      await videoRepo.homeCon.value.getVideos();
                    }
                    videoRepo.homeCon.notifyListeners();
                    Navigator.of(context).pushReplacementNamed('/home');
                    return Future.value(true);
                  },
                  child: ValueListenableBuilder(
                      valueListenable: _con.showLoader,
                      builder: (context, bool showLoad, _) {
                        return ModalProgressHUD(
                          inAsyncCall: showLoad,
                          progressIndicator: Helper.showLoaderSpinner(Colors.white),
                          child: Container(
                            child: SingleChildScrollView(
                              controller: _con.scrollController1,
                              child: Column(
                                children: [
                                  ClipPath(
                                    clipper: CurveDownClipper(),
                                    child: Container(
                                      color: settingRepo.setting.value.bgShade,
                                      height: config.App(context).appHeight(28),
                                      width: config.App(context).appWidth(100),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                      return Scaffold(
                                                          backgroundColor: settingRepo.setting.value.bgColor,
                                                          appBar: PreferredSize(
                                                            preferredSize: Size.fromHeight(45.0),
                                                            child: AppBar(
                                                              leading: InkWell(
                                                                onTap: () {
                                                                  Navigator.of(context).pop();
                                                                },
                                                                child: Icon(
                                                                  Icons.arrow_back,
                                                                  size: 20,
                                                                  color: settingRepo.setting.value.iconColor,
                                                                ),
                                                              ),
                                                              iconTheme: IconThemeData(
                                                                color: settingRepo.setting.value.textColor, //change your color here
                                                              ),
                                                              // backgroundColor: Color(0xff15161a),
                                                              backgroundColor: settingRepo.setting.value.bgColor,
                                                              title: Text(
                                                                "PROFILE PICTURE",
                                                                style: TextStyle(
                                                                  fontSize: 18.0,
                                                                  fontWeight: FontWeight.w400,
                                                                  color: settingRepo.setting.value.textColor,
                                                                ),
                                                              ),
                                                              centerTitle: true,
                                                            ),
                                                          ),
                                                          body: Center(
                                                            child: PhotoView(
                                                              enableRotation: true,
                                                              imageProvider: CachedNetworkImageProvider((_userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                      _userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                  ? _userProfile.largeProfilePic
                                                                  : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png"),
                                                            ),
                                                          ));
                                                    }));
                                                  },
                                                  child: Container(
                                                    height: config.App(context).appWidth(38),
                                                    width: config.App(context).appWidth(38),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(100),
                                                      color: settingRepo.setting.value.textColor,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: _userProfile.smallProfilePic != null
                                                          ? CachedNetworkImage(
                                                              imageUrl: (_userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                      _userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                  ? _userProfile.smallProfilePic
                                                                  : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png",
                                                              placeholder: (context, url) => Helper.showLoaderSpinner(Colors.white),
                                                              fit: BoxFit.fill,
                                                              width: 50,
                                                              height: 50,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/default-user.png',
                                                              fit: BoxFit.fill,
                                                              width: 50,
                                                              height: 50,
                                                            ),
                                                    ).pLTRB(4, 4, 4, 4),
                                                  ),
                                                ),
                                                Container(
                                                  height: config.App(context).appWidth(38),
                                                  width: config.App(context).appWidth(38),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(100),
                                                    color: Colors.black12,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (currentUser.value.token == '') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => PasswordLoginView(userId: widget.userId),
                                                          ),
                                                        );
                                                      } else {
                                                        userProfile.value.followText = userProfile.value.followText == "Follow" ? "Following" : "Follow";
                                                        userProfile.notifyListeners();
                                                        _con.followUnfollowUserFromUserProfile(widget.userId);
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: settingRepo.setting.value.accentColor),
                                                      child: "${_userProfile.followText}".text.color(settingRepo.setting.value.textColor!).size(12).make().pSymmetric(h: 12, v: 6),
                                                    ),
                                                  ).centered(),
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: _userProfile.isVerified == true
                                                      ? Icon(
                                                          Icons.verified,
                                                          color: settingRepo.setting.value.accentColor,
                                                          size: 30,
                                                        ).pOnly(left: 5)
                                                      : Container(),
                                                )
                                              ],
                                            ).centered(),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                "${_userProfile.name}".text.color(settingRepo.setting.value.accentColor!).size(20).make(),
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                "(${_userProfile.username})".text.color(settingRepo.setting.value.textColor!).size(15).make(),
                                                SizedBox(
                                                  height: _userProfile.bio != "" && _userProfile.bio != null ? 8 : 0,
                                                ),
                                                "${_userProfile.bio}".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(14).make(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    color: settingRepo.setting.value.bgShade,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            "${_userProfile.totalVideos}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            "Posts".text.color(settingRepo.setting.value.textColor!).size(15).make(),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            "${_userProfile.totalVideosLike}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            "Likes".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            "${_userProfile.totalFollowings}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            "Followings".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            "${_userProfile.totalFollowers}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            "Followers".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                          ],
                                        )
                                      ],
                                    ).pSymmetric(h: 10, v: 10),
                                  ).pSymmetric(h: 10),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/videos.svg',
                                        width: 20.0,
                                        color: settingRepo.setting.value.accentColor,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      "Videos".text.color(settingRepo.setting.value.textColor!).size(16).make(),
                                    ],
                                  ).centered(),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  if (_userProfile.userVideos.length > 0)
                                    Container(
                                      child: GridView.builder(
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          primary: false,
                                          physics: BouncingScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                            height: 150,
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                          ),
                                          itemCount: _userProfile.userVideos.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final item = _userProfile.userVideos.elementAt(index);
                                            return InkWell(
                                              onTap: () {
                                                videoRepo.homeCon.value.userVideoObj.value.userId = item.userId;
                                                videoRepo.homeCon.value.userVideoObj.value.videoId = item.videoId;
                                                videoRepo.homeCon.value.userVideoObj.value.name = _userProfile.name.split(" ").first + "'s";
                                                videoRepo.homeCon.value.showFollowingPage.value = false;
                                                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                                videoRepo.homeCon.value.getVideos().whenComplete(() {
                                                  videoRepo.homeCon.notifyListeners();
                                                  Navigator.of(context).pushReplacementNamed('/home');
                                                });
                                              },
                                              child: Container(
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      width: config.App(context).appWidth(30),
                                                      child: item.videoThumbnail != ""
                                                          ? CachedNetworkImage(
                                                              imageUrl: item.videoThumbnail,
                                                              placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/noVideo.jpg',
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    Container(
                                                      width: config.App(context).appWidth(30),
                                                      height: 150,
                                                      color: Colors.black12,
                                                    ),
                                                    Positioned(
                                                      bottom: 8,
                                                      child: Container(
                                                        width: config.App(context).appWidth(30),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'assets/icons/liked.svg',
                                                                    width: 15.0,
                                                                    color: settingRepo.setting.value.iconColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  "${item.totalLikes}".text.color(settingRepo.setting.value.textColor!).size(13).make(),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    'assets/icons/views.svg',
                                                                    width: 15.0,
                                                                    color: settingRepo.setting.value.iconColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  "${Helper.formatter(item.totalViews.toString())}".text.color(settingRepo.setting.value.textColor!).size(13).make(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ).pSymmetric(h: 10)
                                  else
                                    Container(
                                      height: config.App(context).appHeight(40),
                                      child: "No video yet!".text.size(16).color(settingRepo.setting.value.textColor!.withOpacity(0.6)).center.wide.make().centered(),
                                    )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              );
            }),
        Positioned(
          bottom: Platform.isAndroid ? 0 : 15,
          child: ValueListenableBuilder(
            valueListenable: _con.showBannerAd,
            builder: (context, bool adLoader, _) {
              return adLoader ? Center(child: Container(width: MediaQuery.of(context).size.width, child: BannerAdWidget(AdSize.banner))) : Container();
            },
          ),
        ),
      ],
    );
  }
}

class CurveDownClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 40;
    Offset controlPoint = Offset(size.width / 2, size.height + curveHeight);
    Offset endPoint = Offset(size.width, size.height - curveHeight);

    Path path = Path()
      ..lineTo(0, size.height - curveHeight)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
