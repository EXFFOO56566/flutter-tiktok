# flutter-tiktok

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Setup

In order to set up the project, please follow below steps:

### Flutter setup

1. Upgrade flutter to newest version
```
flutter upgrade
```

2. Install package dependencies:
```
flutter pub get
```

3. Run the project by running command:
```
flutter run
```

4. Use one of these commands to build the project:
```
flutter build ios
flutter build apk
flutter build appbundle
```

5. If any issue (run the below command to troubleshoot):
```
flutter doctor
```


#### Google map setup

1. To use Google Maps in your Flutter app, you need to configure an API project with the [Google Maps Platform](https://cloud.google.com/maps-platform/), following both the [Maps SDK for Android's Get API key](https://developers.google.com/maps/documentation/android-sdk/get-api-key), and [Maps SDK for iOS' Get API key](https://developers.google.com/maps/documentation/ios-sdk/get-api-key) processes. With API keys in hand, carry out the following steps to configure both Android and iOS applications.
2. To add an API key to the Android app, edit the ```AndroidManifest.xml``` file in ```android/app/src/main```. Add a single meta-data entry containing the API key created in the previous step.
3. To add an API key to the iOS app, edit the ```AppDelegate.swift``` file in ```ios/Runner```. Unlike Android, adding an API key on iOS requires changes to the source code of the Runner app. The AppDelegate is the core singleton that is part of the app initialization process.



For help getting started with Flutter, check [online documentation](https://flutter.dev/docs), which offers great tutorials, samples, guidance on mobile development, and a full API reference. If you run into any issue or question, feel free to reach out to us via email info@tochycomputerservices.com

### Flutter packages used in FlutKit:

* shared_preferences
* provider
* cupertino_icons
* material_design_icons_flutter
* charts_flutter
* google_fonts
* google_maps_flutter
