import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/db_model.dart';
import 'package:flutter_app/core/local_db_model.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import 'core/model/user.dart';
import 'core/model/visit.dart';

class BaseUtil extends ChangeNotifier{
  final Log log = new Log("BaseUtil");
  LocalDBModel _lModel = locator<LocalDBModel>();
  DBModel _dbModel = locator<DBModel>();
  //FirebaseMessaging _fcm;
  FirebaseUser firebaseUser;
  bool isUserOnboarded = false;
  int homeState;
  User _myUser;
  Visit _currentVisit;
  Assistant _currentAssistant;

  BaseUtil() {
    //init(); //init called in
  }

  Future init() async {
    //fetch onboarding status and User details
    firebaseUser = await FirebaseAuth.instance.currentUser();
    isUserOnboarded = await _lModel.isUserOnboarded()==1;
    _myUser = await _lModel.getUser();
    if(_myUser != null && _myUser.mobile != null) {
      //homeState = await _retrieveCurrentStatus();
      //homeState = (homeState == null)?Constants.VISIT_STATUS_NONE:homeState;
      homeState = await _setupCurrentState();
    }
  }

  /**
   * -Fetches current activity state from user subcollection
   * -If there is an upcoming visit, it retrieves/updates the local visit object
   * -Sets the variable used to decide home layout(Default layout, upcoming visit, ongoing visit etc)
   * */
  Future<int> _setupCurrentState() async {
    int status = Constants.VISIT_STATUS_NONE;
    String vPath;
    Map<String, dynamic> res = await _dbModel.getUserActivityStatus(_myUser);
    try {
      status = res['visit_status'];
      vPath = res['visit_id'];
    }catch(e) {
      log.debug("Didnt find the activity subcollection. Defaulting values");
      status = Constants.VISIT_STATUS_NONE;
    }
    log.debug("Recieved Activity Status:: Status: $status.toString()");
    switch(status) {
      case Constants.VISIT_STATUS_NONE: {
        //TODO clear existing cache visit object if present
        homeState = Constants.VISIT_STATUS_NONE;
        break;
      }
      case Constants.VISIT_STATUS_UPCOMING: {
        /**
         * Retrieve Upcoming Visit. Ensure not null
         * Retrieve Upcoming visit Assistant. Ensure not null
         * */
        homeState = Constants.VISIT_STATUS_UPCOMING;
        if(vPath == null){
          log.error("Status in VISIT_STATUS_UPCOMING but no visit id found");
          homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        this.currentVisit = await getUpcomingVisit(vPath);
        if(this.currentVisit == null) {
          log.error("Couldnt identify Upcoming visit. Defaulting HomeState");
          homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        this.currentAssistant = await getUpcomingAssistant(this.currentVisit.aId);
        if(this.currentAssistant == null) {
          log.error("Couldnt identify Upcoming Visit Assistant. Defaulting HomeState");
          homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        break;
      }
      case Constants.VISIT_STATUS_COMPLETED: {

      }
    }
  }

  //Path of format: visits/YEAR/MONTH/ID
  Future<Visit> getUpcomingVisit(String vPath) async {
    if(vPath == null) return null;
    //first check in cache
    Visit lVisit = await _lModel.getVisit();
    if (lVisit == null || lVisit.path != vPath) {
      log.debug("No local saved visit object or expired visit object. Updation required");
      Visit nVisit = await _dbModel.getVisit(vPath);
      if (nVisit != null) {
        bool flag = await _lModel.saveVisit(nVisit);
        log.debug("Saved fetched visit to local cache: $flag");
        return nVisit;
      }
    }
    return lVisit;
  }

  Future<Assistant> getUpcomingAssistant(String aId) async{
    if(aId == null)return null;
    //first check the cache
    Assistant lAssistant = await _lModel.getAssistant();
    if(lAssistant == null || lAssistant.id != aId) {
      log.debug("No local saved assistant object or expired assistant object. Updation required");
      Assistant nAssistant = await _dbModel.getAssistant(aId);
      if(nAssistant != null) {
        bool flag = await _lModel.saveAssistant(nAssistant);
        log.debug("Saved fetched assistant object to le cache: $flag");
        return nAssistant;
      }
    }
    return lAssistant;
  }

  isSignedIn() =>  (firebaseUser != null && myUser != null);

  AuthCredential generateAuthCredential(String verificationId, String smsCode) {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return credential;
  }

  Future<bool> authenticateUser(AuthCredential credential) {
    return FirebaseAuth.instance.signInWithCredential(credential).then((res) {
      this.firebaseUser = res.user;
      return true;
    }).catchError((e) {
      log.error("User Authentication failed with credential: Error: " + e.toString());
      return false;
    });
  }

  int encodeTimeRequest(DateTime time) {
    return ((time.hour * 3600) + (time.minute * 60));
  }

  User get myUser => _myUser;

  set myUser(User value) {
    _myUser = value;
  }

  Visit get currentVisit => _currentVisit;

  set currentVisit(Visit value) {
    _currentVisit = value;
  }

  Assistant get currentAssistant => _currentAssistant;

  set currentAssistant(Assistant value) {
    _currentAssistant = value;
  }

}