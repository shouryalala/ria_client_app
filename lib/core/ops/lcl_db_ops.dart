import 'package:flutter/material.dart';
import 'package:flutter_app/core/service/lcl_db_api.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import '../model/user.dart';

class LocalDBModel extends ChangeNotifier {
  LocalApi _api = locator<LocalApi>();
  final Log log = new Log("LocalDBModel");

  Future<User> getUser() async {
    try{
      List<String> contents = await _api.readUserFile();
      return User.parseFile(contents);
    }catch(e) {
      log.error("Unable to fetch user from local store." + e.toString());
      return null;
    }
  }

  Future<bool> saveUser(User user) async{
    try {
      await _api.writeUserFile(user.toFileString());
      return true;
    }catch(e) {
      log.error("Failed to store user details in local db: " + e.toString());
      return false;
    }
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