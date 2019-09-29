import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/service/api.dart';

import '../../util/locator.dart';
import '../../util/logger.dart';
import 'user.dart';

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

  Future updateUser(User user) async {
    String id = user.mobile;
    _api.updateUserDocument(id, user.toJson());
    return;
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
}
