import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../helpers/global_keys.dart';
import '../helpers/helper.dart';
import '../models/sound_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/sound_repository.dart' as soundRepo;
import '../repositories/user_repository.dart' as userRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../views/video_recorder.dart';
import 'dashboard_controller.dart';

class VideoRecorderController extends ControllerMVC {
  DashboardController homeCon = DashboardController();
  CameraController? controller;
  String videoPath = "";
  String audioFile = "";
  String description = "";
  List<CameraDescription> cameras = [];
  int selectedCameraIdx = 0;
  bool videoRecorded = false;
  GlobalKey<FormState> key = new GlobalKey();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  bool showRecordingButton = false;
  ValueNotifier<bool> isUploading = new ValueNotifier(false);
  ValueNotifier<bool> disableFlipButton = new ValueNotifier(false);
  bool isProcessing = false;

  ValueNotifier<double> uploadProgress = new ValueNotifier(0);

  bool saveLocally = true;
  VideoPlayerController? videoController;
  VoidCallback videoPlayerListener = () {};
  String thumbFile = "";
  String gifFile = "";
  String watermark = "";
  int userId = 0;
  PanelController pc1 = new PanelController();
  String appToken = "";
  final assetsAudioPlayer = AssetsAudioPlayer();
  String audioFileName = "";
  int audioId = 0;
  int videoId = 0;
  bool showLoader = false;
  bool isPublishPanelOpen = false;
  bool isVideoRecorded = false;
  ValueNotifier<double> videoProgressPercent = new ValueNotifier(0);

