import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/user_profile_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;
import '../views/edit_profile_view.dart';
import '../views/followings.dart';
import '../views/verify_profile.dart';
import '../widgets/GridViewLayout.dart';
import 'blocked_users.dart';
import 'change_password_view.dart';
import 'chat_setting_view.dart';
import 'edit_video.dart';
import 'notification_settings_view.dart';

class MyProfileView extends StatefulWidget {
  MyProfileView({Key? key}) : super(key: key);
  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends StateMVC<MyProfileView> {
  UserController _con = UserController();
  int page = 1;
  _MyProfileViewState() : super(UserController()) {
    _con = UserController();
  }
  int activeTab = 1;
  @override
  void initState() {
    _con.getMyProfile(page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return ValueListenableBuilder(
        valueListenable: myProfile,
        builder: (context, UserProfileModel userProfile, _) {
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
                IconButton(
                  onPressed: () async {
                    _con.myProfileScaffoldKey.currentState!.openDrawer();
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/setting.svg',
                    width: 25.0,
                    color: settingRepo.setting.value.iconColor,
                  ),
                ),
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
                      child: !showLoad
                          ? Container(
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
                                                                    Icons.arrow_back_ios,
                                                                    size: 20,
                                                                    color: settingRepo.setting.value.iconColor,
                                                                  ),
                                                                ),
                                                                iconTheme: IconThemeData(
                                                                  color: Colors.white, //change your color here
                                                                ),
                                                                // backgroundColor: Color(0xff15161a),
                                                                backgroundColor: settingRepo.setting.value.bgColor,
                                                                title: Text(
                                                                  "PROFILE PICTURE",
                                                                  style: TextStyle(
                                                                    fontSize: 18.0,
                                                                    fontWeight: FontWeight.w400,
                                                                    color: settingRepo.setting.value.headingColor,
                                                                  ),
                                                                ),
                                                                centerTitle: true,
                                                              ),
                                                            ),
                                                            body: Center(
                                                              child: PhotoView(
                                                                enableRotation: true,
                                                                imageProvider: CachedNetworkImageProvider((userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                        userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                    ? userProfile.largeProfilePic
                                                                    : '${GlobalConfiguration().getString('base_url')}' + "default/user-dummy-pic.png"),
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
                                                        child: userProfile.smallProfilePic != null
                                                            ? CachedNetworkImage(
                                                                imageUrl: (userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                        userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                    ? userProfile.smallProfilePic
                                                                    : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png",
                                                                placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                                fit: BoxFit.fill,
                                                                width: 50,
                                                                height: 50,
                                                              )
                                                            : Image.asset('assets/images/default-user.png'),
                                                      ).pLTRB(4, 4, 4, 4),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: config.App(context).appWidth(38),
                                                    width: config.App(context).appWidth(38),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(100),
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => EditProfileView(),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: settingRepo.setting.value.accentColor),
                                                        child: "Edit Profile".text.color(settingRepo.setting.value.textColor!).size(12).make().pSymmetric(h: 12, v: 6),
                                                      ),
                                                    ).centered(),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: userProfile.isVerified == true
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
                                                  "${userProfile.name}".text.color(settingRepo.setting.value.accentColor!).size(20).make(),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  "(${userProfile.username})".text.color(settingRepo.setting.value.textColor!).size(15).make(),
                                                  SizedBox(
                                                    height: userProfile.bio != "" && userProfile.bio != null ? 8 : 0,
                                                  ),
                                                  "${userProfile.bio}".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(14).make(),
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
                                              "${userProfile.totalVideos}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              "Posts".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              "${userProfile.totalVideosLike}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              "Likes".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (userProfile.totalFollowings != '0') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => FollowingsView(userId: userRepo.currentUser.value.userId, type: 0),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                "${userProfile.totalFollowings}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                "Followings".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (userProfile.totalFollowers != '0') {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => FollowingsView(userId: userRepo.currentUser.value.userId, type: 1),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Column(
                                              children: [
                                                "${userProfile.totalFollowers}".text.color(settingRepo.setting.value.textColor!).size(18).make(),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                "Followers".text.color(settingRepo.setting.value.textColor!.withOpacity(0.5)).size(15).make(),
                                              ],
                                            ),
                                          )
                                        ],
                                      ).pSymmetric(h: 10, v: 10),
                                    ).pSymmetric(h: 10),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      child: activeTab == 1
                                          ? Stack(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Transform.translate(
                                                      offset: Offset(5, 0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: settingRepo.setting.value.accentColor,
                                                          borderRadius: BorderRadius.circular(100),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: settingRepo.setting.value.bgShade!,
                                                              blurRadius: 2.0,
                                                              offset: Offset(2, 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/videos.svg',
                                                          width: 20.0,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ).pSymmetric(h: 30, v: 5),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          activeTab = 2;
                                                          page = 1;
                                                        });
                                                        _con.getLikedVideos(page);
                                                      },
                                                      child: Transform.translate(
                                                        offset: Offset(-8, 0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: settingRepo.setting.value.bgShade,
                                                            borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(100),
                                                              bottomRight: Radius.circular(100),
                                                            ),
                                                          ),
                                                          child: SvgPicture.asset(
                                                            'assets/icons/liked.svg',
                                                            width: 20.0,
                                                            color: settingRepo.setting.value.iconColor,
                                                          ).pSymmetric(h: 30, v: 5),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 0,
                                                  right: 0,
                                                  child: Transform.translate(
                                                    offset: Offset(-35, 0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: settingRepo.setting.value.accentColor,
                                                        borderRadius: BorderRadius.circular(100),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: settingRepo.setting.value.bgShade!,
                                                            blurRadius: 2.0,
                                                            offset: Offset(2, 0.5),
                                                          ),
                                                        ],
                                                      ),
                                                      child: SvgPicture.asset(
                                                        'assets/icons/videos.svg',
                                                        width: 20.0,
                                                        color: settingRepo.setting.value.iconColor,
                                                      ).pSymmetric(h: 30, v: 5),
                                                    ).centered(),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Stack(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          activeTab = 1;
                                                          page = 1;
                                                        });
                                                        _con.getMyProfile(page, false);
                                                      },
                                                      child: Transform.translate(
                                                        offset: Offset(5, 0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: settingRepo.setting.value.bgShade,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(100),
                                                              bottomLeft: Radius.circular(100),
                                                            ),
                                                          ),
                                                          child: SvgPicture.asset(
                                                            'assets/icons/videos.svg',
                                                            width: 20.0,
                                                            color: settingRepo.setting.value.iconColor,
                                                          ).pSymmetric(h: 30, v: 5),
                                                        ),
                                                      ),
                                                    ),
                                                    Transform.translate(
                                                      offset: Offset(-8, 0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: settingRepo.setting.value.accentColor,
                                                          borderRadius: BorderRadius.circular(100),
                                                        ),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/liked.svg',
                                                          width: 20.0,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ).pSymmetric(h: 30, v: 5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  left: 0,
                                                  right: 0,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        activeTab = 1;
                                                      });
                                                    },
                                                    child: Transform.translate(
                                                      offset: Offset(32, 0),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: settingRepo.setting.value.accentColor,
                                                          borderRadius: BorderRadius.circular(100),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: settingRepo.setting.value.bgShade!,
                                                              blurRadius: 2.0,
                                                              offset: Offset(-2, 0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        child: SvgPicture.asset(
                                                          'assets/icons/liked.svg',
                                                          width: 20.0,
                                                          color: settingRepo.setting.value.iconColor,
                                                        ).pSymmetric(h: 30, v: 5),
                                                      ).centered(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ).centered(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    userProfile.userVideos.length > 0 && activeTab == 1
                                        ? Stack(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(bottom: 10),
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
                                                    itemCount: userProfile.userVideos.length,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      final item = userProfile.userVideos.elementAt(index);
                                                      return InkWell(
                                                        onTap: () async {
                                                          videoRepo.homeCon.value.userVideoObj.value.userId = currentUser.value.userId;
                                                          videoRepo.homeCon.value.userVideoObj.value.videoId = item.videoId;
                                                          videoRepo.homeCon.value.userVideoObj.notifyListeners();

                                                          videoRepo.homeCon.value.showFollowingPage.value = false;
                                                          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                                          videoRepo.homeCon.value.getVideos();
                                                          Navigator.of(context).pushReplacementNamed('/home');
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
                                                                color: Colors.black26,
                                                              ),
                                                              Positioned(
                                                                bottom: 10,
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
                                                                      Expanded(
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            showCupertinoModalPopup(
                                                                              context: context,
                                                                              builder: (BuildContext context) => CupertinoActionSheet(
                                                                                actions: [
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Edit"),
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => EditVideo(video: item),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                  CupertinoActionSheetAction(
                                                                                    child: Text("Delete"),
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                      _con.showDeleteAlert("Delete Confirmation", "Do you realy want to delete the video", item.videoId);
                                                                                    },
                                                                                  ),
                                                                                ],
                                                                                cancelButton: CupertinoActionSheetAction(
                                                                                  child: Text("Cancel"),
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            Icons.more_vert,
                                                                            size: 18,
                                                                            color: settingRepo.setting.value.iconColor,
                                                                          ),
                                                                        ),
                                                                        //child: PopupMenuButton<int>(
                                                                        //   padding: EdgeInsets.only(bottom: 0, left: 10),
                                                                        //   color: settingRepo.setting.value.buttonColor,
                                                                        //   icon: Icon(
                                                                        //     Icons.more_vert,
                                                                        //     size: 18,
                                                                        //     color: settingRepo.setting.value.iconColor,
                                                                        //   ),
                                                                        //   onSelected: (int) {
                                                                        //     if (int == 0) {
                                                                        //       Navigator.push(
                                                                        //         context,
                                                                        //         MaterialPageRoute(
                                                                        //           builder: (context) => EditVideo(video: item),
                                                                        //         ),
                                                                        //       );
                                                                        //     } else {
                                                                        //       _con.showDeleteAlert("Delete Confirmation", "Do you realy want to delete the video", item.videoId);
                                                                        //     }
                                                                        //   },
                                                                        //   itemBuilder: (context) => [
                                                                        //     PopupMenuItem(
                                                                        //       height: 15,
                                                                        //       value: 0,
                                                                        //       child: Text(
                                                                        //         "Edit",
                                                                        //         style: TextStyle(
                                                                        //           color: settingRepo.setting.value.textColor,
                                                                        //           // fontFamily: 'RockWellStd',
                                                                        //           fontSize: 12,
                                                                        //         ),
                                                                        //       ),
                                                                        //     ),
                                                                        //     PopupMenuItem(
                                                                        //       height: 15,
                                                                        //       value: 1,
                                                                        //       child: Text(
                                                                        //         "Delete",
                                                                        //         style: TextStyle(
                                                                        //           color: settingRepo.setting.value.textColor,
                                                                        //           // fontFamily: 'RockWellStd',
                                                                        //           fontSize: 12,
                                                                        //         ),
                                                                        //       ),
                                                                        //     ),
                                                                        //   ],
                                                                        // ),
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
                                              ).pSymmetric(h: 10),
                                              _con.videosLoader
                                                  ? Container(
                                                      width: config.App(context).appWidth(100),
                                                      height: config.App(context).appHeight(40),
                                                      child: Center(
                                                        child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    )
                                            ],
                                          )
                                        : ValueListenableBuilder(
                                            valueListenable: userFavVideos,
                                            builder: (context, UserProfileModel favVideos, _) {
                                              return favVideos.userVideos.length > 0
                                                  ? Stack(
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.only(bottom: 10),
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
                                                              itemCount: favVideos.userVideos.length,
                                                              itemBuilder: (BuildContext context, int index) {
                                                                final item = favVideos.userVideos.elementAt(index);
                                                                return InkWell(
                                                                  onTap: () async {
                                                                    videoRepo.homeCon.value.userVideoObj.value.userId = currentUser.value.userId;
                                                                    videoRepo.homeCon.value.userVideoObj.value.videoId = item.videoId;
                                                                    videoRepo.homeCon.value.userVideoObj.notifyListeners();

                                                                    videoRepo.homeCon.value.showFollowingPage.value = false;
                                                                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                                                    videoRepo.homeCon.value.getVideos();
                                                                    Navigator.of(context).pushReplacementNamed('/home');
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
                                                                          color: Colors.black26,
                                                                        ),
                                                                        Positioned(
                                                                          bottom: 10,
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
                                                                                      "${Helper.formatter(item.totalViews.toString())}"
                                                                                          .text
                                                                                          .color(settingRepo.setting.value.textColor!)
                                                                                          .size(13)
                                                                                          .make(),
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
                                                        ).pSymmetric(h: 10),
                                                        _con.videosLoader
                                                            ? Container(
                                                                width: config.App(context).appWidth(100),
                                                                height: config.App(context).appHeight(40),
                                                                child: Center(
                                                                  child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                                ),
                                                              )
                                                            : SizedBox(
                                                                height: 0,
                                                              )
                                                      ],
                                                    )
                                                  : !_con.videosLoader
                                                      ? Container(
                                                          height: config.App(context).appHeight(40),
                                                          child: "No video yet!".text.size(16).color(settingRepo.setting.value.textColor!.withOpacity(0.6)).center.wide.make().centered(),
                                                        )
                                                      : Container(
                                                          width: config.App(context).appWidth(100),
                                                          height: config.App(context).appHeight(40),
                                                          child: Center(
                                                            child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                          ),
                                                        );
                                            })
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    );
                  }),
            ),
            drawer: Container(
              width: 250,
              child: Drawer(
                child: Stack(
                  children: [
                    Container(
                      color: settingRepo.setting.value.appbarColor,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          Container(
                            height: 150,
                            child: DrawerHeader(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        color: settingRepo.setting.value.accentColor,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: userProfile.smallProfilePic != null
                                            ? CachedNetworkImage(
                                                imageUrl: (userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                        userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                    ? userProfile.smallProfilePic
                                                    : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png",
                                                placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                fit: BoxFit.fill,
                                                width: 80,
                                                height: 80,
                                              )
                                            : Image.asset(
                                                'assets/images/default-user.png',
                                                fit: BoxFit.fill,
                                                width: 80,
                                                height: 80,
                                              ),
                                      ).pLTRB(3, 3, 3, 3),
                                    ).objectCenterLeft(),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        "${userProfile.name}".text.color(settingRepo.setting.value.accentColor!).ellipsis.bold.size(18).make(),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        "(${userProfile.username})".text.color(settingRepo.setting.value.textColor!).ellipsis.size(14).make(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Color(0XFF15161a).withOpacity(0.1),
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.5,
                                    color: settingRepo.setting.value.dividerColor!,
                                  ),
                                ),
                              ),
                              margin: EdgeInsets.all(0.0),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                            ),
                          ),
                          ListTile(
                            // contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.person,
                              color: settingRepo.setting.value.iconColor,
                              size: 25,
                            ),
                            title: 'Edit Profile'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileView(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.verified_user,
                              color: settingRepo.setting.value.iconColor,
                              size: 25,
                            ),
                            title: 'Verification'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyProfileView(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.block,
                              color: settingRepo.setting.value.iconColor,
                              size: 25,
                            ),
                            title: 'Blocked User'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlockedUsers(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.lock,
                              color: settingRepo.setting.value.iconColor,
                              size: 25,
                            ),
                            title: 'Change Password'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangePasswordView(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.delete_forever,
                              color: settingRepo.setting.value.iconColor,
                              textDirection: TextDirection.rtl,
                              size: 25,
                            ),
                            title: 'Delete Profile Instruction'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              String url = GlobalConfiguration().get('base_url') + "data-delete";
                              _con.launchURL(url);
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: settingRepo.setting.value.iconColor,
                              textDirection: TextDirection.rtl,
                              size: 25,
                            ),
                            title: 'Notifications'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationSetting(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.chat,
                              color: settingRepo.setting.value.iconColor,
                              textDirection: TextDirection.rtl,
                              size: 25,
                            ),
                            title: 'Chat Setting'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatSetting(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: settingRepo.setting.value.iconColor,
                              textDirection: TextDirection.rtl,
                              size: 25,
                            ),
                            title: 'Logout'.text.color(settingRepo.setting.value.textColor!).size(16).wide.make(),
                            onTap: () {
                              Navigator.pop(context);
                              logout().whenComplete(() async {
                                videoRepo.homeCon.value.showFollowingPage.value = false;
                                videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                videoRepo.homeCon.value.getVideos();
                                Navigator.of(context).pushReplacementNamed('/home');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 10,
                      child: Container(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "App Version:  ${userProfile.appVersion}",
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
