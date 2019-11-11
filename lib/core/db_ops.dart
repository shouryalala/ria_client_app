import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/core/service/api.dart';
import 'package:path_provider/path_provider.dart';

import '../util/locator.dart';
import '../util/logger.dart';
import 'model/assistant.dart';
import 'model/user.dart';
import 'model/visit.dart';

class DBModel extends ChangeNotifier {
  Api _api = locator<Api>();
  final Log log = new Log("DBModel");

  Future pushRequest(Request request) async {
    var result = await _api.addRequestDocument(request.toJson());
    return;
  }

  Future<User> getUser(String id) async {
    try {
      var doc = await _api.getUserById(id);
      return User.fromMap(doc.data, id);
    }catch(e) {
      log.error("Error fetch User details: " + e.toString());
      return null;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      //String id = user.mobile;
      String id = user.uid;
      await _api.updateUserDocument(id, user.toJson());
      return true;
    }catch(e) {
      log.error("Failed to update user object: " + e.toString());
      return false;
    }
  }

  Future<Map> getUserActivityStatus(User user) async{
    try{
      //String id = user.mobile;
      String id = user.uid;
      var doc = await _api.getUserActivityDocument(id);
      return doc.data;
    }catch(e) {
      log.error("Failed to fetch user activity status: " + e.toString());
      return null;
    }
  }

  Future<bool> updateClientToken(User user, String token) async{
    try{
      //String id = user.mobile;
      String id = user.uid;
      var dMap = {
        'token': token,
        'timestamp': FieldValue.serverTimestamp()
      };
      await _api.updateUserClientToken(id, dMap);
      return true;
    }catch(e) {
      log.error("Failed to update User Client Token: " + e.toString());
      return false;
    }
  }

  Future<Visit> getVisit(String path) async {
    try {
      List<String> vPath = path.split("/");
      if(vPath[0] == null || vPath[1] == null || vPath[2] == null || vPath[3] == null)return null;
      var doc = await _api.getVisitByPath(vPath[1], vPath[2], vPath[3]);
      return Visit.fromMap(doc.data, path);
    }catch(e) {
      log.error("Error fetch visit details: " + e.toString());
      return null;
    }
  }

  Future<bool> updateVisit(Visit visit) async {
    try {
      String path = visit.path;
      List<String> vPath = path.split("/");
      if(vPath[0] == null || vPath[1] == null || vPath[2] == null || vPath[3] == null)return false;
      await _api.updateVisitDocument(vPath[1], vPath[2], vPath[3], visit.toJson());
      return true;
    }catch(e) {
      log.error("Failed to update visit object: " + e.toString());
      return false;
    }
  }

  //Assumes city = New Delhi, district = Dwarka
  //ONLY ITERATES ON DWARKA SOCIETIES!
  //cause thats all we need rn
  Future<Map<int, Set<Society>>> getServicingApptList() async {
    try {
      Map<int, Set<Society>> socMap = new HashMap();
      var querySnap = await _api.getSocietyColn();
      querySnap.documents.forEach((doc) {
        String sKey = doc.documentID;
        Society society = Society.fromMap(doc.data, sKey);
        socMap.update(society.sector, (tList) {
          tList.add(society);
          return tList;
        }, ifAbsent: () {
          Set<Society> sList = new HashSet();
          sList.add(society);
          return sList;
        });
      });
      return socMap;
    }catch(e) {
      log.error("Unable to fetch data:" + e.toString());
      return null;
    }
  }

  Future<Assistant> getAssistant(String id) async {
    try {
      var doc = await _api.getAssistantById(id);
      return Assistant.fromMap(doc.data, id);
    }catch(e) {
      log.error("Error fetching assistant details: " + e.toString());
      return null;
    }
  }

}