  bool showProgressBar = false;
  double progress = 0.0;
  late Timer timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
    videoProgressPercent.value += 1 / (videoLength * 10);
    videoProgressPercent.notifyListeners();
    if (videoProgressPercent.value >= 1) {
      isProcessing = true;
      videoProgressPercent.value = 1;
      videoProgressPercent.notifyListeners();
      timer.cancel();
      onStopButtonPressed();
    }
  });
  String responsePath = "";
  double videoLength = 15.0;
  bool cameraCrash = false;
  late AnimationController animationController;
  late Animation sizeAnimation;
  bool reverse = false;
  bool isRecordingPaused = false;
  int seconds = 1;
  int privacy = 0;
  String thumbPath = "";
  String gifPath = "";
  ValueNotifier<DateTime> endShift = ValueNotifier(DateTime.now());
  DateTime pauseTime = DateTime.now();
  DateTime playTime = DateTime.now();
  ValueNotifier<List<double>> videoTimerLimit = new ValueNotifier([]);
  ValueNotifier<bool> cameraPreview = new ValueNotifier(false);
  int pointers = 0;
  bool enableAudio = true;
  double minAvailableExposureOffset = 0.0;
  double maxAvailableExposureOffset = 0.0;
  double currentExposureOffset = 0.0;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();
  final Trimmer _trimmer = Trimmer();
  @override
  void dispose() {
    super.dispose();
  }

  initCamera() {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
          print(1111);
        });

        onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }

  Future<void> handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || pointers != 2) {
      return;
    }

    currentScale = (baseScale * details.scale).clamp(minAvailableZoom, maxAvailableZoom);

    await controller!.setZoomLevel(currentScale);
  }

  void handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        showInSnackBar('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        // The exposure mode is currently not supported on the web.
        ...(!kIsWeb
            ? [cameraController.getMinExposureOffset().then((value) => minAvailableExposureOffset = value), cameraController.getMaxExposureOffset().then((value) => maxAvailableExposureOffset = value)]
            : []),
        cameraController.getMaxZoomLevel().then((value) => maxAvailableZoom = value),
        cameraController.getMinZoomLevel().then((value) => minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void _showCameraException(CameraException e) {
    print("${e.code} ${e.description}");
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String? validateDescription(String? value) {
    if (value!.length == 0) {
      return "Description is required!";
    } else {
      return null;
    }
  }

  loadWatermark() {
    videoRepo.getWatermark().then((value) async {
      if (value != '') {
        var file = await DefaultCacheManager().getSingleFile(value);
        // setState(() {
        watermark = file.path;
        // });
      }
    });
  }

  Future<void> onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    if (audioFileName == "") {
      controller = CameraController(
        cameraDescription,
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: soundRepo.mic.value ? true : false,
      );
    } else {
      controller = CameraController(
        cameraDescription,
        ResolutionPreset.veryHigh,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: soundRepo.mic.value ? true : false,
      );
    }
    try {
      await controller!.initialize();
      // await controller!.setFlashMode(FlashMode.off);
      await controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } catch (e) {
      print("Expdddd:" + e.toString());
      setState(() {});
      // showCameraException(e, GlobalVariable.navState.currentContext);
    }
    setState(() {});
    cameraPreview.value = true;
    cameraPreview.notifyListeners();
  }

  Widget dialogContent(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: new Text("Camera Error", style: TextStyle(fontSize: 20.0, color: settingRepo.setting.value.textColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: new Text("Camera Stopped Wroking !!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: settingRepo.setting.value.textColor,
                      )),
                )),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: settingRepo.setting.value.accentColor,
                    ),
                    child: Center(
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          color: settingRepo.setting.value.textColor,
                          fontSize: 20,
                          fontFamily: 'RockWellStd',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCameraException(CameraException e, BuildContext context) {
    setState(() {
      cameraCrash = true;
    });
    AwesomeDialog(
        dialogBackgroundColor: settingRepo.setting.value.buttonColor,
        context: GlobalVariable.navState.currentContext!,
        animType: AnimType.SCALE,
        dialogType: DialogType.WARNING,
        body: dialogContent(context),
        btnOkText: "Close")
      ..show();
  }

  Future<void> onSwitchCamera() async {
    disableFlipButton.value = true;
    disableFlipButton.notifyListeners();
    selectedCameraIdx = selectedCameraIdx == 0 ? 1 : 0;
    print("selectedCameraIdx $selectedCameraIdx");
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    await onCameraSwitched(selectedCamera);
    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
    Timer(Duration(seconds: 2), () {
      disableFlipButton.value = false;
      disableFlipButton.notifyListeners();
    });
  }

  Future<String> enableVideo(BuildContext context) async {
    try {
      Uri apiUrl = Helper.getUri('video-enabled');
      var response = await Dio().post(
        apiUrl.toString(),
        options: Options(
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
          },
        ),
        queryParameters: {
          "video_id": videoId,
          "description": description,
          "privacy": privacy,
        },
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          setState(() {
            isUploading.value = true;
            isUploading.notifyListeners();
            showLoader = false;
          });
          Navigator.of(scaffoldKey.currentContext!).popAndPushNamed('/my-profile');
        } else {
          var msg = response.data['msg'];
          scaffoldKey.currentState!.showSnackBar(
            Helper.toast(msg, Colors.red),
          );
        }
      }
      setState(() {
        showLoader = false;
      });
    } catch (e) {
      var msg = e.toString();
      scaffoldKey.currentState!.showSnackBar(
        Helper.toast(msg, Colors.red),
      );
      setState(() {
        showLoader = false;
      });
    }
    return responsePath;
  }

  Future saveAudio(audio) async {
    DefaultCacheManager().getSingleFile(audio).then((value) {
      // setState(() {
      audioFile = value.path;
      // });
      print("audioFile $audioFile");
      assetsAudioPlayer.open(
        Audio.file(audioFile),
        autoStart: false,
        volume: 0.05,
      );
    });
  }

  Future<String> downloadFile(uri, fileName) async {
    bool downloading;
    bool isDownloaded;
    String progress = "";
    setState(() {
      downloading = true;
    });
    String savePath = await getFilePath(fileName);
    Dio dio = Dio();
    dio.download(
      uri.trim(),
      savePath,
      onReceiveProgress: (rcv, total) {
        progress = ((rcv / total) * 100).toStringAsFixed(0);
        if (progress == '100') {
          isDownloaded = true;
        } else if (double.parse(progress) < 100) {}
      },
      deleteOnError: true,
    ).then((_) {
      if (progress == '100') {
        isDownloaded = true;
      }
      downloading = false;
    });
    return savePath;
  }

  willPopScope(context) async {
    if (isVideoRecorded == true) {
      return exitConfirm(context);
    } else {
      videoRepo.isOnRecordingPage.value = false;
      videoRepo.isOnRecordingPage.notifyListeners();
      videoRepo.homeCon.value.showFollowingPage.value = false;
      videoRepo.homeCon.value.showFollowingPage.notifyListeners();
      videoRepo.homeCon.value.getVideos();
      Navigator.of(context).pushReplacementNamed('/home');
      return Future.value(true);
    }
  }

  void exitConfirm(context) {
    AwesomeDialog(
      dialogBackgroundColor: settingRepo.setting.value.buttonColor,
      context: GlobalVariable.navState.currentContext!,
      animType: AnimType.SCALE,
      dialogType: DialogType.QUESTION,
      body: Column(
        children: <Widget>[
          "Do you really want to discard "
                  "the video?"
              .text
              .color(settingRepo.setting.value.textColor!)
              .size(16)
              .center
              .make()
              .centered()
              .pSymmetric(v: 10),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop("Discard");
            },
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(new Radius.circular(32.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () async {
                          videoRepo.isOnRecordingPage.value = false;
                          videoRepo.isOnRecordingPage.notifyListeners();
                          soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
                          soundRepo.currentSound.notifyListeners();
                          videoRepo.homeCon.value.showFollowingPage.value = false;
                          videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                          videoRepo.homeCon.value.getVideos();
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                        child: Container(
                          width: 100,
                          height: 35,
                          decoration: BoxDecoration(
                            color: settingRepo.setting.value.accentColor,
                            borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                          ),
                          child: Center(
                            child: Text(
                              "Yes",
                              style: TextStyle(color: settingRepo.setting.value.textColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RockWellStd'),
                            ),
                          ),
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop("Discard");
                      },
                      child: Container(
                        width: 100,
                        height: 35,
                        decoration: BoxDecoration(
                          color: settingRepo.setting.value.accentColor,
                          borderRadius: BorderRadius.all(new Radius.circular(5.0)),
                        ),
                        child: Center(
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: settingRepo.setting.value.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'RockWellStd',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    )..show();
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';
    Directory dir;
    if (!Platform.isAndroid) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = (await getExternalStorageDirectory())!;
    }
    path = '${dir.path}/$uniqueFileName';

    return path;
  }

  Future uploadGalleryVideo() async {
    File file = File("");
    final picker = ImagePicker();
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print(appDirectory);
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String thumbImg = '$outputDirectory/${currentTime}.jpg';
    final String outputVideo = '$outputDirectory/${currentTime}.mp4';
    final pickedFile = await picker.getVideo(
      source: ImageSource.gallery,
    );
    // setState(() {
    if (pickedFile != null) {
      file = File(pickedFile.path);
    } else {
      print('No image selected.');
    }
    // });

    if (file != File("")) {
      await _trimmer.loadVideo(videoFile: file);
      Navigator.of(scaffoldKey.currentContext!).push(
        MaterialPageRoute(builder: (context) {
          return TrimmerView(
            trimmer: _trimmer,
            onVideoSaved: (output) async {
              // setState(() {
              videoPath = output;
              // });
              Navigator.pop(context);
              // setState(() {
              isProcessing = true;
              // });
              if (watermark != "") {
                _flutterFFmpeg.execute("-i $videoPath -i $watermark -filter_complex 'overlay=W-w-5:5' -c:a copy -preset ultrafast $outputVideo").then((rc) async {
                  // setState(() {
                  videoPath = outputVideo;
                  // });
                  _flutterFFmpeg.execute("-i $videoPath -ss 00:00:00.000 -vframes 1 $thumbImg").then((rc) async {
                    thumbPath = thumbImg;

                    isProcessing = false;

                    await _startVideoPlayer(videoPath);
                  });
                });
              } else {
                _flutterFFmpeg.execute("-i $videoPath -ss 00:00:00.000 -vframes 1 $thumbImg").then((rc) async {
                  thumbPath = thumbImg;
                  isProcessing = false;

                  await _startVideoPlayer(videoPath);
                });
              }
              String responseVideo = "";
              if (responseVideo != "") {
                pc1.open();
              }
            },
            onSkip: () async {
              Navigator.pop(context);
              // setState(() {
              videoPath = file.path;
              // });
              await _startVideoPlayer(videoPath);
            },
            maxLength: videoLength,
            sound: audioFile,
            showSkip: false,
          );
        }),
      );
    }
  }

  Future<bool> uploadVideo(videoFilePath, thumbFilePath) async {
    isUploading.value = true;
    isUploading.notifyListeners();
    Uri url = Helper.getUri('upload-video');
    String videoFileName = videoFilePath.split('/').last;
    String thumbFileName = thumbFilePath.split('/').last;
    FormData formData = FormData.fromMap({
      "video": await MultipartFile.fromFile(videoFilePath, filename: videoFileName),
      "thumbnail_file": await MultipartFile.fromFile(thumbFilePath, filename: thumbFileName),
      "privacy": privacy,
    });
    var response = await Dio().post(
      url.toString(),
      options: Options(
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ' + userRepo.currentUser.value.token,
        },
      ),
      data: formData,
      queryParameters: {
        "description": description,
        "sound_id": soundRepo.mic.value
            ? 0
            : soundRepo.currentSound.value.soundId > 0
                ? soundRepo.currentSound.value.soundId
                : audioId
      },
      onSendProgress: (int sent, int total) {
        // setState(() {
        uploadProgress.value = sent / total;
        uploadProgress.notifyListeners();
        if (uploadProgress.value >= 100) {
          isUploading.value = false;
          isUploading.notifyListeners();
        }
        // });
      },
    );
    soundRepo.currentSound = new ValueNotifier(SoundData(soundId: 0, title: ""));
    soundRepo.currentSound.notifyListeners();
    if (response.statusCode == 200) {
      if (response.data['status'] == 'success') {
        // setState(() {
        isUploading.value = true;
        isUploading.notifyListeners();
        showLoader = false;
        /*responsePath = response.data['file_path'];
        thumbPath = response.data['thumb_path'];
        videoId = response.data['video_id'];*/
        // });
        return true;
      } else {
        var msg = response.data['msg'];
        AwesomeDialog(
          dialogBackgroundColor: settingRepo.setting.value.buttonColor,
          context: GlobalVariable.navState.currentContext!,
          animType: AnimType.SCALE,
          dialogType: DialogType.WARNING,
          body: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Video Flagged",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    videoRepo.homeCon.value.showFollowingPage.value = false;
                    videoRepo.homeCon.value.showFollowingPage.notifyListeners();
                    videoRepo.homeCon.value.getVideos();
                    Navigator.of(scaffoldKey.currentContext!).pushReplacementNamed('/home');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: settingRepo.setting.value.accentColor,
                    ),
                    child: "Close".text.size(18).center.color(settingRepo.setting.value.textColor!).make().centered().pSymmetric(h: 10, v: 10),
                  ),
                )
              ],
            ),
          ),
        )..show();
        return false;
      }
    } else {
      return false;
    }
    setState(() {
      showLoader = false;
    });
    /*} catch (e) {
      var msg = e.toString();
      scaffoldKey.currentState!.showSnackBar(
        Helper.toast(msg, Colors.red),
      );
      // setState(() {
      showLoader = false;
      // });
      homeCon = videoRepo.homeCon.value;
      return false;
    }*/
  }

  convertToBase(file) async {
    List<int> vidBytes = await File(file).readAsBytes();
    String base64Video = base64Encode(vidBytes);
    return base64Video;
  }

  void onRecordButtonPressed(BuildContext context) {
    isVideoRecorded = true;
    videoRecorded = true;
    isRecordingPaused = false;

    startVideoRecording(context).whenComplete(() {
      showProgressBar = true;
      startTimer(context);
      if (soundRepo.mic.value) {
        assetsAudioPlayer.setVolume(0.05);
      } else {
        assetsAudioPlayer.setVolume(0.6);
      }
      assetsAudioPlayer.play();
      cameraPreview.value = true;
      cameraPreview.notifyListeners();
    });
  }

  void onStopButtonPressed() {
    timer.cancel();
    if (soundRepo.currentSound.value.soundId > 0) {
      assetsAudioPlayer.pause();
    }

    videoRecorded = false;
    isProcessing = true;

    stopVideoRecording().then((String outputVideo) async {
      if (outputVideo != null) {}
    });
  }

  Future<void> _startVideoPlayer(outputVideo) async {
    showLoader = true;
    isProcessing = false;
    final VideoPlayerController vController = VideoPlayerController.file(new File(outputVideo));

    videoPlayerListener = () {
      if (videoController != null && videoController!.value.size != null) {
        videoController!.removeListener(videoPlayerListener);
      }
    };
    vController.addListener(videoPlayerListener);
    await vController.setLooping(true);
    await vController.initialize();
    showLoader = false;
    cameraPreview.value = true;
    cameraPreview.notifyListeners();
    if (videoController != null && videoController!.value.size != null) {
      await videoController?.dispose();
    }

    videoController = vController;

    await vController.play();
  }

  void onPauseButtonPressed(BuildContext context) {
    if (soundRepo.currentSound.value.soundId > 0) {
      assetsAudioPlayer.pause();
    }
    // setState(() {
    isRecordingPaused = true;
    pauseTime = DateTime.now();
    // });
    pauseVideoRecording(context).then((_) {
      // setState(() {
      videoRecorded = false;
      timer.cancel();
      // });
    });
  }

  void onResumeButtonPressed(BuildContext context) {
    assetsAudioPlayer.play();
    playTime = DateTime.now();
    isRecordingPaused = false;
    try {
      endShift.value.add(Duration(milliseconds: playTime.difference(pauseTime).inMilliseconds));
      endShift.notifyListeners();
    } catch (e) {
      print("endShift.value error $e");
    }
    resumeVideoRecording(context).then((_) {
      videoRecorded = true;
      startTimer(context);
    });
  }

  Future<void> startVideoRecording(BuildContext context) async {
    if (!controller!.value.isInitialized) {
      return null;
    }
    if (controller!.value.isRecordingVideo) {
      return null;
    }
    Directory? appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
    } else {
      appDirectory = await getExternalStorageDirectory();
    }
    final String videoDirectory = '${appDirectory!.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/$currentTime.mp4';

    try {
      await controller!.startVideoRecording();
      endShift.value = DateTime.now().add(Duration(milliseconds: videoLength.toInt() * 1000 + int.parse((videoLength.toInt() / 15).toStringAsFixed(0)) * 104));
      endShift.notifyListeners();
    } on CameraException catch (e) {
      showCameraException(e, context);
      return null;
    }
  }

  Future<void> pauseVideoRecording(BuildContext context) async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e, context);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording(BuildContext context) async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      showCameraException(e, context);
      rethrow;
    }
  }

  Future<String> stopVideoRecording() async {
    assetsAudioPlayer.pause();
    if (!controller!.value.isRecordingVideo) {
      return "";
    }
    if (!videoRepo.isOnRecordingPage.value) {
      return "";
    }

    try {
      await controller!.stopVideoRecording().then((file) {
        videoPath = file.path;
      });
    } on CameraException catch (e) {
      showCameraException(e, scaffoldKey.currentContext!);
      return "";
    }
    Directory appDirectory;
    if (!Platform.isAndroid) {
      appDirectory = await getApplicationDocumentsDirectory();
      print(appDirectory);
    } else {
      appDirectory = (await getExternalStorageDirectory())!;
    }
    final String outputDirectory = '${appDirectory.path}/outputVideos';
    await Directory(outputDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String outputVideo = '$outputDirectory/$currentTime.mp4';
    final String thumbImg = '$outputDirectory/$currentTime.jpg';
    String responseVideo = "";
    String audioFileArgs = '';
    String audioFileArgs2 = '';
    String mergeAudioArgs = '';
    String mergeAudioArgs2 = '';
    String watermarkArgs = '';
    if (watermark != '') {
      watermark = " -i $watermark";
      watermarkArgs = ",overlay=W-w-5:5";
    }
    if (audioFile != '') {
      audioFile = " -i $audioFile";
      audioFileArgs = "-c:a aac -ac 2 -ar 22050";
      audioFileArgs2 = "-shortest";
    }
    if (soundRepo.mic.value && audioFile != '') {
      audioFileArgs = '';
    }
    try {
      _flutterFFmpeg
          .execute(
              '-i $videoPath $watermark $audioFile  -filter_complex "$mergeAudioArgs[0:v]scale=720:-2$watermarkArgs" $mergeAudioArgs2 $audioFileArgs -c:v libx264 -preset ultrafast -crf 33  $audioFileArgs2 $outputVideo')
          .then((rc) async {
        setState(() {
          videoPath = outputVideo;
        });
        _flutterFFmpeg.execute("-i $videoPath -ss 00:00:00.000 -vframes 1 $thumbImg").then((rc) async {
          thumbPath = thumbImg;
          try {
            await _trimmer.loadVideo(videoFile: File(videoPath));
          } catch (e) {
            print("videoPath error : $e");
          }
          setState(() {
            isProcessing = false;
          });
          Navigator.of(scaffoldKey.currentContext!).push(
            MaterialPageRoute(builder: (context) {
              return TrimmerView(
                trimmer: _trimmer,
                onVideoSaved: (output) async {
                  setState(() {
                    videoPath = output;
                  });
                  Navigator.pop(context);
                  await _startVideoPlayer(videoPath);
                  String responseVideo = "";
                  if (responseVideo != "") {
                    pc1.open();
                  }
                },
                onSkip: () async {
                  Navigator.pop(context);

                  await _startVideoPlayer(videoPath);
                },
                maxLength: videoLength,
                sound: "",
                showSkip: true,
              );
            }),
          );
        });
      });
    } catch (e) {
      print(e.toString());
    }

    return outputVideo;
  }

  startTimer(BuildContext context) {
    timer = Timer.periodic(new Duration(milliseconds: 100), (timer) {
      videoProgressPercent.value += 1 / (videoLength * 10);
      videoProgressPercent.notifyListeners();
      if (videoProgressPercent.value >= 1) {
        isProcessing = true;
        cameraPreview.value = true;
        cameraPreview.notifyListeners();
        videoProgressPercent.value = 1;
        videoProgressPercent.notifyListeners();
        timer.cancel();
        onStopButtonPressed();
      }
    });
  }

  void getTimeLimits() {
    settingRepo.setting.value.videoTimeLimits.forEach((element) {
      videoTimerLimit.value.add(double.parse(element));
    });
    videoTimerLimit.notifyListeners();
  }
}
