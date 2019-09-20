import 'package:flutter/material.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import '../service/local_api.dart';
import 'user.dart';

class LocalDBModel extends ChangeNotifier {
  LocalApi _api = locator<LocalApi>();
  final Log log = new Log("LocalDBModel");

  Future<User> getUser() async {
    try{
      final file = await _api.userFile;
      List<String> contents = await file.readAsLines();
      return User.parseFile(contents);
    }catch(e) {
      log.error("Unable to fetch user from local store." + e);
      return null;
    }
  }

  Future saveUser(User user) async{
   return _api.writeUserFile(user.toFileString());
  }

  Future<int> isUserOnboarded() async {
    try {
      final file = await _api.onboardFile;

      String contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      log.error("Didnt find onboarding flag. Defaulting to 0.");
      return 0;
    }
  }

  Future saveOnboardStatus(bool flag) async {
    // Write the file
    int status = (flag)?1:0;
    return _api.writeOnboardFile('$status');
  }
}