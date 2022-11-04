import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_profile_controller.dart';
import '../helpers/helper.dart';
import '../models/following_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart';

class BlockedUsers extends StatefulWidget {
  final int type;
  final int userId;
  BlockedUsers({Key? key, this.type = 0, this.userId = 0}) : super(key: key);

  @override
  _BlockedUsersState createState() => _BlockedUsersState();
}

class _BlockedUsersState extends StateMVC<BlockedUsers> {
  UserProfileController _con = UserProfileController();

  int page = 1;
  _BlockedUsersState() : super(UserProfileController()) {
    _con = UserProfileController();
  }

  @override
  void initState() {
    blockedUsersData = new ValueNotifier(BlockedModel());
    blockedUsersData.notifyListeners();
    _con.getblockedUsers(page);
    super.initState();
  }

  Widget layout(_user) {
    return ValueListenableBuilder(
        valueListenable: _con.showLoader,
        builder: (context, bool showLoading, _) {
          if (_user != null) {
            if (_user.users.length > 0) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 185,
                    child: ListView.builder(
                      controller: _con.scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: _user.users.length,
                      itemBuilder: (context, i) {
                        print(_user.users[0].toString());
                        var fullName = _user.users[i].firstName + " " + _user.users[i].lastName;
                        return Container(
                          decoration: new BoxDecoration(
                            border: new Border(bottom: new BorderSide(width: 0.2, color: settingRepo.setting.value.dividerColor!)),
                          ),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: settingRepo.setting.value.dpBorderColor!,
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: (_user.users[i].dp != '')
                                    ? CachedNetworkImage(
                                        imageUrl: _user.users[i].dp,
                                        placeholder: (context, url) => Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
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
                            title: Text(
                              _user.users[i].username,
                              style: TextStyle(color: settingRepo.setting.value.textColor, fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            subtitle: Text(
                              fullName,
                              style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.7), fontSize: 14),
                            ),
                            trailing: GestureDetector(
                                onTap: () {
                                  if (!_con.blockUnblockLoader) {
                                    _con.blockUnblockUser(_user.users[i].id);
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: settingRepo.setting.value.inactiveButtonColor,
                                    border: Border.all(color: settingRepo.setting.value.inactiveButtonColor!),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: (!_con.blockUnblockLoader)
                                        ? Text(
                                            "Unblock",
                                            style: TextStyle(
                                              color: (_user.users[i].followText == 'Following') ? settingRepo.setting.value.inactiveButtonTextColor : settingRepo.setting.value.buttonTextColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        : Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                                  ),
                                )),
                            contentPadding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            } else {
              if (showLoading) {
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
                          color: settingRepo.setting.value.iconColor!.withOpacity(0.5),
                        ),
                        Text(
                          "No Blocked Users",
                          style: TextStyle(
                            color: settingRepo.setting.value.textColor!.withOpacity(0.5),
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
                        color: settingRepo.setting.value.iconColor!.withOpacity(0.5),
                      ),
                      Text(
                        "No User Yet",
                        style: TextStyle(color: settingRepo.setting.value.textColor!.withOpacity(0.5), fontSize: 15),
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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff2d3d44), statusBarIconBrightness: Brightness.light),
    );
    return ValueListenableBuilder(
        valueListenable: blockedUsersData,
        builder: (context, BlockedModel _user, _) {
          return ValueListenableBuilder(
              valueListenable: _con.showLoader,
              builder: (context, bool showLoading, _) {
                return ModalProgressHUD(
                    inAsyncCall: showLoading,
                    progressIndicator: Helper.showLoaderSpinner(Colors.white),
                    child: SafeArea(
                      child: Scaffold(
                        backgroundColor: settingRepo.setting.value.bgColor,
                        key: _con.blockedUserScaffoldKey,
                        resizeToAvoidBottomInset: true,
                        appBar: AppBar(
                          automaticallyImplyLeading: true,
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
                          title: "Blocked Users".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                        ),
                        body: SingleChildScrollView(
                          child: Container(
                            color: settingRepo.setting.value.bgColor,
                            child: Column(
                              children: <Widget>[
                                layout(_user),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ));
              });
        });
  }
}
