import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_profile_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearbefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearbefore);
String initDatetime = formatter.format(yearbefore);

class ChangePasswordView extends StatefulWidget {
  // final GlobalKey<ScaffoldState> parentScaffoldKey;
  ChangePasswordView({Key? key}) : super(key: key);

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends StateMVC<ChangePasswordView> {
  UserProfileController _con = UserProfileController();
  int page = 1;
  _ChangePasswordViewState() : super(UserProfileController()) {
    _con = UserProfileController();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff2d3d44), statusBarIconBrightness: Brightness.light),
    );
    final currentPasswordField = TextFormField(
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: true,
      validator: (input) {
        if (input!.isEmpty) {
          return "Current Password field is required!";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      controller: _con.currentPasswordController,
      onSaved: (String? val) {
        _con.currentPassword = val!;
      },
      onChanged: (String val) {
        _con.currentPassword = val;
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
        labelText: "Current Password",
        labelStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
    final newPasswordField = TextFormField(
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: true,
      validator: (input) {
        if (input!.isEmpty) {
          return "New Password field is required!";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      controller: _con.newPasswordController,
      onSaved: (String? val) {
        _con.newPassword = val!;
      },
      onChanged: (String val) {
        _con.newPassword = val;
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
        labelText: "New Password",
        labelStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
    final confirmPasswordField = TextFormField(
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor!,
        fontSize: 14.0,
      ),
      obscureText: true,
      validator: (input) {
        if (input!.isEmpty) {
          return "Confirm Password field is required!";
        } else if (input != _con.newPassword) {
          return "Password doesn't match!";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      controller: _con.confirmPasswordController,
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
        labelText: "Confirm Password",
        labelStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.5),
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );

    return ValueListenableBuilder(
        valueListenable: usersProfileData,
        builder: (context, EditProfileModel _userProfile, _) {
          return SafeArea(
            child: Scaffold(
                backgroundColor: settingRepo.setting.value.bgColor,
                key: _con.scaffoldKey,
                resizeToAvoidBottomInset: false,
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
                  title: "Change Password".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                  centerTitle: true,
                  actions: <Widget>[
                    IconButton(
                      padding: EdgeInsets.all(13),
                      onPressed: () {
                        if (_con.formKey.currentState!.validate()) {
                          _con.changePassword();
                        }
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/update.svg',
                        color: settingRepo.setting.value.accentColor,
                      ),
                    ),
                  ],
                ),
                body: ValueListenableBuilder(
                    valueListenable: _con.showLoader,
                    builder: (context, bool showLoading, _) {
                      return ModalProgressHUD(
                        inAsyncCall: showLoading,
                        progressIndicator: Helper.showLoaderSpinner(
                          settingRepo.setting.value.iconColor!,
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            color: settingRepo.setting.value.bgColor,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              children: <Widget>[
                                ClipPath(
                                  clipper: CurveDownClipper(),
                                  child: Container(
                                    color: settingRepo.setting.value.bgShade,
                                    height: config.App(context).appHeight(20),
                                    width: config.App(context).appWidth(100),
                                    child: SvgPicture.asset(
                                      'assets/icons/lock.svg',
                                      width: 80,
                                      color: settingRepo.setting.value.iconColor,
                                    ).centered(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                  child: Container(
                                    child: Form(
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      key: _con.formKey,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 20,
                                          ),
                                          currentPasswordField,
                                          SizedBox(
                                            height: 20,
                                          ),
                                          newPasswordField,
                                          SizedBox(
                                            height: 20,
                                          ),
                                          confirmPasswordField
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })),
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
