import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/following_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/following_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import 'my_profile_view.dart';
import 'user_profile_view.dart';

class FollowingsView extends StatefulWidget {
  final int type;
  final int userId;
  FollowingsView({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _FollowingsViewState createState() => _FollowingsViewState();
}

class _FollowingsViewState extends StateMVC<FollowingsView> {
  FollowingController _con = FollowingController();

  int page = 1;
  _FollowingsViewState() : super(FollowingController()) {
    _con = FollowingController();
  }

  @override
  void initState() {
    usersData = new ValueNotifier(FollowingModel());
    usersData.notifyListeners();
    if (this.widget.type == 0) {
      _con.curIndex = 0;
      _con.followingUsers(widget.userId, page);
    } else {
      _con.curIndex = 1;
      _con.followers(widget.userId, page);
    }
    super.initState();
  }

  Widget layout(obj) {
    return ValueListenableBuilder(
        valueListenable: _con.showLoader,
        builder: (context, bool showLoading, _) {
          if (obj != null) {
            if (obj.users.length > 0) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 190,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _con.scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: obj.users.length,
                      itemBuilder: (context, i) {
                        print(obj.users[0].toString());
                        var fullName = obj.users[i].firstName + " " + obj.users[i].lastName;
                        return Container(
                          decoration: new BoxDecoration(
                            border: new Border(bottom: new BorderSide(width: 0.2, color: Colors.white)),
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => obj.users[i].id == userRepo.currentUser.value.userId ? MyProfileView() : UsersProfileView(userId: obj.users[i].id),
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: (obj.users[i].dp != '')
                                      ? CachedNetworkImage(
                                          imageUrl: obj.users[i].dp,
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
                                ),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => obj.users[i].id == userRepo.currentUser.value.userId ? MyProfileView() : UsersProfileView(userId: obj.users[i].id),
                                  ),
                                );
                              },
                              child: Text(
                                obj.users[i].id == userRepo.currentUser.value.userId ? "You" : obj.users[i].username,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                            subtitle: Text(
                              fullName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(0.8)),
                            ),
                            trailing: obj.users[i].id == userRepo.currentUser.value.userId
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _con.followUnfollowUser(obj.users[i].id, i);
                                        },
                                        child: Container(
                                          width: 100,
                                          height: 28,
                                          decoration: (obj.users[i].followText == 'Unfollow')
                                              ? BoxDecoration(
                                                  color: settingRepo.setting.value.accentColor,
                                                  border: Border.all(color: settingRepo.setting.value.accentColor!),
                                                  borderRadius: BorderRadius.circular(100),
                                                )
                                              : BoxDecoration(
                                                  color: settingRepo.setting.value.accentColor,
                                                  border: Border.all(color: settingRepo.setting.value.accentColor!),
                                                  borderRadius: BorderRadius.all(
                                                    new Radius.circular(100),
                                                  ),
                                                ),
                                          child: Center(
                                              child: "${obj.users[i].followText}"
                                                  .text
                                                  .wide
                                                  .color((obj.users[i].followText == 'Unfollow') ? settingRepo.setting.value.inactiveButtonTextColor! : settingRepo.setting.value.buttonTextColor!)
                                                  .size(14)
                                                  .make()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: _con.curIndex == 1 ? 10 : 0,
                                      ),
                                      _con.curIndex == 1
                                          ? InkWell(
                                              onTap: () {
                                                _con.removeFollower(obj.users[i].id, i);
                                              },
                                              child: SvgPicture.asset(
                                                'assets/icons/delete.svg',
                                                width: 20,
                                                height: 20,
                                                color: settingRepo.setting.value.textColor,
                                              ),
                                            )
                                          : SizedBox(
                                              height: 0,
                                            )
                                    ],
                                  ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              if (!showLoading) {
                return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 185,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.grey,
                        ),
                        Text(
                          "No User Yet",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }
          } else {
            if (!showLoading) {
              return Center(
                child: Container(
                  height: MediaQuery.of(context).size.height - 185,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey,
                      ),
                      Text(
                        "No User Yet",
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          }
        });
  }

  Widget tabs(user) {
    return DefaultTabController(
      initialIndex: _con.curIndex,
      length: 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            color: settingRepo.setting.value.appbarColor,
            child: TabBar(
              onTap: (index) {
                usersData = new ValueNotifier(FollowingModel());
                usersData.notifyListeners();
                setState(() {
                  _con.searchKeyword = '';
                  _con.curIndex = index;
                  if (index == 0) {
                    _con.followingUsers(widget.userId, 1);
                  } else {
                    _con.followers(widget.userId, 1);
                  }
                });
              },
              unselectedLabelColor: settingRepo.setting.value.bgShade,
              labelColor: settingRepo.setting.value.textColor,
              indicatorColor: settingRepo.setting.value.textColor,
              indicatorWeight: 1,
              indicatorPadding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              tabs: [
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Following",
                      style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15),
                    ),
                  ),
                ),
                Tab(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: Text(
                        "Followers",
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 125,
            child: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
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
                          Timer(Duration(seconds: 1), () {
                            _con.followingUsers(widget.userId, 1);
                          });
                        },
                        decoration: new InputDecoration(
                          fillColor: settingRepo.setting.value.bgShade,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(fontSize: 16.0, color: settingRepo.setting.value.textColor!.withOpacity(0.6)),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(13),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              width: 10,
                              height: 10,
                              fit: BoxFit.fill,
                              color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                            ),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _con.searchController.clear();
                              setState(() {
                                _con.searchKeyword = '';
                                _con.followingUsers(widget.userId, 1);
                              });
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
                  (user != null) ? layout(user) : Container()
                ],
              )),
              Container(
                  child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: TextField(
                        controller: _con.searchController,
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        onChanged: (String val) {
                          setState(() {
                            _con.searchKeyword = val;
                          });
                          Timer(Duration(seconds: 1), () {
                            _con.followers(widget.userId, 1);
                          });
                        },
                        decoration: new InputDecoration(
                          fillColor: settingRepo.setting.value.bgShade,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: settingRepo.setting.value.buttonColor!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: settingRepo.setting.value.buttonColor!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          hintText: "Search",
                          hintStyle: TextStyle(
                            fontSize: 16.0,
                            color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(13),
                            child: SvgPicture.asset(
                              'assets/icons/search.svg',
                              width: 10,
                              height: 10,
                              fit: BoxFit.fill,
                              color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                            ),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          suffixIcon: IconButton(
                            padding: EdgeInsets.only(bottom: 0, right: 0),
                            onPressed: () {
                              _con.searchController.clear();
                              setState(() {
                                _con.searchKeyword = '';
                                _con.followers(widget.userId, 1);
                              });
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
                  (user != null) ? layout(user) : Container()
                ],
              )),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff2d3d44), statusBarIconBrightness: Brightness.light),
    );
    return ValueListenableBuilder(
        valueListenable: usersData,
        builder: (context, FollowingModel _user, _) {
          return ValueListenableBuilder(
              valueListenable: _con.showLoader,
              builder: (context, bool showLoading, _) {
                return ModalProgressHUD(
                  inAsyncCall: showLoading,
                  progressIndicator: Helper.showLoaderSpinner(Colors.white),
                  child: SafeArea(
                    maintainBottomViewPadding: true,
                    child: Scaffold(
                      key: _con.scaffoldKey,
                      resizeToAvoidBottomInset: true,
                      backgroundColor: settingRepo.setting.value.bgColor,
                      appBar: AppBar(
                        elevation: 0,
                        iconTheme: IconThemeData(
                          size: 16,
                          color: settingRepo.setting.value.textColor, //change your color here
                        ),
                        backgroundColor: settingRepo.setting.value.appbarColor,
                        leading: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: settingRepo.setting.value.iconColor,
                          ),
                        ),
                        centerTitle: true,
                      ),
                      body: SingleChildScrollView(child: tabs(_user)),
                    ),
                  ),
                );
              });
        });
  }
}
