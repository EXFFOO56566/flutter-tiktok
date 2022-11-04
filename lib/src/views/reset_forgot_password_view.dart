import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'showCupertinoDatePicker.dart';

class ResetForgotPasswordView extends StatefulWidget {
  final String email;
  ResetForgotPasswordView({Key? key, this.email = ""}) : super(key: key);
  @override
  _ResetForgotPasswordViewState createState() => _ResetForgotPasswordViewState();
}

class _ResetForgotPasswordViewState extends StateMVC<ResetForgotPasswordView> {
  UserController _con = UserController();
  _ResetForgotPasswordViewState() : super(UserController()) {
    _con = UserController();
  }

  @override
  void initState() {
    setState(() {
      _con.email = widget.email;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            maintainBottomViewPadding: true,
            child: Scaffold(
              backgroundColor: settingRepo.setting.value.bgColor,
              key: _con.resetForgotPasswordScaffoldKey,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
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
                title: "Reset Password".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                centerTitle: true,
              ),
              body: ValueListenableBuilder(
                  valueListenable: _con.showLoader,
                  builder: (context, bool showLoad, _) {
                    return ModalProgressHUD(
                      inAsyncCall: showLoad,
                      progressIndicator: Helper.showLoaderSpinner(
                        settingRepo.setting.value.iconColor!,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          color: settingRepo.setting.value.bgColor,
                          height: MediaQuery.of(context).size.height,
                          child: Form(
                            key: _con.resetForgotPassword,
                            child: Column(
                              children: [
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
                                  controller: _con.otpController,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 14.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  validator: (value) {
                                    return _con.validateField(value!, "OTP");
                                  },
                                  keyboardType: TextInputType.number,
                                  onSaved: (String? val) {
                                    _con.otp = val!;
                                  },
                                  onChanged: (String val) {
                                    _con.otp = val;
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
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    labelText: "Enter OTP",
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 14.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: _con.passwordController,
                                  validator: (value) {
                                    return _con.validateField(value!, "Password");
                                  },
                                  onSaved: (String? val) {
                                    _con.password = val!;
                                  },
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
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    labelText: "Enter Password",
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 14.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: _con.confirmPasswordController,
                                  validator: (value) {
                                    return _con.validateField(value!, "Confirm Password");
                                  },
                                  onSaved: (String? val) {
                                    _con.confirmPassword = val!;
                                  },
                                  onChanged: (String val) {
                                    _con.confirmPassword = val;
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
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    labelText: "Confirm Password",
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
                                InkWell(
                                  onTap: () => _con.updateForgotPassword(),
                                  child: Container(
                                    height: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: settingRepo.setting.value.accentColor,
                                    ),
                                    child: "Reset Password".text.size(20).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 15),
                                  ).pSymmetric(h: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
