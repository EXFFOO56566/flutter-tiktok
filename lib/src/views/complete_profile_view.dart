import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart';
import '../helpers/app_config.dart' as config;
import '../models/gender.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/user_repository.dart' as userRepo;
import 'verify_otp_screen.dart';

var minDate = new DateTime.now().subtract(Duration(days: 29200));
var yearBefore = new DateTime.now().subtract(Duration(days: 4746));
var formatter = new DateFormat('yyyy-MM-dd 00:00:00.000');
var formatterYear = new DateFormat('yyyy');
var formatterDate = new DateFormat('dd MMM yyyy');

String minYear = formatterYear.format(minDate);
String maxYear = formatterYear.format(yearBefore);
String initDatetime = formatterDate.format(yearBefore);

class CompleteProfileView extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey = GlobalKey<ScaffoldState>();

  final String loginType;
  final String email;
  final String fullName;
  CompleteProfileView({
    Key? key,
    this.loginType = "",
    this.email = "",
    this.fullName = "",
  }) : super(key: key);

  @override
  _CompleteProfileViewState createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends StateMVC<CompleteProfileView> with SingleTickerProviderStateMixin {
  UserController _con = UserController();
  _CompleteProfileViewState() : super(UserController()) {
    _con = UserController();
  }
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    if (userRepo.socialUserProfile.value != null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        print("widget.email ${widget.email} widget.fullName ${widget.fullName}");
        // setState(() {
        _con.showLoader.value = false;
        _con.showLoader.notifyListeners();
        _con.completeProfile = userRepo.socialUserProfile.value;
        _con.fullName = widget.fullName;
        _con.fullNameController = TextEditingController(text: widget.fullName);
        _con.email = widget.email;
        _con.profileEmailController = TextEditingController(text: widget.email);
        _con.loginType = widget.loginType;
        if (userRepo.socialUserProfile.value.email == "") {
        } else {
          _con.profileEmailController = TextEditingController(text: userRepo.socialUserProfile.value.email);
        }
        // });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return ValueListenableBuilder(
        valueListenable: _con.showLoader,
        builder: (context, bool showLoad, _) {
          return ModalProgressHUD(
            inAsyncCall: showLoad,
            child: Scaffold(
              backgroundColor: settingRepo.setting.value.bgColor,
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
                title: "Complete Profile".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus!.unfocus();
                      if (widget.loginType == 'O') {
                        await _con.register().then((value) {
                          if (value != null) {
                            if (value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VerifyOTPView(),
                                ),
                              );
                            }
                          }
                        });
                      } else {
                        _con.registerSocial();
                      }
                    },
                    icon: Icon(
                      Icons.check,
                      color: settingRepo.setting.value.accentColor,
                    ),
                  ),
                ],
              ),
              key: _con.completeProfileScaffoldKey,
              body: EditProfilePanel(),
            ),
          );
        });
  }

  static showLoaderSpinner() {
    return Center(
      child: Container(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget EditProfilePanel() {
    return SingleChildScrollView(
      controller: _con.scrollController,
      child: Stack(
        children: [
          Column(
            children: [
              SlidingUpPanel(
                controller: _con.pc,
                isDraggable: false,
                backdropEnabled: true,
                panelSnapping: false,
                color: Color(0xffffffff),
                maxHeight: 95.0,
                minHeight: 0,
                onPanelClosed: () {
                  _con.scrollController.animateTo(
                    0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 1000),
                  );
                },
                panel: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.5,
                        color: settingRepo.setting.value.dividerColor ?? Colors.grey[400]!,
                      ),
                    ),
                    color: settingRepo.setting.value.bgColor,
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _con.getImageOption(true);
                              _con.pc.close();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/camera.svg',
                              width: 40.0,
                              color: settingRepo.setting.value.textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _con.getImageOption(false);
                              _con.pc.close();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/image-gallery.svg',
                              width: 40.0,
                              color: settingRepo.setting.value.textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                return Scaffold(
                                    appBar: PreferredSize(
                                      preferredSize: Size.fromHeight(45.0),
                                      child: AppBar(
                                        iconTheme: IconThemeData(
                                          color: Colors.white, //change your color here
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
                                        imageProvider: userRepo.socialUserProfile.value.userDP != ''
                                            ? CachedNetworkImageProvider(userRepo.socialUserProfile.value.userDP)
                                            : AssetImage("assets/images/splash.png") as ImageProvider,
                                      ),
                                    ));
                              }));
                              _con.pc.close();
                            },
                            child: Column(
                              children: <Widget>[
                                SvgPicture.asset(
                                  'assets/icons/views.svg',
                                  width: 40.0,
                                  color: settingRepo.setting.value.textColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    color: settingRepo.setting.value.bgColor,
                    child: Form(
                      key: _con.completeProfileFormKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: config.App(context).appHeight(25),
                            width: config.App(context).appWidth(100),
                            color: settingRepo.setting.value.bgShade,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Scaffold(
                                            appBar: PreferredSize(
                                              preferredSize: Size.fromHeight(45.0),
                                              child: AppBar(
                                                centerTitle: true, // this
                                                iconTheme: IconThemeData(
                                                  color: settingRepo.setting.value.iconColor,
                                                ),
                                                // backgroundColor: Color(0xff15161a),
                                                backgroundColor: settingRepo.setting.value.bgColor,
                                                title: Text(
                                                  "PROFILE PICTURE",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: settingRepo.setting.value.headingColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            backgroundColor: settingRepo.setting.value.bgColor,
                                            body: Center(
                                              child: PhotoView(
                                                  enableRotation: true,
                                                  imageProvider: _con.selectedDp.path != ""
                                                      ? FileImage(
                                                          _con.selectedDp,
                                                        )
                                                      : userRepo.socialUserProfile.value.userDP != '' && userRepo.socialUserProfile.value.userDP != null
                                                          ? CachedNetworkImageProvider(
                                                              userRepo.socialUserProfile.value.userDP,
                                                            )
                                                          : AssetImage("assets/images/default-user.png") as ImageProvider),
                                            ));
                                      },
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _con.scrollController.animateTo(
                                            _con.scrollController.position.maxScrollExtent,
                                            curve: Curves.easeOut,
                                            duration: const Duration(milliseconds: 1000),
                                          );
                                          _con.pc.open();
                                        });
                                      },
                                      child: Container(
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
                                            height: App(context).appHeight(20),
                                            width: App(context).appHeight(20),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 5.0,
                                                ),
                                              ],
                                              color: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor : Colors.grey[400],
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: _con.selectedDp.path != null
                                                    ? FileImage(
                                                        _con.selectedDp,
                                                      )
                                                    : userRepo.socialUserProfile.value.userDP != '' && userRepo.socialUserProfile.value.userDP != null
                                                        ? CachedNetworkImageProvider(
                                                            userRepo.socialUserProfile.value.userDP,
                                                          )
                                                        : AssetImage("assets/images/splash.png") as ImageProvider,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 15,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _con.scrollController.animateTo(
                                              70,
                                              curve: Curves.easeOut,
                                              duration: const Duration(milliseconds: 1000),
                                            );
                                            _con.pc.open();
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          'assets/icons/camera.svg',
                                          width: 28.0,
                                          color: settingRepo.setting.value.textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: _con.fullNameController,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'RockWellStd',
                                    fontSize: 14.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  validator: (value) {
                                    return _con.validateField(value!, "Full Name");
                                  },
                                  keyboardType: TextInputType.text,
                                  onChanged: (String val) {
                                    _con.fullName = val;
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
                                    labelText: "Your Name",
                                    labelStyle: TextStyle(
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  controller: _con.profileEmailController,
                                  enabled: _con.email == "" ? true : false,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  validator: (value) {
                                    return _con.validateEmail(value!);
                                  },
                                  onSaved: (String? val) {
                                    _con.email = val!;
                                  },
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
                                    disabledBorder: OutlineInputBorder(
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
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  controller: _con.profileUsernameController,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: settingRepo.setting.value.textColor,
                                  ),
                                  validator: (value) {
                                    return _con.validateField(value!, "Username");
                                  },
                                  onSaved: (String? val) {
                                    _con.userName = val!;
                                  },
                                  onChanged: (String val) {
                                    _con.userName = val;
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
                                    labelText: "Username",
                                    labelStyle: TextStyle(
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller: _con.conDob..text,
                                  style: TextStyle(color: settingRepo.setting.value.textColor, fontWeight: FontWeight.w300),
                                  keyboardType: TextInputType.text,
                                  validator: (input) {
                                    if (_con.profileDOBString == '' || _con.profileDOBString == null) {
                                      return "Date of birth field is required!";
                                    } else {
                                      return null;
                                    }
                                  },
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
                                        _con.conDob..text = _con.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                                        _con.profileDOBString = _con.validDob(date.year.toString(), date.month.toString(), date.day.toString());
                                      },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en,
                                    );
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
                                    labelText: "Date of Birth",
                                    labelStyle: TextStyle(
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  maxLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  controller: _con.passwordController,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  validator: (value) {
                                    return _con.validateField(value!, "Password");
                                  },
                                  obscureText: true,
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
                                    labelText: "Password",
                                    labelStyle: TextStyle(
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  maxLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  controller: _con.confirmPasswordController,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
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
                                    labelText: "Confirm Password",
                                    labelStyle: TextStyle(
                                      color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: Theme(
                                    data: ThemeData(
                                      backgroundColor: settingRepo.setting.value.bgColor,
                                      textTheme: TextTheme(
                                        subtitle1: TextStyle(
                                          color: settingRepo.setting.value.textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      inputDecorationTheme: InputDecorationTheme(
                                        fillColor: settingRepo.setting.value.bgColor,
                                        contentPadding: EdgeInsets.zero,
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: DropdownSearch<Gender>(
                                        validator: (value) {
                                          if (value != null) {
                                            return _con.validateField(value.value, "Gender");
                                          } else {
                                            return "Gender is Required";
                                          }
                                        },
                                        dropdownSearchDecoration: InputDecoration(
                                          labelText: "Select Gender",
                                          labelStyle: TextStyle(fontSize: 16, color: settingRepo.setting.value.textColor!.withOpacity(0.6)),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          border: OutlineInputBorder(borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 1)),
                                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 1)),
                                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: settingRepo.setting.value.buttonColor!, width: 1)),
                                        ),
                                        items: _con.gender,
                                        mode: Mode.BOTTOM_SHEET,
                                        popupBackgroundColor: settingRepo.setting.value.bgShade,
                                        popupBarrierColor: settingRepo.setting.value.dividerColor != null ? settingRepo.setting.value.dividerColor!.withOpacity(0.2) : Colors.grey[200],
                                        itemAsString: (Gender? u) => u!.name,
                                        onChanged: (Gender? data) {
                                          setState(() {
                                            _con.selectedGender = data!.value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ).pSymmetric(h: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
