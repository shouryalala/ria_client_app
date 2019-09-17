import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'api.dart';
import 'locator.dart';
import 'model/user.dart';
import 'util/logger.dart';

class UserDetails extends ChangeNotifier{
  User myUser;
  Api _api = locator<Api>();
  final Log log = new Log("UserDetails");

  UserDetails(){
    log.debug("Entered this bad boy");
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _userFile async {
    final path = await _localPath;
    return File('$path/userdetails.txt');
  }

  Future<User> getUser() async {
    try{
      final file = await _userFile;
      List<String> contents = await file.readAsLines();
      myUser = User.parseFile(contents);
    }catch(e) {
      return null;
    }
  }

  Future<File> writeUser(User user) async {
    final file = await _userFile;
    return file.writeAsString(user.toFileString());
  }
}