import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../models/login_screen_model.dart';
import '../repositories/login_page_repository .dart' as loginRepo;
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import 'forgot_password.dart';
import 'sign_up_view.dart';

class PasswordLoginView extends StatefulWidget {
  final int userId;
  PasswordLoginView({Key? key, this.userId = 0}) : super(key: key);
  @override
  _PasswordLoginViewState createState() => _PasswordLoginViewState();
}

class _PasswordLoginViewState extends StateMVC<PasswordLoginView> {
  UserController _con = UserController();
  _PasswordLoginViewState() : super(UserController()) {
    _con = UserController();
  }
  @override
  void initState() {
    super.initState();
    _con.getLoginPageData();
    if (widget.userId > 0) {
      _con.userIdValue.value = widget.userId;
      _con.userIdValue.notifyListeners();
    }
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () async {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/home');
        return Future.value(true);
      },
      child: ValueListenableBuilder(
          valueListenable: loginRepo.LoginPageData,
          builder: (context, LoginScreenData data, _) {
            return ValueListenableBuilder(
                valueListenable: _con.showLoader,
                builder: (context, bool showLoad, _) {
                  return ModalProgressHUD(
                    inAsyncCall: showLoad,
                    child: SafeArea(
                      maintainBottomViewPadding: true,
                      child: Scaffold(
                        resizeToAvoidBottomInset: true,
                        backgroundColor: settingRepo.setting.value.bgColor,
                        appBar: AppBar(
                          iconTheme: IconThemeData(
                            size: 16,
                            color: settingRepo.setting.value.textColor, //change your color here
                          ),
                          backgroundColor: settingRepo.setting.value.appbarColor,
                          leading: InkWell(
                            onTap: () {
                              videoRepo.homeCon.value.showFollowingPage.value = false;
                              videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                              videoRepo.homeCon.value.getVideos();
                              Navigator.of(context).pushReplacementNamed('/home');
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: settingRepo.setting.value.iconColor,
                            ),
                          ),
                          title: "Sign In".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                          centerTitle: true,
                        ),
                        body: Container(
                          color: settingRepo.setting.value.bgColor,
                          child: ValueListenableBuilder(
                              valueListenable: loginRepo.LoginPageData,
                              builder: (context, LoginScreenData data, _) {
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  color: settingRepo.setting.value.bgColor,
                                  child: SingleChildScrollView(
                                    child: Form(
                                      key: _con.registerFormKey,
                                      child: Column(
                                        children: <Widget>[
                                          ClipPath(
                                            clipper: CurveDownClipper(),
                                            child: Container(
                                              color: settingRepo.setting.value.bgShade,
                                              height: config.App(context).appHeight(20),
                                              width: config.App(context).appWidth(100),
                                              child: Image.asset(
                                                'assets/images/login-logo.png',
                                                fit: BoxFit.fill,
                                                width: config.App(context).appWidth(70),
                                              ).centered(),
                                            ),
                                          ),
                                          SizedBox(
                                            height: config.App(context).appHeight(3),
                                          ),
                                          TextFormField(
                                            controller: _con.emailController,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'RockWellStd',
                                              fontSize: 14.0,
                                              color: settingRepo.setting.value.textColor,
                                            ),
                                            validator: _con.validateEmail,
                                            keyboardType: TextInputType.text,
                                            onChanged: (String val) {
                                              _con.email = val;
                                            },
                                            decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                wordSpacing: 2.0,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              labelText: "Email Address",
                                              labelStyle: TextStyle(
                                                color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ).pSymmetric(h: 20),
                                          SizedBox(
                                            height: config.App(context).appHeight(3),
                                          ),
                                          TextFormField(
                                            controller: _con.passwordController,
                                            obscureText: true,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'RockWellStd',
                                              fontSize: 14.0,
                                              color: settingRepo.setting.value.textColor,
                                            ),
                                            validator: (input) {
                                              if (input!.isEmpty) {
                                                return "Please enter your password!";
                                              } else {
                                                return null;
                                              }
                                            },
                                            keyboardType: TextInputType.text,
                                            onChanged: (String val) {
                                              _con.password = val;
                                            },
                                            decoration: InputDecoration(
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                wordSpacing: 2.0,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: settingRepo.setting.value.buttonColor!,
                                                  width: 1,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              labelText: "Password",
                                              labelStyle: TextStyle(
                                                color: settingRepo.setting.value.textColor!.withOpacity(0.5),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ).pSymmetric(h: 20),
                                          SizedBox(height: 10),
                                          "Forgot Password".text.bold.wide.color(settingRepo.setting.value.textColor!.withOpacity(0.8)).make().objectCenterRight().pSymmetric(h: 20).onTap(() {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ForgotPasswordView(),
                                              ),
                                            );
                                          }),
                                          SizedBox(
                                            height: config.App(context).appHeight(3),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              await _con.login();
                                            },
                                            child: Container(
                                              height: 35,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5),
                                                color: settingRepo.setting.value.accentColor,
                                              ),
                                              child: "Sign In".text.size(20).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 0),
                                            ).pSymmetric(h: 20),
                                          ),
                                          SizedBox(
                                            height: config.App(context).appHeight(3),
                                          ),
                                          ((!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true) ||
                                                  (data.googleLogin != null && data.googleLogin == true) ||
                                                  (data.fbLogin != null && data.fbLogin == true))
                                              ? Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 0.5,
                                                          color: settingRepo.setting.value.bgShade,
                                                        ),
                                                      ),
                                                      "OR".text.size(16).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10),
                                                      Expanded(
                                                        child: Container(
                                                          height: 0.5,
                                                          color: settingRepo.setting.value.bgShade,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ).pSymmetric(h: 22)
                                              : SizedBox(
                                                  height: 0,
                                                ),
                                          SizedBox(
                                            height: ((!Platform.isAndroid && data.appleLogin != null && data.appleLogin == true) ||
                                                    (data.googleLogin != null && data.googleLogin == true) ||
                                                    (data.fbLogin != null && data.fbLogin == true))
                                                ? config.App(context).appHeight(3)
                                                : 0,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                data.fbLogin != null && data.fbLogin == true
                                                    ? InkWell(
                                                        onTap: () {
                                                          _con.loginWithFB();
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: Image.asset(
                                                            'assets/icons/facebook-login.png',
                                                            width: 50.0,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(height: 0),
                                                data.googleLogin != null && data.googleLogin == true
                                                    ? InkWell(
                                                        onTap: () {
                                                          _con.loginWithGoogle();
                                                        },
                                                        child: Container(
                                                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                          child: SvgPicture.asset(
                                                            'assets/icons/google-login.svg',
                                                            width: 46.0,
                                                            height: 46.0,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      ),
                                                Platform.isIOS && data.appleLogin == true
                                                    ? InkWell(
                                                        onTap: () async {
                                                          _con.signInWithApple();
                                                        },
                                                        child: Container(
                                                          width: 46.0,
                                                          height: 46.0,
                                                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: settingRepo.setting.value.iconColor,
                                                          ),
                                                          child: SvgPicture.asset(
                                                            'assets/icons/apple.svg',
                                                            width: 28.0,
                                                            height: 28.0,
                                                            color: settingRepo.setting.value.bgColor,
                                                          ).centered(),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ).pSymmetric(h: 22),
                                          SizedBox(
                                            height: config.App(context).appHeight(3),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SignUpView(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 40,
                                              width: config.App(context).appWidth(100),
                                              // decoration: BoxDecoration(
                                              //   borderRadius: BorderRadius.circular(0),
                                              //   color: settingRepo.setting.value.buttonColor,
                                              // ),
                                              child: "Don't have an account? Create an account"
                                                  .text
                                                  .size(16)
                                                  .underline
                                                  .center
                                                  .color(settingRepo.setting.value.textColor!)
                                                  .make()
                                                  .centered()
                                                  .pSymmetric(h: 10, v: 0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}

class MyDateTimePicker extends StatefulWidget {
  @override
  _MyDateTimePickerState createState() => _MyDateTimePickerState();
}

class _MyDateTimePickerState extends State<MyDateTimePicker> {
  DateTime _dateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return CupertinoDatePicker(
      initialDateTime: _dateTime,
      onDateTimeChanged: (dateTime) {
        setState(() {
          _dateTime = dateTime;
        });
      },
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
