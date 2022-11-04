import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../helpers/app_config.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/my_profile_view.dart';
import '../views/password_login_view.dart';
import '../views/user_profile_view.dart';

class VideoDescription extends StatefulWidget {
  final Video video;
  final PanelController pc3;
  VideoDescription(this.video, this.pc3);
  @override
  _VideoDescriptionState createState() => _VideoDescriptionState();
}

class _VideoDescriptionState extends StateMVC<VideoDescription> {
  String username = "";
  String description = "";
  String appToken = "";
  int soundId = 0;
  int loginId = 0;
  bool isLogin = false;
  late AnimationController animationController;

  String soundImageUrl = "";

  String profileImageUrl = "";

  bool isVerified = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    username = widget.video.username;
    isVerified = widget.video.isVerified;
    description = widget.video.description;
    profileImageUrl = widget.video.userDP;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: videoRepo.homeCon.value.descriptionHeight,
      builder: (context, double heightPercent, _) {
        return Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: App(context).appHeight(heightPercent),
            ),
            padding: EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (!videoRepo.homeCon.value.showFollowingPage.value) {
                          videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                        } else {
                          videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2).pause();
                        }
                        videoRepo.isOnHomePage.value = false;
                        videoRepo.isOnHomePage.notifyListeners();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.video.userId == userRepo.currentUser.value.userId
                                ? MyProfileView()
                                : UsersProfileView(
                                    userId: widget.video.userId,
                                  ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: settingRepo.setting.value.dpBorderColor!,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: profileImageUrl != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                  height: 60.0,
                                  width: 60.0,
                                  fit: BoxFit.fitHeight,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Image.asset(
                                  "assets/images/splash.png",
                                  height: 60.0,
                                  width: 60.0,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        username != ''
                            ? GestureDetector(
                                onTap: () async {
                                  videoRepo.isOnHomePage.value = false;
                                  videoRepo.isOnHomePage.notifyListeners();
                                  if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                    videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                  } else {
                                    videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2).pause();
                                  }
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => widget.video.userId == userRepo.currentUser.value.userId
                                          ? MyProfileView()
                                          : UsersProfileView(
                                              userId: widget.video.userId,
                                            ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: settingRepo.setting.value.textColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    isVerified == true
                                        ? Icon(
                                            Icons.verified,
                                            color: Colors.blueAccent,
                                            size: 16,
                                          )
                                        : Container(),
                                    SizedBox(
                                      width: 20.0,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        (widget.video.userId != userRepo.currentUser.value.userId)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ValueListenableBuilder(
                                    valueListenable: videoRepo.homeCon.value.showFollowLoader,
                                    builder: (context, bool showFollowLoading, _) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          showFollowLoading
                                              ? Container(
                                                  height: 25,
                                                  width: 65,
                                                  decoration: BoxDecoration(
                                                    color: settingRepo.setting.value.accentColor,
                                                    borderRadius: BorderRadius.circular(10.0),
                                                  ),
                                                  child: Center(
                                                    child: showLoaderSpinner(),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () async {
                                                    if (userRepo.currentUser.value.token != "") {
                                                      if (videoRepo.homeCon.value.showFollowingPage.value) {
                                                        if (videoRepo.followingUsersVideoData.value.videos
                                                                .elementAt(videoRepo.homeCon.value.showFollowingPage.value ? videoRepo.homeCon.value.swiperIndex2 : videoRepo.homeCon.value.swiperIndex)
                                                                .isFollowing ==
                                                            0) {
                                                          videoRepo.followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex2).totalFollowers++;
                                                        } else {
                                                          videoRepo.followingUsersVideoData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex2).totalFollowers--;
                                                        }
                                                        videoRepo.followingUsersVideoData.notifyListeners();
                                                      } else {
                                                        print(
                                                            "videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing ${videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing}");
                                                        if (videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing == 0) {
                                                          videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing = 1;
                                                          videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).totalFollowers++;
                                                        } else {
                                                          videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).isFollowing = 0;
                                                          videoRepo.videosData.value.videos.elementAt(videoRepo.homeCon.value.swiperIndex).totalFollowers--;
                                                        }
                                                        videoRepo.videosData.notifyListeners();
                                                      }
                                                      await videoRepo.homeCon.value.followUnfollowUser(widget.video);
                                                    } else {
                                                      videoRepo.isOnHomePage.value = false;
                                                      videoRepo.isOnHomePage.notifyListeners();
                                                      if (!videoRepo.homeCon.value.showFollowingPage.value) {
                                                        videoRepo.homeCon.value.videoController(videoRepo.homeCon.value.swiperIndex).pause();
                                                      } else {
                                                        videoRepo.homeCon.value.videoController2(videoRepo.homeCon.value.swiperIndex2).pause();
                                                      }
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => PasswordLoginView(userId: 0),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 25,
                                                    width: 65,
                                                    decoration: BoxDecoration(
                                                      color: settingRepo.setting.value.accentColor,
                                                      borderRadius: BorderRadius.circular(10.0),
                                                    ),
                                                    child: Center(
                                                      child: (!showFollowLoading)
                                                          ? videoRepo.homeCon.value.showFollowingPage.value
                                                              ? Text(
                                                                  (videoRepo.followingUsersVideoData.value.videos
                                                                              .elementAt(videoRepo.homeCon.value.showFollowingPage.value
                                                                                  ? videoRepo.homeCon.value.swiperIndex2
                                                                                  : videoRepo.homeCon.value.swiperIndex)
                                                                              .isFollowing ==
                                                                          0)
                                                                      ? "Follow"
                                                                      : "Unfollow",
                                                                  style: TextStyle(
                                                                    color: settingRepo.setting.value.buttonTextColor,
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 12,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  (videoRepo.videosData.value.videos
                                                                              .elementAt(videoRepo.homeCon.value.showFollowingPage.value
                                                                                  ? videoRepo.homeCon.value.swiperIndex2
                                                                                  : videoRepo.homeCon.value.swiperIndex)
                                                                              .isFollowing ==
                                                                          0)
                                                                      ? "Follow"
                                                                      : "Unfollow",
                                                                  style: TextStyle(
                                                                    color: settingRepo.setting.value.buttonTextColor,
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 12,
                                                                  ),
                                                                )
                                                          : showLoaderSpinner(),
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          widget.video.totalFollowers > 0
                                              ? Text(
                                                  "${Helper.formatter(widget.video.totalFollowers.toString())} " + (widget.video.totalFollowers > 1 ? "Followers" : "Follower"),
                                                  style: TextStyle(
                                                    color: settingRepo.setting.value.textColor,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              : Container(),
                                          description.length > 55
                                              ? InkWell(
                                                  onTap: () {
                                                    videoRepo.homeCon.value.descriptionHeight.value = videoRepo.homeCon.value.descriptionHeight.value == 18.0 ? 40.0 : 18.0;
                                                    videoRepo.homeCon.value.descriptionHeight.notifyListeners();
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 2.0, left: 3, right: 3),
                                                    child: Icon(
                                                      videoRepo.homeCon.value.descriptionHeight.value == 18.0 ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                      color: settingRepo.setting.value.textColor,
                                                      size: 18,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      );
                                    }),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                description != ''
                    ? InkWell(
                        onTap: () {
                          if (description.length > 55) {
                            videoRepo.homeCon.value.descriptionHeight.value = videoRepo.homeCon.value.descriptionHeight.value == 18.0 ? 40.0 : 18.0;
                            videoRepo.homeCon.value.descriptionHeight.notifyListeners();
                          }
                        },
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: App(context).appHeight(heightPercent) - 80,
                          ),
                          child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical, //.horizontal
                            child: Text(
                              "$description",
                              style: TextStyle(
                                color: settingRepo.setting.value.textColor,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
