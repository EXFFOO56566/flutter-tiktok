import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leuke/src/helpers/global_keys.dart';
import 'package:leuke/src/repositories/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../controllers/user_controller.dart';
import '../models/edit_profile_model.dart';
import '../models/gender.dart';
import '../repositories/profile_repository.dart' as profRepo;
import '../repositories/user_repository.dart' as userRepo;

class UserProfileController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PanelController pc = new PanelController();
  ValueNotifier<bool> showLoader = new ValueNotifier(false);
  final picker = ImagePicker();
  File image = File("");

  String emailErr = '';
  String nameErr = '';
  String mobileErr = '';
  String genderErr = '';
  String currentPasswordErr = '';
  String newPasswordErr = '';
  String confirmPasswordErr = '';
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';
  ScrollController scrollController = new ScrollController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<ScaffoldState> blockedUserScaffoldKey = GlobalKey<ScaffoldState>();
  UserController userCon = UserController();
  EditProfileModel userProfileCon = new EditProfileModel();
  List<Gender> genders = <Gender>[const Gender('', 'Select'), const Gender('m', 'Male'), const Gender('f', 'Female'), const Gender('o', 'Other')];
  Gender selectedGender = Gender('', 'Select');
  bool showLoadMore = true;

  bool blockUnblockLoader = false;
  /*UserProfileController() {
    fetchLoggedInUserInformation();
  }*/

  @override
  void initState() {
    scrollController = new ScrollController();
    scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_editProfilePage');
    formKey = new GlobalKey<FormState>();
    blockedUserScaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: '_blockedUserScaffoldPage');
    scrollController = new ScrollController();
    super.initState();
  }

  fetchLoggedInUserInformation() async {
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    EditProfileModel userValue = await profRepo.fetchLoggedInUserInformation();

    print("userValue.gender ${userValue.gender} ${userValue.gender.length} ${userValue.userName} ${userValue.name} ${userValue.email} ${userValue.mobile} ${userValue.bio}");
    selectedGender = userValue.gender == 'm'
        ? genders[1]
        : userValue.gender == 'f'
            ? genders[2]
            : userValue.gender == 'o'
                ? genders[3]
                : genders[0];

    usernameController = new TextEditingController(text: userValue.userName);
    nameController = new TextEditingController(text: userValue.name);
    emailController = new TextEditingController(text: userValue.email);
    mobileController = new TextEditingController(text: userValue.mobile);
    bioController = new TextEditingController(text: userValue.bio);
    showLoader.value = false;
    showLoader.notifyListeners();
    setState(() {});
  }

  getImageOption(bool isCamera) async {
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
      } else {
        print('No image selected.');
      }
      // });
    }
    updateProfilePic(image);
  }

  Future updateProfilePic(File file) async {
    userCon = UserController();
    showLoader.value = true;
    showLoader.notifyListeners();
    var value = await profRepo.updateProfilePic(file);
    showLoader.value = false;
    showLoader.notifyListeners();
    print("updateProfilePic $value");
    var response = json.decode(value);
    if (response['status'] == 'success') {
      // setState(() {
      profRepo.usersProfileData.value.smallProfilePic = response['small_pic'];
      profRepo.usersProfileData.value.largeProfilePic = response['large_pic'];
      profRepo.usersProfileData.notifyListeners();
      // });
      userRepo.currentUser.value.userDP = response['large_pic'];
      userRepo.currentUser.notifyListeners();

      userCon.refreshMyProfile();
    } else {
      showLoader.value = false;
      showLoader.notifyListeners();
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There are some error to upload file"),
      ));
    }
  }

  Future<void> update() async {
    if (profRepo.usersProfileData.value.name.contains(" ")) {
      var nameArr = profRepo.usersProfileData.value.name.split(' ');
      profRepo.usersProfileData.value.firstName = nameArr[0];
      profRepo.usersProfileData.value.lastName = nameArr[1];
    } else {
      profRepo.usersProfileData.value.firstName = profRepo.usersProfileData.value.name;
      profRepo.usersProfileData.value.lastName = "";
    }

    profRepo.usersProfileData.value.appToken = userRepo.currentUser.value.token;
    profRepo.usersProfileData.notifyListeners();
    showLoader.value = true;
    showLoader.notifyListeners();
    profRepo.update(profRepo.usersProfileData.value.toJson()).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      var response = json.decode(value);
      if (response['status'] == 'success') {
        Navigator.of(scaffoldKey.currentContext!).popAndPushNamed('/my-profile');
      } else {
        showLoader.value = false;
        showLoader.notifyListeners();
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
          content: Text(response['msg']),
        ));
      }
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There is some error updating profile"),
      ));
    });
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
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (emailErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        emailErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (mobileErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        mobileErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (genderErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        genderErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (currentPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        currentPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (newPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        newPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              (confirmPasswordErr != "")
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        confirmPasswordErr,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    )
                  : SizedBox(
                      height: 0,
                    ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Container(
                    height: 25,
                    width: 50,
                    decoration: BoxDecoration(color: setting.value.buttonColor),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            "OK",
                            style: TextStyle(
                              color: setting.value.buttonTextColor,
                              fontSize: 16,
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
          ),
        );
      },
    );
  }

  void onChanged(value) {
    userProfileCon.dob = value;
  }

  Future<void> changePassword() async {
    setState(() {
      showLoader.value = true;
      showLoader.notifyListeners();
    });

    var data = {
      "user_id": userRepo.currentUser.value.userId.toString(),
      "app_token": userRepo.currentUser.value.token,
      "old_password": currentPassword,
      "password": newPassword,
      "confirm_password": confirmPassword,
    };
    profRepo.changePassword(data).then((value) {
      showLoader.value = false;
      showLoader.notifyListeners();
      var response = json.decode(value);
      if (response['status'] == 'success') {
        Navigator.of(scaffoldKey.currentContext!).popAndPushNamed('/my-profile');
      } else {
        showLoader.value = false;
        showLoader.notifyListeners();
        ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
          content: Text(response['msg']),
        ));
      }
    }).catchError((e) {
      showLoader.value = false;
      showLoader.notifyListeners();
      print("Follow Error $e");
      ScaffoldMessenger.of(GlobalVariable.navState.currentContext!).showSnackBar(SnackBar(
        content: Text("There are som error"),
      ));
    });
  }

  getblockedUsers(int page) async {
    showLoader.value = true;
    showLoader.notifyListeners();
    scrollController = new ScrollController();
    userRepo.getBlockedUsers(page).then((userValue) {
      showLoader.value = false;
      showLoader.notifyListeners();
      if (userValue.users.length == userValue.totalRecords) {
        showLoadMore = false;
      }
      scrollController.addListener(() {
        if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
          if (userValue.users.length != userValue.totalRecords && showLoadMore) {
            page = page + 1;
            getblockedUsers(page);
          }
        }
      });
    });
  }

  blockUnblockUser(userId) async {
    setState(() {
      blockUnblockLoader = true;
    });
    userRepo.blockUser(userId).then((value) async {
      setState(() {
        blockUnblockLoader = false;
      });
      var response = json.decode(value);
      if (response['status'] == 'success') {
        userRepo.userProfile.value.blocked = response['block'] == 'Block' ? 'no' : 'yes';
        userRepo.userProfile.notifyListeners();
        userRepo.blockedUsersData.value.users.removeWhere((element) => element.id == userId);
        userRepo.blockedUsersData.notifyListeners();
        blockedUserScaffoldKey.currentState!.showSnackBar(SnackBar(
          content: Text(response['msg']),
        ));
      } else {
        blockedUserScaffoldKey.currentState!.showSnackBar(SnackBar(
          content: Text("There are some error"),
        ));
      }
    });
  }
}
