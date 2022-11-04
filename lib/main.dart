import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

import 'routes.dart';
import 'src/helpers/global_keys.dart';
import 'src/repositories/settings_repository.dart' as settingRepo;
import 'src/repositories/video_repository.dart' as videoRepo;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel? channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

Future<void> main() async {
  _enablePlatformOverrideForDesktop();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    //bool inDebug = false;
    assert(() {
      // inDebug = true;
      return true;
    }());
    return Material(
      child: Container(
        alignment: Alignment.center,
        color: settingRepo.setting.value.bgColor,
        child: InkWell(
          onTap: () {
            videoRepo.dataLoaded.value = true;
            videoRepo.homeCon.value.showHomeLoader.value = false;
          },
          child: Text(
            "",
            style: TextStyle(color: settingRepo.setting.value.headingColor),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await GlobalConfiguration().loadFromAsset("configuration");
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel!);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    permission();
    super.initState();
  }

  permission() async {
    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    //Permission for camera...
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus == PermissionStatus.denied) {
      await Permission.camera.request();
    } else if (cameraStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for storage...
    final storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      await Permission.storage.request();
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }

    //Permission for microphone...
    final microphoneStatus = await Permission.microphone.status;
    if (microphoneStatus == PermissionStatus.denied) {
      await Permission.microphone.request();
    } else if (microphoneStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      navigatorKey: GlobalVariable.navState,
      title: '${GlobalConfiguration().get('app_name')}',
      navigatorObservers: [routeObserver],
      initialRoute: '/splash-screen',
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'ProductSans',
        primaryColor: Colors.white,
        floatingActionButtonTheme: FloatingActionButtonThemeData(elevation: 0, foregroundColor: Colors.white),
        brightness: Brightness.light,
        accentColor: Color(0xff36C5D3),
        dividerColor: Color(0xff36C5D3).withOpacity(0.1),
        focusColor: Color(0xff36C5D3).withOpacity(1),
        hintColor: Color(0xff000000).withOpacity(0.2),
        textTheme: TextTheme(
          headline5: TextStyle(fontSize: 22.0, color: Color(0xff000000), height: 1.3),
          headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Color(0xff000000), height: 1.3),
          headline3: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            color: Color(0xff000000),
          ),
          headline2: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Color(0xff000000),
          ),
          headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: Color(0xff000000), height: 1.4),
          subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: Color(0xff000000), height: 1.3),
          headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Color(0xff000000), height: 1.3),
          bodyText2: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Color(0xff000000), height: 1.2),
          bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: Color(0xff000000), height: 1.3),
          caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: Color(0xff000000).withOpacity(0.5), height: 1.2),
        ),
      ),
    );
  }
}
