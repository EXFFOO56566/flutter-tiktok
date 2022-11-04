import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../models/videos_model.dart';
import '../repositories/settings_repository.dart' as settingRepo;
import '../repositories/video_repository.dart' as videoRepo;
import '../services/CacheManager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Video videoObj;
  VideoPlayerController? videoController;
  Future<void> initializeVideoPlayerFuture;
  VideoPlayerWidget(this.videoController, this.videoObj, this.initializeVideoPlayerFuture);
  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends StateMVC<VideoPlayerWidget> {
  int chkVideo = 0;
  late VoidCallback listener;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: widget.videoObj.videoId.toString());
    listener = () {
      if (widget.videoController!.value.position.inSeconds == 5 || widget.videoController!.value.position.inSeconds == widget.videoController!.value.duration.inSeconds) {
        widget.videoController!.removeListener(listener);
        chkVideo = 1;
        videoRepo.incVideoViews(widget.videoObj);
      } else {
        return;
      }
    };
    checkVideoController();
    super.initState();
  }

  checkVideoController() async {
    try {
      if (widget.videoController!.hasListeners) {
        if (widget.videoController!.value.isInitialized) {
          widget.videoController!.play();
          setState(() {
            videoRepo.homeCon.value.onTap = false;
          });
        }
      } else {}
    } catch (e) {
      print("error play=");
      final fileInfo = await CustomCacheManager.instance.getFileFromCache(widget.videoObj.url);

      VideoPlayerController controller;
      if (fileInfo == null || fileInfo.file == null) {
        unawaited(CustomCacheManager.instance.downloadFile(widget.videoObj.url).whenComplete(() => print('saved video url ${widget.videoObj.url}')));
        controller = VideoPlayerController.network(widget.videoObj.url);
        widget.videoController = controller;
      } else {
        controller = VideoPlayerController.file(fileInfo.file);
        widget.videoController = controller;
      }
      widget.initializeVideoPlayerFuture = widget.videoController!.initialize();
      videoRepo.homeCon.value.videoControllers[widget.videoObj.url] = widget.videoController;

      videoRepo.homeCon.value.initializeVideoPlayerFutures[widget.videoObj.url] = widget.initializeVideoPlayerFuture;
      videoRepo.homeCon.notifyListeners();
      if (widget.videoController!.value.isInitialized) {
        widget.videoController!.play();

        setState(() {
          videoRepo.homeCon.value.onTap = false;
        });
      }
    }
    if (chkVideo == 0) {
      widget.videoController!.addListener(listener);
    } else {
      widget.videoController!.removeListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: settingRepo.setting.value.bgColor,
      body: FutureBuilder(
        future: widget.initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  videoRepo.homeCon.value.onTap = true;
                  if (widget.videoController!.value.isPlaying) {
                    widget.videoController!.pause();
                  } else {
                    widget.videoController!.play();
                  }
                });
              },
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height,
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: SizedBox.expand(
                              child: FittedBox(
                                fit: widget.videoController!.value.size.height > widget.videoController!.value.size.width ? BoxFit.fitHeight : BoxFit.fitWidth,
                                child: SizedBox(
                                  width: widget.videoController!.value.size.width,
                                  height: widget.videoController!.value.size.height,
                                  child: VideoPlayer(widget.videoController!),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_outline,
                              color: widget.videoController!.value.isPlaying
                                  ? Colors.transparent
                                  : (!videoRepo.homeCon.value.onTap)
                                      ? Colors.transparent
                                      : settingRepo.setting.value.dashboardIconColor,
                              size: 80,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: widget.videoController!.value.size.height * 0.4,
                            width: config.App(scaffoldKey.currentContext).appWidth(100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black38,
                                  Colors.black26,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else {
            return Stack(
              children: [
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                      maxWidth: MediaQuery.of(context).size.width,
                    ),
                    child: SizedBox.expand(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              widget.videoObj.videoThumbnail,
                            ),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        child: Helper.showLoaderSpinner(settingRepo.setting.value.iconColor!),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: config.App(scaffoldKey.currentContext).appHeight(40),
                    width: config.App(scaffoldKey.currentContext).appWidth(100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black38,
                          Colors.black26,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
