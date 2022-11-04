import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/following_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/following_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'user_profile_view.dart';

class FriendsListView extends StatefulWidget {
  FriendsListView({Key? key}) : super(key: key);

  @override
  _FriendsListViewState createState() => _FriendsListViewState();
}

class _FriendsListViewState extends StateMVC<FriendsListView> {
  FollowingController _con = FollowingController();
  int page = 1;
  _FriendsListViewState() : super(FollowingController()) {
    _con = FollowingController();
  }

  @override
  void initState() {
    _con.friendsList(page);
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
                      height: MediaQuery.of(context).size.height - 185,
                      child: ListView.builder(
                        controller: _con.scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: obj.users.length,
                        itemBuilder: (context, i) {
                          print(obj.users[0].toString());
                          var fullName = obj.users[i].firstName + " " + obj.users[i].lastName;
                          return Container(
                            decoration: new BoxDecoration(
                              border: new Border(
                                bottom: new BorderSide(
                                  width: 0.2,
                                  color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UsersProfileView(userId: obj.users[i].id),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: (obj.users[i].dp != '')
                                      ? Image.network(
                                          obj.users[i].dp,
                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                            );
                                          },
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
                              title: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UsersProfileView(userId: obj.users[i].id),
                                    ),
                                  );
                                },
                                child: Text(
                                  obj.users[i].username,
                                  style: TextStyle(
                                    color: settingRepo.setting.value.textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              subtitle: Text(
                                fullName,
                                style: TextStyle(
                                  color: settingRepo.setting.value.textColor,
                                ),
                              ),
                              trailing: Container(
                                width: 85,
                                height: 26,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: settingRepo.setting.value.textColor!,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Text(
                                    "Start Chat",
                                    style: TextStyle(
                                      color: settingRepo.setting.value.textColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 5),
                            ),
                          );
                        },
                      )),
                ),
              );
            } else {
              if (_con.noRecord) {
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
                          "No record found",
                          style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.5), fontSize: 15),
                        )
                      ],
                    ),
                  ),
                );
              } else if (!showLoading) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/users',
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height - 80,
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
                                color: settingRepo.setting.value.iconColor!,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: settingRepo.setting.value.iconColor,
                              size: 20,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "This is your feed of user you follow.",
                            style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "You can follow people or subscribe to hashtags.",
                            style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Icon(
                            Icons.person_add,
                            color: settingRepo.setting.value.iconColor,
                            size: 45,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
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
                        style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.6), fontSize: 15),
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: friendsData,
        builder: (context, FollowingModel _user, _) {
          return ValueListenableBuilder(
              valueListenable: _con.showLoader,
              builder: (context, bool showLoading, _) {
                return ModalProgressHUD(
                  inAsyncCall: showLoading,
                  progressIndicator: Helper.showLoaderSpinner(Colors.black),
                  child: SafeArea(
                    child: Scaffold(
                      key: _con.scaffoldKey,
                      resizeToAvoidBottomInset: false,
                      body: SingleChildScrollView(
                        child: Container(
                          color: settingRepo.setting.value.bgColor,
                          child: Column(
                            children: <Widget>[
                              SingleChildScrollView(
                                child: Container(
                                    child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      height: MediaQuery.of(context).size.height,
                                      child: Container(
                                          child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Flexible(
                                                flex: 0,
                                                child: IconButton(
                                                  color: settingRepo.setting.value.iconColor,
                                                  icon: new Icon(
                                                    Icons.arrow_back,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ),
                                              Flexible(
                                                flex: 1,
                                                child: Container(
                                                  padding: EdgeInsets.only(right: 15),
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
                                                        _con.friendsList(1);
                                                      });
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
                                                      hintStyle: TextStyle(fontSize: 16.0, color: settingRepo.setting.value.textColor!.withOpacity(0.6)),
                                                      contentPadding: EdgeInsets.fromLTRB(2, 15, 0, 0),
                                                      suffixIcon: IconButton(
                                                        padding: EdgeInsets.only(bottom: 0, right: 0),
                                                        onPressed: () {
                                                          _con.searchController.clear();
                                                          setState(() {
                                                            _con.searchKeyword = '';
                                                            _con.friendsList(1);
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.clear,
                                                          color: (_con.searchKeyword.length > 0) ? settingRepo.setting.value.iconColor : settingRepo.setting.value.bgColor,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          (_user != null) ? layout(_user) : Container()
                                        ],
                                      )),
                                    ),
                                  ],
                                )),
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
