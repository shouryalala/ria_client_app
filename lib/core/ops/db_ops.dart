import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/core/model/user_stats.dart';
import 'package:flutter_app/core/model/user_status.dart';
import 'package:flutter_app/core/service/api.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';

import '../../util/locator.dart';
import '../../util/logger.dart';
import '../model/assistant.dart';
import '../model/user.dart';
import '../model/visit.dart';

class DBModel extends ChangeNotifier {
  Api _api = locator<Api>();
  final Log log = new Log("DBModel");
  ValueChanged<UserState> userStatusUpdated;
  ///Adds a new Request and updates the current user activity status
  Future<bool> pushRequest(String userId, Request request) async {
    try {
      Map<String, dynamic> userActMap = UserState(visitStatus: Constants.VISIT_STATUS_SEARCHING).toJson();
      Map<String, dynamic> requestMap = request.toJson();
      CalendarUtil cal = CalendarUtil();
      String yearDoc = cal.getCurrentYear();
      String monthSubColn = cal.getCurrentMonthCode();

      await _api.batchAddRequestVisitUserActivity(userId, userActMap, yearDoc, monthSubColn, requestMap);
      //var result = await _api.addRequestDocument(request.toJson());
      return true;
    }catch(error) {
      return false;
    }
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

  /*Future<UserState> getUserActivityStatus(User user) async{
    try{
      //String id = user.mobile;
      String id = user.uid;
      var doc = await _api.getUserActivityDocument(id);
      return UserState.fromMap(doc.data);
    }catch(e) {
      log.error("Failed to fetch user activity status: " + e.toString());
      return null;
    }
  }*/

  bool subscribeUserActivityStatus(User user) {
    try{
      //String id = user.mobile;
      String id = user.uid;
      Stream<DocumentSnapshot> stream = _api.getUserActivityDocumentStream(id);
      stream.listen((snapshot) {
        if(userStatusUpdated != null && snapshot != null
            && snapshot.data != null && snapshot.data.length>0)
            userStatusUpdated(UserState.fromMap(snapshot.data));
      });
      return true;
    }catch(e) {
      log.error("Failed to subscribe to user activity status: " + e.toString());
      return false;
    }
  }

  addUserStatusListener(ValueChanged<UserState> listener) {
    userStatusUpdated = listener;
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

  Future<bool> updateUserActivityState(String userId, UserState userState) async{
    try {
      log.debug("Rating unavailable. Only updating user status");
      await _api.updateUserState(userId, userState.toJson());
      return true;
    }catch(e) {
      log.error("Failed to update user activity status: " + e.toString());
      return false;
    }
  }

  ///if rating = 0 , visit rating was skipped
  Future<bool> rateVisitAndUpdateUserState(String userId, String astId, String visPath, int rating, String fdbk) async{
    if(rating == 0) {
      /*try {
        log.debug("Rating unavailable. Only updating user status");
        Map<String, dynamic> userActMap = {UserState.fldVisitStatus: Constants.VISIT_STATUS_NONE,
          UserState.fldModifiedTime: FieldValue.serverTimestamp()};
        await _api.updateUserState(userId, userActMap);
        return true;
      }catch(e) {
        log.error("Failed to update user activity status: " + e.toString());
        return false;
      }*/
      return updateUserActivityState(userId, new UserState(visitStatus: Constants.VISIT_STATUS_NONE, modifiedTime: Timestamp.now()));
    }
    else{
      try {
        log.debug("Batching rating and updation of user status");
        List<String> vPath = visPath.split("/");
        if (vPath[0] == null || vPath[1] == null || vPath[2] == null ||
            vPath[3] == null) return null;
        Map<String, dynamic> userActMap = {'visit_status': Constants.VISIT_STATUS_NONE,
          'modified_time': Timestamp.now()};
        Map<String, dynamic> ratingMap = {'rating': rating};
        Map<String, dynamic> fdbkMap;
        if(fdbk != null && fdbk.isNotEmpty) {
          fdbkMap = {'fdbk': fdbk,
          'timestamp': FieldValue.serverTimestamp(),
          'user_id': userId};
        }
        await _api.batchVisitUserActivityFeedbackUpdate(
            userId, astId, vPath[1], vPath[2], vPath[3], userActMap, ratingMap, fdbkMap);
        return true;
      }catch(e) {
        log.error("Batch commit for rating and updating user activity status failed: " + e.toString());
      }
    }
    return false;
  }

  Future<bool> logDeviceId(String userId) async{
    try {
      String meid = await DeviceId.getMEID;
      if (meid != null && meid.isNotEmpty){
        await _api.updateDeviceLog(meid, userId);
        log.debug("DeviceID logged successfully");
        return true;
      }
      return false;
    }catch(e) {
      log.error("Platform Exception(?) while trying to fetch meid: " + e.toString());
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

  Stream<QuerySnapshot> getUserVisitHistory(String id){
    try {
      CalendarUtil cal = CalendarUtil();
      String yearDoc = cal.getCurrentYear();
      String monthSubColn = cal.getCurrentMonthCode();
      return _api.getUserVisitDocuments(id, yearDoc, monthSubColn);
    }catch(e) {
      log.error('Stream fetch failed: ' + e.toString());
    }
  }

  ///User provided General Feedback..updated to Feedback collection
  Future<bool> submitFeedback(String userId, String fdbk) async{
    try {
      Map<String, dynamic> fdbkMap = {'user_id': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'fdbk': fdbk};
        await _api.addFeedbackDocument(fdbkMap);
        return true;
    }catch(e) {
      log.error(e.toString());
      return false;
    }
  }

  Future<bool> requestCallback(String userId, String mobile) async{
    try {
      Map<String, dynamic> callbackMap = {'user_id': userId,
        'timestamp': Timestamp.now(),
        'mobile': mobile};
      await _api.addCallbackDocument(callbackMap);
      return true;
    }catch(e) {
      log.error(e.toString());
      return false;
    }
  }

  Future<bool> cancelVisitUpdateStatus(String userId, Visit visit) async{
    try{
      String path = visit.path;
      List<String> vPath = path.split("/");
      if(vPath[0] == null || vPath[1] == null || vPath[2] == null || vPath[3] == null)return false;
      Map<String, dynamic> userActMap = UserState(visitStatus: Constants.VISIT_STATUS_NONE).toJson();
      Map<String, dynamic> visMap = {
        Visit.fldStatus: Constants.VISIT_STATUS_CANCELLED,
        Visit.fldCncldByUser: true
      };  //visit status ends at cancelled
      await _api.batchVisitUserActivityFeedbackUpdate(userId, visit.aId, vPath[1], vPath[2], vPath[3], userActMap, visMap, null);
      return true;
    }catch(e) {
      log.error(e.toString());
      return false;
    }
  }

  Future<UserStats> getUserStats(String userId) async{
    try{
      var doc = await _api.getUserStatsDocument(userId);
      return UserStats.fromMap(doc.data);
    }catch(e) {
      log.error(e.toString());
      return null;
    }
  }

}
