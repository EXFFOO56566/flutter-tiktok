import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/user_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../repositories/settings_repository.dart' as settingRepo;

class VerifyOTPView extends StatefulWidget {
  @override
  _VerifyOTPViewState createState() => _VerifyOTPViewState();
}

class _VerifyOTPViewState extends StateMVC<VerifyOTPView> {
  ScaffoldState scaffold = ScaffoldState();
  UserController _con = UserController();
  _VerifyOTPViewState() : super(UserController()) {
    _con = UserController();
  }
  TextEditingController textEditingController = TextEditingController();
  bool hasError = false;
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  @override
  void initState() {
    _con.startTimer();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      setState(() {
        _con.bHideTimer = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _con.reload.addListener(() {
      if (_con.reload.value == true) {
        setState(() {});
      }
    });
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      appBar: AppBar(
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
        title: "Email Verification".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
          valueListenable: _con.showLoader,
          builder: (context, bool showLoad, _) {
            return ModalProgressHUD(
              inAsyncCall: showLoad,
              progressIndicator: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
              opacity: 1.0,
              color: Colors.black26,
              child: Container(
                color: Colors.black,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Enter 6 digits verification code has sent in your registered email account."
                        .text
                        .color(settingRepo.setting.value.textColor!)
                        .lineHeight(1.4)
                        .size(16)
                        .wide
                        .center
                        .make()
                        .centered(),
                    SizedBox(
                      height: 30,
                    ),
                    PinCodeTextField(
                      backgroundColor: settingRepo.setting.value.bgColor,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        inactiveColor: settingRepo.setting.value.textColor,
                        disabledColor: settingRepo.setting.value.textColor,
                        inactiveFillColor: settingRepo.setting.value.textColor,
                        selectedFillColor: settingRepo.setting.value.textColor,
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(0),
                        fieldHeight: config.App(context).appWidth(15),
                        fieldWidth: config.App(context).appWidth(15),
                        activeFillColor: settingRepo.setting.value.textColor,
                      ),
                      cursorColor: settingRepo.setting.value.bgShade,
                      animationDuration: Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: settingRepo.setting.value.bgShade!,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {
                        _con.otp = v;

                        _con.verifyOtp();
                      },
                      onChanged: (value) {
                        _con.otp = value;
                      },
                      beforeTextPaste: (text) {
                        return true;
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _con.bHideTimer
                        ? ValueListenableBuilder(
                            valueListenable: _con.countTimer,
                            builder: (context, int countTimer, _) {
                              return 'Resend OTP in $countTimer seconds'.text.color(settingRepo.setting.value.textColor!).lineHeight(1.4).size(16).wide.center.make().centered();
                            })
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              "Did not get OTP?".text.color(settingRepo.setting.value.textColor!).size(16).wide.center.make(),
                              SizedBox(
                                width: 10,
                              ),
                              "Resend OTP".text.color(settingRepo.setting.value.buttonColor!).size(16).wide.center.make().onTap(() {
                                _con.resendOtp(verifyPage: true);
                              }),
                            ],
                          )
                  ],
                ),
              ).pSymmetric(h: 10),
            );
          }),
    );
  }
}
