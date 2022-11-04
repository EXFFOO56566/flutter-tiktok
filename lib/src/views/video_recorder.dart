import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../controllers/video_recorder_controller.dart';
import '../models/sound_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/sound_list.dart';
import '../views/video_submit.dart';
import '../widgets/MarqueWidget.dart';

class VideoRecorder extends StatefulWidget {
  VideoRecorder({
    Key? key,
  }) {}
  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends StateMVC<VideoRecorder> with TickerProviderStateMixin {
  VideoRecorderController _con = VideoRecorderController();

  _VideoRecorderState() : super(VideoRecorderController()) {
    _con = VideoRecorderController();
  }

  @override
  void dispose() {
    _con.animationController.dispose();
    _con.videoController!.dispose();
    _con.controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _con.getTimeLimits();
    _con.initCamera();
    if (soundRepo.currentSound.value.soundId > 0) {
      _con.saveAudio(soundRepo.currentSound.value.url);
    }
    super.initState();
    _con.animationController = AnimationController(vsync: this, duration: Duration(seconds: _con.seconds))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _con.animationController.repeat(reverse: !_con.reverse);
          setState(() {
            _con.reverse = !_con.reverse;
          });
        }
      });

    _con.sizeAnimation = Tween<double>(begin: 70.0, end: 80.0).animate(_con.animationController);
    _con.animationController.forward();

    unawaited(_con.loadWatermark());
  }

  Widget _thumbnailWidget() {
    final VideoPlayerController? localVideoController = _con.videoController;

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: _con.videoController == null
          ? Container()
          : Stack(children: <Widget>[
              SizedBox.expand(
                child: (_con.videoController == null)
                    ? Container()
                    : Container(
                        color: Colors.black,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _con.videoController!.value.size.width,
                              height: _con.videoController!.value.size.height,
                              child: Center(
                                child: Container(
                                  child: Center(
                                    child: AspectRatio(aspectRatio: localVideoController!.value.size != null ? localVideoController.value.aspectRatio : 1.0, child: VideoPlayer(localVideoController)),
                                  ), /*AspectRatio(
                                    aspectRatio: _con.videoController!.value.aspectRatio,
                                    child: VideoPlayer(
                                      _con.videoController!,
                                    )),*/
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 50,
                right: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    _con.videoController!.pause();
                    _con.videoController!.dispose();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoSubmit(
                          thumbPath: _con.thumbPath,
                          videoPath: _con.videoPath,
                          gifPath: _con.gifPath,
                        ),
                      ),
                    );
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.check_circle,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                child: RawMaterialButton(
                  onPressed: () {
                    _con.videoController!.pause();
                    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                    soundRepo.currentSound.notifyListeners();
                    videoRepo.homeCon.value.showFollowingPage.value = false;
                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                    videoRepo.homeCon.value.getVideos();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    size: 35.0,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
            ]),
    );
  }

  /*Widget publishPanel() {
    const Map<String, int> privacies = {'Public': 0, 'Private': 1, 'Only Followers': 2};
    return Stack(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _con.key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: Center(
                      child: Text(
                        "New Post",
                        style: TextStyle(
                          fontFamily: 'RockWellStd',
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      height: 1,
                      child: Container(
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  Container(
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  style: TextStyle(
                                    fontFamily: 'RockWellStd',
                                    fontSize: 18.0,
                                    color: Colors.white,
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
//                    contentPadding: EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 0.5,
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 0.5,
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
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 175,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.pinkAccent, //                   <--- border color
                                          width: 0.5,
                                        ),
                                        color: Color(0xff2e2f34),
                                        borderRadius: BorderRadius.all(new Radius.circular(6.0)),
                                        image: DecorationImage(
                                          image: _con.thumbPath != '' ? AssetImage(_con.thumbPath) : AssetImage("assets/images/splash.png"),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),

                                      */ /* child: CachedNetworkImage(
                                      imageUrl: thumbPath,
                                      height: 175,
                                    ),*/ /*
                                    ),
                                  ))
                            ],
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "Privacy Setting",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * .4,
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
//                                      canvasColor: Color(0xffffffff),
                                            canvasColor: Colors.black87,
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButtonFormField(
                                              isExpanded: true,
                                              hint: new Text(
                                                "Select Type",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              iconEnabledColor: Colors.white,
                                              style: new TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0,
                                              ),
                                              value: _con.privacy,
                                              onChanged: (int? newValue) {
                                                setState(() {
                                                  _con.privacy = newValue!;
                                                });
                                              },
                                              items: privacies
                                                  .map((text, value) {
                                                    return MapEntry(
                                                      text,
                                                      DropdownMenuItem<int>(
                                                        value: value,
                                                        child: new Text(
                                                          text,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .values
                                                  .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
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
                                child: RaisedButton(
                                  color: Color(0xff15161a),
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.0),
                                      color: setting.value.buttonColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                          color: setting.value.buttonTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                                    soundRepo.currentSound.notifyListeners();
                                    videoRepo.homeCon.value.showFollowingPage.value = false;
                                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                                    videoRepo.homeCon.value.getVideos();
                                    Navigator.of(context).pushReplacementNamed('/home');
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: RaisedButton(
                                  color: Color(0xff15161a),
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    height: 45,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3.0),
                                      color: setting.value.buttonColor,
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: setting.value.buttonTextColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              fontFamily: 'RockWellStd',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Icon(
                                              Icons.send,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus!.unfocus();

                                    // Validate returns true if the form is valid, otherwise false.
                                    if (_con.key.currentState!.validate()) {
                                      // If the form is valid, display a snackbar. In the real world,
                                      // you'd often call a server or save the information in a database.
                                      _con.enableVideo(context);
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          content: Text("Enter Video Description"),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
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
        ),
        (_con.isProcessing == true)
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.black54,
                ),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black87,
                    ),
                    width: 200,
                    height: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: <Widget>[
                          Center(
                            child: Container(
                              height: 90,
                              width: 90,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Processing video",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }*/

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

  Widget build(BuildContext context) {
    _con.cameraPreview.addListener(() {
      if (_con.cameraPreview.value == true) {
        setState(() {});
      }
    });
    var size = MediaQuery.of(context).size;
    if (size != null) {
      var deviceRatio = size.width / size.height;
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.black54),
      );
      return ModalProgressHUD(
        progressIndicator: showLoaderSpinner(),
        inAsyncCall: _con.showLoader,
        child: WillPopScope(
          onWillPop: () async => _con.willPopScope(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            key: _con.scaffoldKey,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    child: Center(
                      child: /*Transform.scale(
                        scale: (!_con.controller!.value.isInitialized) ? 1 : _con.controller!.value.aspectRatio / deviceRatio,
                        child: new AspectRatio(
                          aspectRatio: (!_con.controller!.value.isInitialized) ? 1 : _con.controller!.value.aspectRatio,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Center(
                                      child: (!_con.controller!.value.isInitialized) ? CircularProgressIndicator() : _cameraPreviewWidget(),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                          _cameraPreviewWidget(),
                    ),
                    onDoubleTap: () {
                      // _con.onSwitchCamera();
                    },
                  ),
                  Positioned(
                    bottom: 35,
                    left: 85,
                    child: _cameraFlashRowWidget(),
                  ),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _captureControlRowWidget(),
                      ),
                    ),
                  ),
                  (_con.controller == null || !_con.controller!.value.isInitialized || !_con.controller!.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 35,
                          left: 0,
                          child: _cameraTogglesRowWidget(),
                        )
                      : Container(),
                  (_con.controller == null || !_con.controller!.value.isInitialized || !_con.controller!.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 110,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: getTimerLimit(),
                            ),
                          ),
                        )
                      : Container(),
                  (_con.showProgressBar)
                      ? Positioned(
                          top: 10,
                          child: ValueListenableBuilder(
                              valueListenable: _con.videoProgressPercent,
                              builder: (context, double videoProgressPercent, _) {
                                return LinearPercentIndicator(
                                  width: MediaQuery.of(context).size.width,
                                  lineHeight: 5.0,
                                  animationDuration: 100,
                                  percent: videoProgressPercent,
                                  progressColor: Colors.pink,
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  // progressColor: Colors.black,
                                );
                              }),
                        )
                      : Container(),
                  (_con.controller == null || !_con.controller!.value.isInitialized || !_con.controller!.value.isRecordingVideo)
                      ? Positioned(
                          top: 30,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                child: SizedBox(
                                  width: 140.0,
                                  child: MarqueeWidget(
                                    direction: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          soundRepo.currentSound.value.title == null || soundRepo.currentSound.value.title == "" ? "Select Sound " : soundRepo.currentSound.value.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Icon(
                                          Icons.queue_music,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SoundList(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  (_con.controller != null && _con.controller!.value.isInitialized && _con.controller!.value.isRecordingVideo)
                      ? Positioned(
                          bottom: 42,
                          right: 90,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox.fromSize(
                                size: Size(
                                  30,
                                  30,
                                ), // button width and height
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        splashColor: Colors.pinkAccent, // splash color
                                        onTap: () {
                                          setState(() {
                                            _con.reverse = _con.reverse;
                                          });
                                          if (!_con.videoRecorded) {
                                            _con.onResumeButtonPressed(context);
                                            _con.animationController.forward();
                                          } else {
                                            _con.onPauseButtonPressed(context);
                                            _con.animationController.stop();
                                          }
                                        },
                                        child: Container(
                                            color: Colors.white,
                                            width: 30,
                                            height: 30,
                                            child: SvgPicture.asset(
                                              !_con.videoRecorded ? 'assets/icons/play.svg' : 'assets/icons/pause.svg',
                                              width: 30,
                                              height: 30,
                                              color: settingRepo.setting.value.accentColor,
                                            ).centered()),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Positioned(
                    bottom: 35,
                    right: 20,
                    child: InkWell(
                      child: SvgPicture.asset(
                        'assets/icons/add_photo.svg',
                        width: 40,
                        color: settingRepo.setting.value.iconColor,
                      ),
                      onTap: () {
                        _con.uploadGalleryVideo();
                      },
                    ),
                  ),
                  (_con.isUploading == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87,
                              ),
                              width: 200,
                              height: 170,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: CircularPercentIndicator(
                                        progressColor: Colors.pink,
                                        percent: _con.uploadProgress.value,
                                        radius: 120.0,
                                        lineWidth: 8.0,
                                        circularStrokeCap: CircularStrokeCap.round,
                                        center: Text(
                                          (_con.uploadProgress.value * 100).toStringAsFixed(2) + "%",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  _con.controller != null && _con.controller!.value.isInitialized && !_con.controller!.value.isRecordingVideo
                      ? Positioned(
                          top: 30,
                          left: 10,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: SizedBox(
                                width: 35,
                                child: ValueListenableBuilder(
                                    valueListenable: soundRepo.mic,
                                    builder: (context, bool enableMic, _) {
                                      return InkWell(
                                        child: SizedBox(
                                          width: 35,
                                          child: enableMic
                                              ? Image.asset(
                                                  "assets/icons/microphone.png",
                                                  height: 30,
                                                )
                                              : Image.asset(
                                                  "assets/icons/microphone-mute.png",
                                                  height: 30,
                                                ),
                                        ),
                                        onTap: () {
                                          soundRepo.mic.value = enableMic ? false : true;
                                          soundRepo.mic.notifyListeners();
                                          _con.onCameraSwitched(_con.cameras[_con.selectedCameraIdx]).then((void v) {});
                                        },
                                      );
                                    }),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  _thumbnailWidget(),
                  _con.videoController == null
                      ? Positioned(
                          top: 30,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              _con.willPopScope(context);
                            },
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  (_con.isProcessing == true)
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black87,
                              ),
                              width: 200,
                              height: 170,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: <Widget>[
                                    Center(
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 4,
                                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Processing video",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!_con.controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        _con.onCameraSwitched(_con.controller!.description);
      }
    }
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = _con.controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Loading..',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _con.pointers++,
        onPointerUp: (_) => _con.pointers--,
        child: CameraPreview(
          _con.controller!,
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _con.handleScaleStart,
              onScaleUpdate: _con.handleScaleUpdate,
              onTapDown: (details) => _con.onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  Widget _cameraTogglesRowWidget() {
    if (_con.cameras == null) {
      return Row();
    }
    return ValueListenableBuilder(
      valueListenable: _con.disableFlipButton,
      builder: (context, bool disableButton, _) {
        return (!disableButton)
            ? InkWell(
                child: SvgPicture.asset(
                  'assets/icons/flip.svg',
                  width: 30,
                  color: settingRepo.setting.value.iconColor,
                ).pOnly(left: 25),
                onTap: () {
                  _con.onSwitchCamera();
                },
              )
            : Container();
      },
    );
  }

  Widget _cameraFlashRowWidget() {
    return Row();
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = _con.controller;
    return cameraController!.value.isInitialized
        ? !cameraController.value.isRecordingVideo && !_con.isProcessing
            ? ClipOval(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {});
                        _con.onRecordButtonPressed(context);
                        _con.controller!.notifyListeners();
                      },
                      onDoubleTap: () {
                        if (cameraController != null && cameraController.value.isInitialized && !cameraController.value.isRecordingVideo) {
                          print("Camera Testing");
                        } else {
                          print("else Camera Testing");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: SvgPicture.asset(
                              "assets/icons/create-video.svg",
                              width: 70,
                              height: 70,
                              color: settingRepo.setting.value.accentColor,
                            ),
                          ), // icon
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : AnimatedBuilder(
                animation: _con.sizeAnimation,
                builder: (context, child) => SizedBox.fromSize(
                  size: Size(_con.sizeAnimation.value, _con.sizeAnimation.value), // button width and height
                  child: GestureDetector(
                    onTap: () {
                      setState(() {});
                      _con.onStopButtonPressed();
                      _con.controller!.notifyListeners();
                    },
                    onDoubleTap: () {
                      if (cameraController.value.isInitialized && !cameraController.value.isRecordingVideo) {
                        print("Camera Testing");
                      } else {
                        print("else Camera Testing");
                      }
                    },
                    child: SvgPicture.asset(
                      "assets/icons/video-stop.svg",
                      width: 50,
                      height: 50,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              )
        : Container();
  }

  Widget getTimerLimit() {
    List<Widget> list = <Widget>[];
    return ValueListenableBuilder(
        valueListenable: _con.videoTimerLimit,
        builder: (context, List<double> timers, _) {
          timers.length = timers.length > 5 ? 5 : timers.length;
          list = <Widget>[];
          if (timers.length > 0) {
            for (var i = 0; i < timers.length; i++) {
              list.add(
                InkWell(
                  onTap: () {
                    if (_con.videoLength != timers[i].toDouble()) {
                      setState(() {
                        _con.videoLength = timers[i] > 300 ? 300 : timers[i];
                      });
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 18,
                    ),
                    height: 45,
                    constraints: BoxConstraints(
                      minWidth: 45,
                    ),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: (_con.videoLength == timers[i]) ? settingRepo.setting.value.accentColor : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                      border: (_con.videoLength == timers[i]) ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.white70, width: 0),
                    ),
                    child: Center(
                      child: Text(
                        "${timers[i].toInt() > 300 ? 300 : timers[i].toInt()}s",
                        style: TextStyle(
                          color: (_con.videoLength == timers[i]) ? settingRepo.setting.value.buttonTextColor : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                height: 70,
                child: timers.length > 0
                    ? list.length > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: list,
                          )
                        : Container()
                    : Container(),
              ),
            );
          } else {
            list.add(Container());
            return Container();
          }
        });
  }
}

class VideoRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: VideoRecorder(),
    );
  }
}

Future<void> main() async {
  runApp(VideoRecorderApp());
}

class TrimmerView extends StatefulWidget {
  final Trimmer trimmer;
  final ValueSetter<String> onVideoSaved;
  final VoidCallback onSkip;
  final double maxLength;
  final String sound;
  final bool showSkip;
  TrimmerView({
    required this.trimmer,
    required this.onVideoSaved,
    required this.onSkip,
    required this.maxLength,
    required this.sound,
    required this.showSkip,
  });
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;
  Color appbarColor = Color(0xff2d3d44);
  Color curveColor = Color(0xff1c262d);
  Color textFieldBorderColor = Color(0xff01a684);
  Color buttonColor = Color(0xff01a684);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<String> _saveVideo() async {
    setState(() {
      if (_startValue + widget.maxLength * 1000 < _endValue) {
        _endValue = _startValue + widget.maxLength * 1000;
      }
      _progressVisibility = true;
    });
    String _value = "";

    await widget.trimmer
        .saveTrimmedVideo(ffmpegCommand: " -preset ultrafast ", applyVideoEncoding: widget.showSkip ? false : true, startValue: _startValue, endValue: _endValue, customVideoFormat: '.mp4')
        .then((value) {
      setState(() {
        _progressVisibility = true;
        _value = value;
      });
    });
    return _value;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Color(0xff2d3d44), statusBarIconBrightness: Brightness.light),
    );
    return Scaffold(
      backgroundColor: settingRepo.setting.value.bgColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: settingRepo.setting.value.iconColor,
            ),
            onPressed: () async {
              videoRepo.isOnRecordingPage.value = true;
              videoRepo.isOnRecordingPage.notifyListeners();
              Navigator.pushReplacementNamed(context, '/video-recorder');
            }),
        iconTheme: IconThemeData(
          size: 16,
          color: settingRepo.setting.value.textColor, //change your color here
        ),
        title: "Post".text.uppercase.bold.size(18).color(settingRepo.setting.value.textColor!).make(),
        backgroundColor: appbarColor,
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: VideoViewer(
                      //trimmer: widget.trimmer,
                      ),
                ),
                Center(
                  child: TrimEditor(
                    // trimmer: widget.trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width - 50,
                    maxVideoLength: Duration(seconds: widget.maxLength.toInt()),
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      if (_endValue - _startValue >= widget.maxLength * 1000 + 0.1) {
                        setState(() {
                          _endValue = _startValue + widget.maxLength * 1000;
                        });
                      }
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          bool playbackState = await widget.trimmer.videPlaybackControl(
                            startValue: _startValue,
                            endValue: _endValue,
                          );

                          setState(() {
                            _isPlaying = playbackState;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: buttonColor),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  _isPlaying ? "Pause" : "Play",
                                  style: TextStyle(
                                    color: settingRepo.setting.value.buttonTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: 'RockWellStd',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: widget.showSkip
                          ? InkWell(
                              onTap: () {
                                widget.onSkip();
                              },
                              child: Container(
                                height: 40,
                                width: 80,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0), color: buttonColor),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        "Skip",
                                        style: TextStyle(
                                          color: settingRepo.setting.value.buttonTextColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          fontFamily: 'RockWellStd',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _progressVisibility
                            ? null
                            : () async {
                                _saveVideo().then((outputPath) {
                                  print('OUTPUT PATH: $outputPath');
                                  final snackBar = SnackBar(
                                    content: Text('Video Saved successfully'),
                                  );
                                  widget.onVideoSaved(outputPath);
                                  Scaffold.of(context).showSnackBar(snackBar);
                                });
                              },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            color: buttonColor,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "Save",
                                  style: TextStyle(
                                    color: settingRepo.setting.value.buttonTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    fontFamily: 'RockWellStd',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).pSymmetric(h: 34, v: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String durationToString(Duration duration) {
    String twoDigits(var n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
