class OnlineUsersModel {
  int id = 0;
  String name = '';
  String userDp = '';
  bool online = false;
  int convId = 0;
  OnlineUsersModel();

  OnlineUsersModel.fromJson(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] ?? 0;
      name = jsonMap['name'] ?? '';
      userDp = jsonMap['user_dp'] ?? '';
    } catch (e) {
      print(e);
    }
  }
}
