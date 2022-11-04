import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leuke/src/repositories/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_controller.dart';
import '../helpers/global_keys.dart';
import '../models/gender.dart';
import '../models/verify_profile_model.dart';
import '../repositories/verify_repository.dart' as verifyRepo;

class VerifyProfileController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PanelController pc = new PanelController();
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  final picker = ImagePicker();

  Gender selectedGender = Gender("M", "Male");
  String name = '';
  String address = '';
  String document1 = '';
  String document2 = '';
  String verified = '';
  String verifiedText = '';
  String submitText = 'Submit';
  String emailErr = '';
  String nameErr = '';
  String addressErr = '';
  String document1Err = '';
  String reason = '';
  ScrollController scrollController = ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  UserController userCon = UserController();
  VerifyProfileModel verifyProfileCon = new VerifyProfileModel();
  ValueNotifier<bool> reload = new ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  fetchVerifyInformation() async {
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    VerifyProfileModel userValue = await verifyRepo.fetchVerifyInformation();
    showLoader.value = false;
    showLoader.notifyListeners();
    // setState(() {
    print("fetchVerifyInformation jsonData $userValue");
    verified = userValue.verified;
    nameController = new TextEditingController(text: userValue.name);
    addressController = new TextEditingController(text: userValue.address);
    name = userValue.name;
    address = userValue.address;
    document1 = userValue.document1;
    document2 = userValue.document2;
    if (userValue.verified == "P") {
      verifiedText = "Pending";
      submitText = "Verification Pending";
    } else if (userValue.verified == "A") {
      verifiedText = "Verified";
      submitText = "Verified Already";
    } else if (userValue.verified == "R") {
      verifiedText = "Rejected";
      submitText = "Re-submit";
      reason = userValue.reason;
    } else {
      verifiedText = "Not Applied";
      submitText = "Submit";
    }

    reload.value = true;
    reload.notifyListeners();
    // });
  }

  getDocument1(bool isCamera) async {
    File image = File("");
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.notifyListeners();
      } else {
        print('No image selected.');
      }
      // });

    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.notifyListeners();
      } else {
        print('No image selected.');
      }
    }
    document1 = image.path;
  }

  getDocument2(bool isCamera) async {
    File image = File("");
    if (isCamera) {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // <- Reduce Image quality
        maxHeight: 1000, // <- reduce the image size
        maxWidth: 1000,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.notifyListeners();
      } else {
        print('No image selected.');
      }
      // });
    } else {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      // setState(() {
      if (pickedFile != null) {
        image = File(pickedFile.path);
        reload.value = true;
        reload.notifyListeners();
      } else {
        print('No image selected.');
      }
      // });
    }
    document2 = image.path;
  }

  Future<void> update() async {
    String patttern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = new RegExp(patttern);
    nameErr = "";
    addressErr = "";
    document1Err = "";
    if (name.length == 0) {
      nameErr = 'Please enter full name';
    } else if (!regExp.hasMatch(name)) {
      nameErr = 'Please enter valid full name';
    }
    if (address.length == 0) {
      addressErr = "Address Field is required";
    } else {
      addressErr = "";
    }
    if (document1.length == 0) {
      document1Err = "Front Side of ID document is required";
    } else {
      document1Err = "";
    }

    if (nameErr == '' && addressErr == '' && document1Err == '') {
      showLoader.value = true;
      showLoader.notifyListeners();
      Map<String, String> data = {};
      data['name'] = name;
      data['address'] = address;
      data['document1'] = document1;
      if (document2 != '') {
        data['document2'] = document2;
      }
      verifyRepo.update(data).then((value) {
        showLoader.value = false;
        showLoader.notifyListeners();
        var response = json.decode(value);
        if (response['status'] == 'success') {
          Navigator.of(scaffoldKey.currentContext!).popAndPushNamed('/verification-page');
        }
      }).catchError((e) {
        showLoader.value = false;
        showLoader.notifyListeners();
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
          content: Text("There is some error"),
        ));
      });
    } else {
      showAlertDialog(scaffoldKey.currentContext!);
    }
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              (nameErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        nameErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (addressErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        addressErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (document1Err != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        document1Err,
                        style: TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 45,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: setting.value.buttonColor,
                    ),
                    child: Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: setting.value.buttonTextColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 20,
                          fontFamily: 'RockWellStd',
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
