import 'package:flutter/material.dart';
import 'package:flutter_app/core/service/local_api.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import 'model/assistant.dart';
import 'model/user.dart';
import 'model/visit.dart';

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

  Future<Visit> getVisit() async {
    try{
      List<String> contents = await _api.readVisitFile();
      return Visit.parseFile(contents);
    }catch(e) {
      log.error("Unable to fetch visit from local store." + e.toString());
      return null;
    }
  }

  //overwrites existing visit text file
  Future<bool> saveVisit(Visit visit) async {
    try {
      await _api.writeVisitFile(visit.toFileString());
      return true;
    }catch(e) {
      log.error("Failed to store visit details in local db: " + e.toString());
      return false;
    }
  }

  Future<Assistant> getAssistant() async{
    try{
      List<String> contents = await _api.readAssistantFile();
      return Assistant.parseFile(contents);
    }catch(e) {
      log.error("Unable to fetch visit from local store." + e.toString());
      return null;
    }
  }

  Future<bool> saveAssistant(Assistant assistant) async {
    try {
      await _api.writeVisitFile(assistant.toFileString());
      return true;
    }catch(e) {
      log.error("Failed to store assistant details in local db: " + e.toString());
      return false;
    }
  }

}