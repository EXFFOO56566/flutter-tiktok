import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_profile_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/edit_profile_model.dart';
import '../models/gender.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import 'showCupertinoDatePicker.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearBefore);
String initDatetime = formatter.format(yearBefore);

class EditProfileView extends StatefulWidget {
  EditProfileView({Key? key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends StateMVC<EditProfileView> {
  UserProfileController _con = UserProfileController();
  int page = 1;
  _EditProfileViewState() : super(UserProfileController()) {
    _con = UserProfileController();
  }

  @override
  initState() {
    print("StartForeach");
    _con.genders.forEach((element) {
      print(element.value + " " + element.name);
    });
    print("EndForeach");
    _con.fetchLoggedInUserInformation();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Timer(Duration(seconds: 2), () => setState(() {}));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      controller: _con.nameController,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      validator: (input) {
        String patttern = r'^[a-z A-Z,.\-]+$';
        RegExp regExp = new RegExp(patttern);
        if (input!.isEmpty) {
          return "Name field is required!";
        } else if (!regExp.hasMatch(input)) {
          return "Please enter valid full name";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      onSaved: (String? val) {
        usersProfileData.value.name = val!;
      },
      onChanged: (String val) {
        usersProfileData.value.name = val;
        print(usersProfileData.value.name);
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        disabledBorder: InputBorder.none,
        hintText: "Enter Your Name",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.7),
        ),
      ),
    );

    final emailField = TextFormField(
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor!,
        fontSize: 14.0,
      ),
      obscureText: false,
      readOnly: true,
      validator: (input) {
        Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
        RegExp regex = new RegExp(pattern.toString());
        if (input!.isEmpty) {
          return "Email field is required!";
        } else if (!regex.hasMatch(input)) {
          return "Please enter valid email";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.emailAddress,
      controller: _con.emailController,
      onSaved: (String? val) {
        usersProfileData.value.email = val!;
      },
      onChanged: (String val) {
        usersProfileData.value.email = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        disabledBorder: InputBorder.none,
        hintText: "Enter Email",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.7),
        ),
      ),
    );

    final usernameField = TextFormField(
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor!,
        fontSize: 14.0,
      ),
      obscureText: false,
      validator: (input) {
        if (input!.isEmpty) {
          return "Username field is required!";
        } else {
          return null;
        }
      },
      keyboardType: TextInputType.text,
      controller: _con.usernameController,
      onSaved: (String? val) {
        usersProfileData.value.userName = val!;
      },
      onChanged: (String val) {
        usersProfileData.value.userName = val;
      },
      decoration: new InputDecoration(
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        disabledBorder: InputBorder.none,
        hintText: "Enter Username",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.7),
        ),
      ),
    );

    final mobileField = TextFormField(
      inputFormatters: [
        LengthLimitingTextInputFormatter(13),
      ],
      textAlign: TextAlign.left,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      validator: (input) {
        Pattern pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
        RegExp regex = new RegExp(pattern.toString());
        if (input!.isEmpty) {
          return "Mobile field is required!";
        } else if (!regex.hasMatch(input)) {
          return "Please enter valid mobile no";
        } else {
          return null;
        }
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: false,
      keyboardType: TextInputType.phone,
      controller: _con.mobileController,
      onSaved: (String? val) {
        usersProfileData.value.mobile = val!;
      },
      onChanged: (String val) {
        usersProfileData.value.mobile = val;
      },
      decoration: new InputDecoration(
        counterText: '',
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        hintText: "Enter Mobile No.",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.7),
        ),
      ),
    );

    final bioField = TextFormField(
      textAlign: TextAlign.left,
      maxLength: 80,
      maxLines: null,
      style: TextStyle(
        color: settingRepo.setting.value.textColor,
        fontSize: 14.0,
      ),
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: _con.bioController,
      onSaved: (String? val) {
        usersProfileData.value.bio = val!;
      },
      onChanged: (String val) {
        usersProfileData.value.bio = val;
      },
      decoration: new InputDecoration(
        counterText: "",
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          wordSpacing: 2.0,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: settingRepo.setting.value.buttonColor!,
            width: 0.5,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 0.5,
          ),
        ),
        hintText: "Enter Bio (80 chars)",
        hintStyle: TextStyle(
          color: settingRepo.setting.value.textColor!.withOpacity(0.70),
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
                title: "Edit Profile".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                centerTitle: true,
                actions: <Widget>[
                  InkWell(
                    onTap: () {
                      if (_con.formKey.currentState!.validate()) {
                        _con.update();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: settingRepo.setting.value.accentColor,
                      ),
                      child: "Update".text.size(10).uppercase.center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 8, v: 0),
                    ).pSymmetric(h: 15, v: 12),
                  )
                ],
              ),
              body: ValueListenableBuilder(
                  valueListenable: _con.showLoader,
                  builder: (context, bool showLoading, _) {
                    return ModalProgressHUD(
                      inAsyncCall: showLoading,
                      progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                      child: SingleChildScrollView(
                        child: Container(
                          color: settingRepo.setting.value.bgColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ClipPath(
                                clipper: CurveDownClipper(),
                                child: Container(
                                  color: settingRepo.setting.value.bgShade,
                                  height: config.App(context).appHeight(20),
                                  width: config.App(context).appWidth(100),
                                  child: Center(
                                    child: Stack(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet<void>(
                                                backgroundColor: settingRepo.setting.value.bgShade,
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Container(
                                                    height: config.App(context).appHeight(15),
                                                    width: config.App(context).appWidth(100),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              onTap: () {
                                                                _con.getImageOption(true);
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Column(
                                                                children: <Widget>[
                                                                  SvgPicture.asset(
                                                                    'assets/icons/camera.svg',
                                                                    color: settingRepo.setting.value.iconColor,
                                                                    width: 50,
                                                                    height: 50,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                    child: Text(
                                                                      "Camera",
                                                                      style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                _con.getImageOption(false);
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Column(
                                                                children: <Widget>[
                                                                  SvgPicture.asset(
                                                                    'assets/icons/image-gallery.svg',
                                                                    color: settingRepo.setting.value.iconColor,
                                                                    width: 50,
                                                                    height: 50,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                    child: Text(
                                                                      "Gallery",
                                                                      style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                                  return Scaffold(
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
                                                                            color: Colors.black, //change your color here
                                                                          ),
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
                                                                      backgroundColor: settingRepo.setting.value.bgColor,
                                                                      body: Center(
                                                                        child: PhotoView(
                                                                          enableRotation: true,
                                                                          imageProvider: CachedNetworkImageProvider((_userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                                  _userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                              ? _userProfile.largeProfilePic
                                                                              : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png"),
                                                                        ),
                                                                      ));
                                                                }));
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: Column(
                                                                children: <Widget>[
                                                                  SvgPicture.asset(
                                                                    'assets/icons/views.svg',
                                                                    color: settingRepo.setting.value.iconColor,
                                                                    width: 50,
                                                                    height: 50,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                    child: Text(
                                                                      "View Picture",
                                                                      style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Container(
                                            width: 100.0,
                                            height: 100.0,
                                            decoration: new BoxDecoration(
                                              borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                              border: new Border.all(
                                                color: settingRepo.setting.value.dpBorderColor!,
                                                width: 5.0,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(2.0),
                                              child: Container(
                                                width: 100.0,
                                                height: 100.0,
                                                decoration: new BoxDecoration(
                                                  image: new DecorationImage(
                                                    image: new CachedNetworkImageProvider(
                                                      (_userProfile.smallProfilePic.toLowerCase().contains(".jpg") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains(".jpeg") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains(".png") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains(".gif") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains(".bmp") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                              _userProfile.smallProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                          ? _userProfile.smallProfilePic
                                                          : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: new BorderRadius.all(new Radius.circular(100.0)),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet<void>(
                                                    backgroundColor: settingRepo.setting.value.bgShade,
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return Container(
                                                        height: config.App(context).appHeight(15),
                                                        width: config.App(context).appWidth(100),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              children: <Widget>[
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    _con.getImageOption(true);
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      SvgPicture.asset(
                                                                        'assets/icons/camera.svg',
                                                                        color: settingRepo.setting.value.iconColor,
                                                                        width: 50,
                                                                        height: 50,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                        child: Text(
                                                                          "Camera",
                                                                          style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    _con.getImageOption(false);
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      SvgPicture.asset(
                                                                        'assets/icons/image-gallery.svg',
                                                                        color: settingRepo.setting.value.iconColor,
                                                                        width: 50,
                                                                        height: 50,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                        child: Text(
                                                                          "Gallery",
                                                                          style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                                                      return Scaffold(
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
                                                                                color: Colors.black, //change your color here
                                                                              ),
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
                                                                          backgroundColor: settingRepo.setting.value.bgColor,
                                                                          body: Center(
                                                                            child: PhotoView(
                                                                              enableRotation: true,
                                                                              imageProvider: CachedNetworkImageProvider((_userProfile.largeProfilePic.toLowerCase().contains(".jpg") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".jpeg") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".png") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".gif") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains(".bmp") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains("fbsbx.com") ||
                                                                                      _userProfile.largeProfilePic.toLowerCase().contains("googleusercontent.com"))
                                                                                  ? _userProfile.largeProfilePic
                                                                                  : '${GlobalConfiguration().get('base_url')}' + "default/user-dummy-pic.png"),
                                                                            ),
                                                                          ));
                                                                    }));
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      SvgPicture.asset(
                                                                        'assets/icons/views.svg',
                                                                        color: settingRepo.setting.value.iconColor,
                                                                        width: 50,
                                                                        height: 50,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
                                                                        child: Text(
                                                                          "View Picture",
                                                                          style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 14),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: settingRepo.setting.value.iconColor,
                                                size: 25.0,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
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
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "Username",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: settingRepo.setting.value.accentColor,
                                              ),
                                            ),
                                            usernameField,
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 30.0,
                                              width: 100,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                child: Text(
                                                  "Name",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: settingRepo.setting.value.accentColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            nameField
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Email",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: settingRepo.setting.value.accentColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            emailField
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 30.0,
                                              width: 100,
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(2, 5, 0, 0),
                                                  child: Text(
                                                    "Gender",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: settingRepo.setting.value.accentColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                canvasColor: settingRepo.setting.value.buttonColor,
                                              ),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: DropdownButtonHideUnderline(
                                                  child: new DropdownButton<Gender>(
                                                    key: UniqueKey(),
                                                    iconEnabledColor: Colors.white,
                                                    style: new TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                    ),
                                                    value: _con.selectedGender,
                                                    onChanged: (Gender? newValue) {
                                                      usersProfileData.value.gender = newValue!.value;
                                                      setState(() {
                                                        _con.selectedGender = newValue;
                                                      });
                                                    },
                                                    items: _con.genders.map((Gender userGender) {
                                                      return new DropdownMenuItem<Gender>(
                                                        value: userGender,
                                                        child: new Text(
                                                          userGender.name,
                                                          textAlign: TextAlign.right,
                                                          style: new TextStyle(
                                                            color: settingRepo.setting.value.textColor,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 30.0,
                                              width: 100,
                                              child: Text(
                                                "Mobile",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: settingRepo.setting.value.accentColor,
                                                ),
                                              ),
                                            ),
                                            mobileField
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 30.0,
                                              width: 100,
                                              child: Text(
                                                "DOB",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: settingRepo.setting.value.accentColor,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context).unfocus();
                                                DatePicker.showDatePicker(
                                                  context,
                                                  theme: DatePickerTheme(
                                                    headerColor: settingRepo.setting.value.accentColor,
                                                    backgroundColor: settingRepo.setting.value.buttonColor!,
                                                    itemStyle: TextStyle(color: settingRepo.setting.value.textColor, fontWeight: FontWeight.w400, fontSize: 18),
                                                    doneStyle: TextStyle(
                                                      color: settingRepo.setting.value.iconColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    cancelStyle: TextStyle(
                                                      color: settingRepo.setting.value.iconColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  showTitleActions: true,
                                                  minTime: minDate,
                                                  maxTime: yearBefore,
                                                  onConfirm: (date) {
                                                    DateTime result;
                                                    if (date.year > 0) {
                                                      result = DateTime(date.year, date.month, date.day, usersProfileData.value.dob.hour, usersProfileData.value.dob.minute);
                                                      usersProfileData.value.dob = result;
                                                      usersProfileData.notifyListeners();
                                                    } else {
                                                      // The user has hit the cancel button.
                                                      result = usersProfileData.value.dob;
                                                    }

                                                    _con.onChanged(result);
                                                  },
                                                  currentTime: DateTime.now(),
                                                  locale: LocaleType.en,
                                                );
                                                /*showCupertinoDatePicker(context,
                                                    mode: CupertinoDatePickerMode.date,
                                                    initialDateTime: usersProfileData.value.dob,
                                                    leftHanded: false,
                                                    maximumDate: minDate,
                                                    minimumYear: int.parse(minYear),
                                                    maximumYear: int.parse(maxYear), onDateTimeChanged: (DateTime date) {
                                                  DateTime result;
                                                  if (date.year > 0) {
                                                    result = DateTime(date.year, date.month, date.day, usersProfileData.value.dob.hour, usersProfileData.value.dob.minute);
                                                    usersProfileData.value.dob = result;
                                                    usersProfileData.notifyListeners();
                                                  } else {
                                                    // The user has hit the cancel button.
                                                    result = usersProfileData.value.dob;
                                                  }

                                                });*/
                                              },
                                              child: (usersProfileData.value.dob != null)
                                                  ? Text(formatterDate.format(usersProfileData.value.dob),
                                                      textAlign: TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: settingRepo.setting.value.textColor,
                                                      ))
                                                  : Container(),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 30,
                                              width: 100,
                                              child: Text(
                                                "Bio",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: settingRepo.setting.value.accentColor,
                                                ),
                                              ),
                                            ),
                                            bioField
                                          ],
                                        ),
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
