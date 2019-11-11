import 'package:flutter/material.dart';
import 'package:flutter_app/core/service/cache_api.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import '../model/assistant.dart';
import '../model/visit.dart';

class CacheModel extends ChangeNotifier {
  CacheApi _api = locator<CacheApi>();
  final Log log = new Log("LocalDBModel");

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
      await _api.writeAssistantFile(assistant.toFileString());
      return true;
    }catch(e) {
      log.error("Failed to store assistant details in local db: " + e.toString());
      return false;
    }
  }

}