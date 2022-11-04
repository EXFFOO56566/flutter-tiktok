import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import "package:velocity_x/velocity_x.dart";

import '../controllers/video_recorder_controller.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/global_keys.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/video_recorder.dart';

class VideoSubmit extends StatefulWidget {
  final String videoPath;
  final String thumbPath;
  final String gifPath;

  VideoSubmit({required this.videoPath, required this.thumbPath, required this.gifPath})
      : assert(videoPath != null),
        assert(thumbPath != null);
  @override
  _VideoSubmitState createState() => _VideoSubmitState();
}

class _VideoSubmitState extends StateMVC<VideoSubmit> with SingleTickerProviderStateMixin {
  VideoRecorderController _con = VideoRecorderController();
  _VideoSubmitState() : super(VideoRecorderController()) {
    _con = VideoRecorderController();
  }
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    getImageWidth();
    super.initState();
  }

  bool fitHeight = false;
  getImageWidth() async {
    File image = new File(widget.thumbPath); // Or any other way to get a File instance.
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    if (decodedImage.width > decodedImage.height) {
      setState(() {
        fitHeight = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: settingRepo.setting.value.appbarColor, statusBarIconBrightness: Brightness.light),
    );
    return WillPopScope(
      onWillPop: () {
        videoRepo.homeCon.value.showFollowingPage.value = false;
        videoRepo.homeCon.value.showFollowingPage.notifyListeners();
        videoRepo.homeCon.value.getVideos();
        Navigator.of(context).pushReplacementNamed('/home');
        return Future.value(true);
      },
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            iconTheme: IconThemeData(
              size: 16,
              color: settingRepo.setting.value.textColor, //change your color here
            ),
            backgroundColor: settingRepo.setting.value.appbarColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: settingRepo.setting.value.iconColor,
                size: 25,
              ),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoRecorder(),
                ),
              ),
            ),
            title: "Post".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
            centerTitle: true,
          ),
          key: _con.scaffoldKey,
          backgroundColor: settingRepo.setting.value.bgColor,
          body: SingleChildScrollView(
            child: publishPanel(),
          ),
        ),
      ),
    );
  }

  Widget publishPanel() {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: settingRepo.setting.value.bgColor,
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _con.key,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.1,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      child: Container(
                        height: config.App(context).appHeight(40),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: settingRepo.setting.value.dividerColor!,
                              blurRadius: 5.0,
                            ),
                          ],
                          color: settingRepo.setting.value.bgShade,
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: widget.thumbPath != ''
                                ? new FileImage(
                                    File(
                                      widget.thumbPath,
                                    ),
                                  )
                                : AssetImage("assets/images/splash.png") as ImageProvider,
                            fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .1, vertical: 0),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                  fontFamily: 'RockWellStd',
                                  fontSize: 18.0,
                                  color: settingRepo.setting.value.textColor,
                                ),
                                validator: _con.validateDescription,
                                onSaved: (String? val) {
                                  _con.description = val!;
                                },
                                onChanged: (String val) {
                                  _con.description = val;
                                },
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    wordSpacing: 2.0,
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: settingRepo.setting.value.accentColor!),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: settingRepo.setting.value.accentColor!,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: settingRepo.setting.value.accentColor!,
                                      width: 1,
                                    ),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 1.0,
                                    ),
                                  ),
                                  hintText: "Enter Video Description",
                                  hintStyle: TextStyle(
                                    color: settingRepo.setting.value.textColor!.withOpacity(0.6),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Container(
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.black,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            color: settingRepo.setting.value.iconColor,
                                            size: 22,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "Privacy Setting",
                                            style: TextStyle(
                                              color: settingRepo.setting.value.textColor,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _con.privacy = 0;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4), color: _con.privacy == 0 ? settingRepo.setting.value.accentColor : settingRepo.setting.value.iconColor),
                                              child: "Public"
                                                  .text
                                                  .size(13)
                                                  .color(_con.privacy == 0 ? settingRepo.setting.value.textColor! : settingRepo.setting.value.bgColor!)
                                                  .center
                                                  .make()
                                                  .centered()
                                                  .pSymmetric(h: 15, v: 8),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _con.privacy = 1;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4), color: _con.privacy == 1 ? settingRepo.setting.value.accentColor : settingRepo.setting.value.iconColor),
                                              child: "Private"
                                                  .text
                                                  .size(13)
                                                  .color(_con.privacy == 1 ? settingRepo.setting.value.textColor! : settingRepo.setting.value.bgColor!)
                                                  .center
                                                  .make()
                                                  .centered()
                                                  .pSymmetric(h: 15, v: 8),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                _con.privacy = 2;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4), color: _con.privacy == 2 ? settingRepo.setting.value.accentColor : settingRepo.setting.value.iconColor),
                                              child: "Followers"
                                                  .text
                                                  .size(13)
                                                  .color(_con.privacy == 2 ? settingRepo.setting.value.textColor! : settingRepo.setting.value.bgColor!)
                                                  .center
                                                  .make()
                                                  .centered()
                                                  .pSymmetric(h: 15, v: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pushReplacementNamed('/home');
                                    },
                                    child: Container(
                                      height: 45,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: settingRepo.setting.value.accentColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: settingRepo.setting.value.textColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20,
                                            fontFamily: 'RockWellStd',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                ValueListenableBuilder(
                                    valueListenable: _con.isUploading,
                                    builder: (context, bool isUploadingStatus, _) {
                                      return Expanded(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: () async {
                                            if (isUploadingStatus == false) {
                                              FocusManager.instance.primaryFocus!.unfocus();
                                              if (_con.key.currentState!.validate()) {
                                                bool resp = await _con.uploadVideo(
                                                  widget.videoPath,
                                                  widget.thumbPath,
                                                );
                                                if (resp == true) {
                                                  Navigator.of(context).pushReplacementNamed('/my-profile');
                                                }
                                              } else {
                                                ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text("Enter Video Description")));
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 45,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: settingRepo.setting.value.accentColor,
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    "Submit",
                                                    style: TextStyle(
                                                      color: settingRepo.setting.value.textColor,
                                                      fontWeight: FontWeight.normal,
                                                      fontSize: 20,
                                                      fontFamily: 'RockWellStd',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        AnimatedIcon(
          color: Colors.black,
          icon: AnimatedIcons.add_event,
          progress: animationController,
          semanticLabel: 'Show menu',
        ),
        ValueListenableBuilder(
            valueListenable: _con.isUploading,
            builder: (context, bool isUploadingStatus, _) {
              return (isUploadingStatus == true)
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          colorFilter: new ColorFilter.mode(settingRepo.setting.value.accentColor!.withOpacity(1), BlendMode.dstATop),
                          image: widget.thumbPath != ''
                              ? new FileImage(
                                  File(
                                    widget.thumbPath,
                                  ),
                                )
                              : AssetImage("assets/images/splash.png") as ImageProvider,
                          fit: fitHeight == true ? BoxFit.fitHeight : BoxFit.fitWidth,
                        ),
                        color: Colors.black26,
                      ),
                      child: ValueListenableBuilder(
                          valueListenable: _con.uploadProgress,
                          builder: (context, double uploadProgress, _) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                uploadProgress >= 1
                                    ? Container(
                                        width: config.App(context).appWidth(45),
                                        height: config.App(context).appWidth(45),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100),
                                          border: Border.all(color: settingRepo.setting.value.accentColor!, width: 10),
                                        ),
                                        child: SvgPicture.asset(
                                          'assets/icons/checked.svg',
                                          color: settingRepo.setting.value.accentColor,
                                        ).pSymmetric(h: 45, v: 45),
                                      )
                                    : Center(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: settingRepo.setting.value.bgShade,
                                          ),
                                          width: 200,
                                          height: 170,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              children: <Widget>[
                                                uploadProgress >= 1
                                                    ? SvgPicture.asset(
                                                        'assets/icons/checked.svg',
                                                        width: config.App(context).appWidth(30),
                                                        color: settingRepo.setting.value.accentColor,
                                                      )
                                                    : Center(
                                                        child: CircularPercentIndicator(
                                                          progressColor: settingRepo.setting.value.accentColor,
                                                          percent: uploadProgress,
                                                          radius: 120.0,
                                                          lineWidth: 8.0,
                                                          circularStrokeCap: CircularStrokeCap.round,
                                                          center: Text(
                                                            (uploadProgress * 100).toStringAsFixed(2) + "%",
                                                            style: TextStyle(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                uploadProgress >= 1
                                    ? Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              child: Text(
                                                "Yay!!",
                                                style: TextStyle(
                                                  color: settingRepo.setting.value.accentColor,
                                                  fontSize: 45,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          "Your video is posted".text.color(settingRepo.setting.value.textColor!).wide.size(22).make(),
                                        ],
                                      )
                                    : Container(),
                              ],
                            );
                          }),
                    )
                  : Container();
            }),
      ],
    );
  }
}
