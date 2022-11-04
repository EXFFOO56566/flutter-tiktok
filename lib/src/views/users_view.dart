import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/user_controller.dart';
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart' as videoRepo;

class UsersView extends StatefulWidget {
  UsersView({Key? key}) : super(key: key);

  @override
  _UsersViewState createState() => _UsersViewState();
}

class _UsersViewState extends StateMVC<UsersView> {
  UserController _con = UserController();
  _UsersViewState() : super(UserController()) {
    _con = UserController();
  }

  @override
  void initState() {
    _con.getUsers(1);
    super.initState();
  }

  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/home');
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: usersData,
          builder: (context, VideoModel data, _) {
            return ValueListenableBuilder(
                valueListenable: _con.showLoader,
                builder: (context, bool showLoad, _) {
                  return ModalProgressHUD(
                    inAsyncCall: showLoad,
                    progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                    child: SafeArea(
                      child: Scaffold(
                        key: _con.userScaffoldKey,
                        resizeToAvoidBottomInset: false,
                        body: SafeArea(
                            child: SingleChildScrollView(
                          child: Container(
                            color: settingRepo.setting.value.bgColor,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 15, 0, 0),
                                  child: Container(
                                    height: 24,
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () async {
                                            videoRepo.homeCon.value.showFollowingPage.value = false;
                                            videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                            videoRepo.homeCon.value.getVideos();
                                            Navigator.of(context).pushReplacementNamed('/home');
                                          },
                                          child: Icon(
                                            Icons.arrow_back,
                                            size: 20,
                                            color: settingRepo.setting.value.iconColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Container(
                                            width: MediaQuery.of(context).size.width - 50,
                                            child: TextField(
                                              controller: _con.searchController,
                                              style: TextStyle(
                                                color: settingRepo.setting.value.textColor,
                                                fontSize: 16.0,
                                              ),
                                              obscureText: false,
                                              keyboardType: TextInputType.text,
                                              onChanged: (String val) {
                                                setState(() {
                                                  _con.searchKeyword = val;
                                                });
                                                if (val.length > 2) {
                                                  Timer(Duration(seconds: 1), () {
                                                    _con.getUsers(1);
                                                  });
                                                }
                                              },
                                              decoration: new InputDecoration(
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 0.3),
                                                ),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 0.3),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 0.3),
                                                ),
                                                hintText: "Search",
                                                hintStyle: TextStyle(fontSize: 16.0, color: settingRepo.setting.value.textColor!.withOpacity(0.5)),
                                                suffixIcon: IconButton(
                                                  padding: EdgeInsets.only(bottom: 12),
                                                  onPressed: () {
                                                    _con.searchController.clear();
                                                    setState(() {
                                                      _con.searchKeyword = "";
                                                    });
                                                    _con.getUsers(1);
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: (_con.searchKeyword.length > 0) ? settingRepo.setting.value.iconColor : Colors.transparent,
                                                    size: 16,
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
                                SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 13, bottom: 2, left: 15),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: Text(
                                        'Recommended',
                                        style: TextStyle(
                                          color: settingRepo.setting.value.textColor,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                (data.videos.length > 0)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.height - 110,
                                          child: GridView.builder(
                                            controller: _con.scrollController1,
                                            primary: false,
                                            padding: const EdgeInsets.all(2),
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              childAspectRatio: (itemWidth / itemHeight),
                                              crossAxisSpacing: 15,
                                              mainAxisSpacing: 15,
                                              crossAxisCount: 3,
                                            ),
                                            itemCount: data.videos.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              final item = data.videos.elementAt(i);
                                              print("item.videoThumbnail");
                                              print(item.videoThumbnail);
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    height: MediaQuery.of(context).size.height,
                                                    width: MediaQuery.of(context).size.width,
                                                    child: item.videoThumbnail != ""
                                                        ? Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
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
                                                                borderRadius: BorderRadius.circular(5.0),
                                                                child: CachedNetworkImage(
                                                                  imageUrl: item.videoThumbnail,
                                                                  placeholder: (context, url) => Center(
                                                                    child: Helper.showLoaderSpinner(Colors.white),
                                                                  ),
                                                                  fit: BoxFit.cover,
                                                                )),
                                                          )
                                                        : ClipRRect(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                            child: Image.asset(
                                                              'assets/images/noVideo.jpg',
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                  ),
                                                  Container(
                                                    color: settingRepo.setting.value.dividerColor,
                                                  ),
                                                  Positioned(
                                                    bottom: 55,
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
                                                              image: (item.userDP != "")
                                                                  ? CachedNetworkImageProvider(
                                                                      item.userDP,
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
                                                      bottom: 37,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            item.username,
                                                            style: TextStyle(
                                                              color: settingRepo.setting.value.textColor,
                                                              fontSize: 11,
                                                              fontFamily: 'RockWellStd',
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          SizedBox(width: 5),
                                                          item.isVerified == true
                                                              ? Icon(
                                                                  Icons.verified,
                                                                  color: settingRepo.setting.value.accentColor,
                                                                  size: 16,
                                                                )
                                                              : Container(),
                                                        ],
                                                      )),
                                                  Positioned(
                                                    bottom: -5,
                                                    child: ButtonTheme(
                                                      minWidth: 80,
                                                      height: 25,
                                                      child: RaisedButton(
                                                        color: Colors.transparent,
                                                        padding: EdgeInsets.all(0),
                                                        child: Container(
                                                          height: 25,
                                                          width: 80,
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: settingRepo.setting.value.buttonColor),
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: <Widget>[
                                                                ((_con.followUserId != item.userId))
                                                                    ? Text(
                                                                        item.followText,
                                                                        style: TextStyle(
                                                                          color: settingRepo.setting.value.textColor,
                                                                          fontWeight: FontWeight.bold,
                                                                          fontSize: 11,
                                                                          fontFamily: 'RockWellStd',
                                                                        ),
                                                                      )
                                                                    : Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _con.followUnfollowUser(item.userId, i);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : (!_con.showUserLoader)
                                        ? Center(
                                            child: Container(
                                              height: MediaQuery.of(context).size.height - 360,
                                              width: MediaQuery.of(context).size.width,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.all(10),
                                                    padding: EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(100),
                                                      border: Border.all(
                                                        width: 2,
                                                        color: settingRepo.setting.value.dividerColor!,
                                                      ),
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: settingRepo.setting.value.iconColor,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    "No User Yet",
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
                          ),
                        )),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
