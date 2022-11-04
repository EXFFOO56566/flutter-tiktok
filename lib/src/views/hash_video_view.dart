import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/hash_videos_controller.dart';
import '../helpers/helper.dart';
import '../models/hash_videos_model.dart';
import '../repositories/hash_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../widgets/GridViewLayout.dart';

class HashVideoView extends StatefulWidget {
  final String hashTag;
  HashVideoView({Key? key, this.hashTag = ""}) : super(key: key);

  @override
  _HashVideoViewState createState() => _HashVideoViewState();
}

class _HashVideoViewState extends StateMVC<HashVideoView> {
  HashVideosController _con = HashVideosController();
  int page = 1;
  _HashVideoViewState() : super(HashVideosController()) {
    _con = HashVideosController();
  }

  @override
  void initState() {
    _con.getHashData(page, widget.hashTag);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return ValueListenableBuilder(
        valueListenable: hashVideoData,
        builder: (context, HashVideosModel data, _) {
          return ValueListenableBuilder(
              valueListenable: _con.showLoader,
              builder: (context, bool loader, _) {
                return ModalProgressHUD(
                  inAsyncCall: loader,
                  progressIndicator: Helper.showLoaderSpinner(Colors.white),
                  child: SafeArea(
                    child: Scaffold(
                      key: _con.hashScaffoldKey,
                      backgroundColor: settingRepo.setting.value.bgColor,
                      resizeToAvoidBottomInset: false,
                      body: SingleChildScrollView(
                        child: Container(
                          color: settingRepo.setting.value.bgColor,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 15, 0, 0),
                                child: Container(
                                  height: 24,
                                  width: MediaQuery.of(context).size.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          size: 20,
                                          color: settingRepo.setting.value.iconColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13, bottom: 2, left: 10),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        child: Text(
                                          '#${widget.hashTag}',
                                          style: TextStyle(
                                            color: settingRepo.setting.value.headingColor,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  (data.videos != null && data.videos.length > 0)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: MediaQuery.of(context).size.height - 150,
                                            child: GridView.builder(
                                              controller: _con.scrollController,
                                              primary: false,
                                              padding: const EdgeInsets.all(2),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                                                height: 150,
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                              ),
                                              itemCount: data.videos.length,
                                              itemBuilder: (BuildContext context, int i) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    videoRepo.homeCon.value.userVideoObj.value.userId = data.videos[i].userId;
                                                    videoRepo.homeCon.value.userVideoObj.value.videoId = data.videos[i].id;
                                                    videoRepo.homeCon.value.userVideoObj.value.name = data.videos[i].userName + "'s";
                                                    videoRepo.homeCon.value.getVideos().whenComplete(() {
                                                      videoRepo.homeCon.notifyListeners();
                                                      Navigator.of(context).pushReplacementNamed('/home');
                                                    });
                                                  },
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: <Widget>[
                                                      Container(
                                                          height: MediaQuery.of(context).size.height,
                                                          width: MediaQuery.of(context).size.width,
                                                          child: data.videos[i].thumb != ""
                                                              ? Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(settingRepo.setting.value.gridBorderRadius),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: settingRepo.setting.value.gridItemBorderColor!,
                                                                        blurRadius: 3.0, // soften the shadow
                                                                        spreadRadius: 0.0, //extend the shadow
                                                                        offset: Offset(
                                                                          0.0, // Move to right 10  horizontally
                                                                          0.0, // Move to bottom 5 Vertically
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  padding: const EdgeInsets.all(1),
                                                                  child: ClipRRect(
                                                                    borderRadius: BorderRadius.circular(
                                                                      5.0,
                                                                    ),
                                                                    child: CachedNetworkImage(
                                                                      imageUrl: data.videos[i].thumb,
                                                                      placeholder: (context, url) => Center(
                                                                        child: Helper.showLoaderSpinner(Colors.white),
                                                                      ),
                                                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  child: Image.asset(
                                                                    'assets/images/noVideo.jpg',
                                                                    fit: BoxFit.fill,
                                                                  ),
                                                                )),
                                                      Positioned(
                                                        bottom: 20,
                                                        child: Container(
                                                          width: 35.0,
                                                          height: 35.0,
                                                          decoration: new BoxDecoration(
                                                            borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                            border: new Border.all(
                                                              color: settingRepo.setting.value.dpBorderColor!,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Container(
                                                            width: 35.0,
                                                            height: 35.0,
                                                            decoration: new BoxDecoration(
                                                              image: new DecorationImage(
                                                                  image: (data.videos[i].dp != "")
                                                                      ? CachedNetworkImageProvider(
                                                                          data.videos[i].dp,
                                                                        )
                                                                      : AssetImage(
                                                                          'assets/images/default-user.png',
                                                                        ) as ImageProvider,
                                                                  fit: BoxFit.contain),
                                                              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 5,
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              data.videos[i].userName,
                                                              style: TextStyle(
                                                                color: settingRepo.setting.value.textColor,
                                                                fontSize: 11,
                                                                fontFamily: 'RockWellStd',
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            data.videos[i].isVerified == true ? SizedBox(width: 5) : Container(),
                                                            data.videos[i].isVerified == true
                                                                ? Icon(
                                                                    Icons.verified,
                                                                    color: Colors.blueAccent,
                                                                    size: 16,
                                                                  )
                                                                : Container(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                /*),
                                            ),
                                          );*/
                                              },
                                            ),
                                          ),
                                        )
                                      : (!loader)
                                          ? Center(
                                              child: Container(
                                                height: MediaQuery.of(context).size.height - 360,
                                                width: MediaQuery.of(context).size.width,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.videocam,
                                                      size: 30,
                                                      color: settingRepo.setting.value.iconColor,
                                                    ),
                                                    Text(
                                                      "No Videos Found",
                                                      style: TextStyle(
                                                        color: settingRepo.setting.value.textColor,
                                                        fontSize: 15,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class SettingMenu {
  static const String LOGOUT = 'Logout';
  static const String EDIT_PROFILE = 'Edit Profile';
  static const List<String> choices = <String>[EDIT_PROFILE, LOGOUT];
}
