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

  Future<Map> getHomeStatus() async{
    try{
      String res = await _api.readHomeStatusFile();
      if(res == null || res.isEmpty){
        log.error("Couldnt fetch homestatus file string");
        return null;
      }
      List<String> parts = res.split('\$');
      if(parts.length != 2 || parts[0].length != 1 ) {
        log.error("Invalid cached home status format");
        return null;
      }
      try{
        int status = int.parse(parts[0]);
        String vPath = parts[1];
        log.debug('Received Home Status entities:: Status: ${status}, Path: ${vPath}');
        return {'visit_status':status, 'visit_id': vPath};
      }catch(e) {
        log.error("Failed to convert status part to int");
        return null;
      }
    }catch(e) {
      log.error("Unable to fetch home Status/visit path from local store." + e.toString());
      return null;
    }
  }

  Future<bool> saveHomeStatus(int status, String vPath) async{
    try{
      if(status == null)return false;
      if(vPath == null) vPath = '';   //might be null for default home state
      String res = status.toString() + '\$' + vPath;   //1$2020/02/....
      await _api.writeHomeStatusFile(res);
      return true;
    }catch(e) {
      log.error("Failed to store home status to local cache: " + e.toString());
      return false;
    }
  }

}