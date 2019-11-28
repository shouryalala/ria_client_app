import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/ops/cache_ops.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
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
  CacheModel _cModel = locator<CacheModel>();
  //FirebaseMessaging _fcm;
  FirebaseUser firebaseUser;
  bool isUserOnboarded = false;
  int _homeState;
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
      //_homeState = await _retrieveCurrentStatus();
      //_homeState = (_homeState == null)?Constants.VISIT_STATUS_NONE:_homeState;
      await _setupCurrentState();
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
    log.debug("Recieved Activity Status:: Status: $status");
    switch(status) {
      case Constants.VISIT_STATUS_NONE: {
        //TODO clear existing cache visit object if present
        _homeState = Constants.VISIT_STATUS_NONE;
        break;
      }
      case Constants.VISIT_STATUS_UPCOMING: case Constants.VISIT_STATUS_ONGOING:{
        /**
         * Retrieve Upcoming Visit. Ensure not null
         * Retrieve Upcoming visit Assistant. Ensure not null
         * */
        _homeState = status;
        if(vPath == null){
          log.error("Status in VISIT_STATUS_UPCOMING but no visit id found");
          _homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        this.currentVisit = await getVisit(vPath, false);
        if(this.currentVisit != null && this.currentVisit.status != status) {
          //received stored visit object which has'nt been updated yet
          this.currentVisit = await getVisit(vPath, true);
        }
        if(this.currentVisit == null || this.currentVisit.status != status) {
          log.error("Couldnt identify visit. Defaulting HomeState");
          _homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        this.currentAssistant = await getAssistant(this.currentVisit.aId);
        if(this.currentAssistant == null) {
          log.error("Couldnt identify Upcoming Visit Assistant. Defaulting HomeState");
          _homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        break;
      }
      case Constants.VISIT_STATUS_COMPLETED: {

      }
    }
  }

  //Path of format: visits/YEAR/MONTH/ID
  Future<Visit> getVisit(String vPath, bool refreshCache) async {
    if(vPath == null) return null;
    //first check in cache
    Visit lVisit = await _cModel.getVisit();
    if (lVisit == null || lVisit.path != vPath || refreshCache) {
      log.debug("No local saved visit object/expired visit object/Cache refresh reqd.");
      lVisit = await _dbModel.getVisit(vPath);
      if (lVisit != null) {
        bool flag = await _cModel.saveVisit(lVisit);
        log.debug("Saved fetched visit to local cache: $flag");
      }
    }
    return lVisit;
  }

  Future<Assistant> getAssistant(String aId) async{
    if(aId == null || aId.isEmpty)return null;
    aId = aId.trim();
    //first check the cache
    Assistant lAssistant = await _cModel.getAssistant();
    if(lAssistant == null || lAssistant.id != aId) {
      log.debug("No local saved assistant object or expired assistant object. Updation required");
      lAssistant = await _dbModel.getAssistant(aId);
      if(lAssistant != null) {
        lAssistant.url = await getAssistantDpUrl(aId);
        if (lAssistant.url != null) {
          bool flag = await _cModel.saveAssistant(lAssistant);
          //only save to cache if the assistant was fetched and the url also
          log.debug("Saved fetched assistant object to le cache: $flag");
        }
        else{
          log.error("Couldnt fetch the assistant dp url. Not saving to cache.");
        }
      }
      else{
        log.error("Couldnt fetch assistant. Not saving to cache");
      }
    }
    return lAssistant;
    }

  Future<String> getAssistantDpUrl(String aid) async{
    log.debug("Fetching DP url for assistant: $aid");
    if(aid == null || aid.isEmpty)return null;
    try {
      var ref = FirebaseStorage.instance.ref().child(Constants.ASSISTANT_DP_PATH).child(aid.trim() + ".jpg");
      log.debug(ref.path);
      String uri = (await ref.getDownloadURL()).toString();
      if(uri == null || uri.toString().isEmpty)return null;
      log.debug("Assistant DP Url fetched: $uri");
      return uri.toString();
    }catch(e) {
      log.error("Failed to fetch Storage Download URL: " + e.toString());
      return null;
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
      log.error("User Authentication failed with credential: Error: " + e.toString());
      return false;
    });
  }

  int encodeTimeRequest(DateTime time) {
    return ((time.hour * 3600) + (time.minute * 60));
  }

  String decodeTime(int enTime) {
    if(enTime == null) return Constants.DEFAULT_TIME;
    //45000 = 12:30pm
    int product = (enTime/60).truncate();
    int hours = (product/60).truncate();
    int minutes = (product%60);
    String ap = (hours < 12) ? "am" : "pm";
    return "$hours:$minutes $ap";
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

  int get homeState => _homeState;

  set homeState(int value) {
    _homeState = value;
  }


}