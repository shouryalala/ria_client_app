import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/db_model.dart';
import 'package:flutter_app/core/local_db_model.dart';
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
    Map<String, dynamic> res = await _dbModel.getUserActivityStatus(_myUser);
    int status = res['visit_status'];
    String vPath = res['visit_id'];
    log.debug("Recieved Activity Status:: Status: " + status.toString() + " Visit ID Path: " + vPath);
    if(status != null) {
      if(status == Constants.VISIT_STATUS_NONE) {
        //TODO clear existing cache visit object if present
        return Constants.VISIT_STATUS_NONE;
      }
      else if(status == Constants.VISIT_STATUS_UPCOMING) {
        if(vPath == null){
          log.error("Status in VISIT_STATUS_UPCOMING but no visit id found");
          return Constants.VISIT_STATUS_NONE;
        }
        //Path of format: visits/YEAR/MONTH/ID
        Visit lVisit = await _lModel.getVisit();
        if(lVisit == null || lVisit.path != vPath) {
          log.debug("No local saved visit object or expired visit object. Updation required");
          Visit nVisit = await _dbModel.getVisit(vPath);
          if(nVisit != null){
            await _lModel.saveVisit(nVisit);
            this.currentVisit = nVisit;
            //done
          }else{
            return Constants.VISIT_STATUS_NONE;
          }
        }else{
          //visit available in local cache
          this.currentVisit = lVisit;
        }
        return Constants.VISIT_STATUS_UPCOMING;
      }
      else{
        return Constants.VISIT_STATUS_NONE;
      }
    }
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
      log.error("User Authentication failed with credential: Error: " + e);
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
}