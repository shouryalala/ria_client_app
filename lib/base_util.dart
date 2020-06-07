import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/user_status.dart';
import 'package:flutter_app/core/ops/cache_ops.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/util/connection_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';

import 'core/model/user.dart';
import 'core/model/user_stats.dart';
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
  UserStats userStats;
  UserState currentUserState;
  bool isRequestInitiated = false;
  bool isRerouteRequestInitiated = false;
  static bool _setupTimeElapsed = false;
  static bool isDeviceOffline = false;

  BaseUtil() {
    //init(); //init called during onboarding
  }

  Future init() async {
    //fetch on-boarding status and User details
    firebaseUser = await FirebaseAuth.instance.currentUser();
    isUserOnboarded = await _lModel.isUserOnboarded()==1;
    _myUser = await _lModel.getUser();
    if(_myUser != null && _myUser.mobile != null) {
      this.userStats = await getUserStats(false); //get user statistics
      await setupCurrentState(null);
    }
  }

  /// -Fetches current activity state from user sub-collection
  /// -If there is an upcoming visit, it retrieves/updates the local visit object
  /// -Sets the variable used to decide home layout(Default layout, upcoming visit, ongoing visit etc)
  Future<int> setupCurrentState(UserState res) async {
    ///initialize values with cache stored values first
    UserState currState = await _cModel.getHomeStatus();
    if(currState == null) currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE);
    int cachedStatus = currState.visitStatus; // incase it gets overridden by server fetch
    //int status = (currState != null && currState.visitStatus != null)?currState.visitStatus:Constants.VISIT_STATUS_NONE;
    //String vPath = (currState != null)?currState.visitPath:'';
    //int cachedStatus = status;
    //UserState res = await _dbModel.getUserActivityStatus(_myUser);
    if(res != null){
      log.debug("Overriding cached UserState with the following: " + res.toString());
      currState = res;
    }
    log.debug("Recieved Activity Status:: Status: ${currState.visitStatus}");
    switch(currState.visitStatus) {
      case Constants.VISIT_STATUS_NONE: {
        currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE);
        break;
      }
      case Constants.VISIT_STATUS_UPCOMING:
      case Constants.VISIT_STATUS_ONGOING:
      case Constants.VISIT_STATUS_COMPLETED:
      case Constants.VISIT_STATUS_CANCELLED: {
        /**
         * Retrieve Upcoming Visit. Ensure not null
         * Retrieve Upcoming visit Assistant. Ensure not null
         * */
        //_homeState = currState.visitStatus;
        if(currState.visitPath == null || currState.visitPath.isEmpty){
          log.error("Status in VISIT_STATUS_UPCOMING but no visit id found");
          currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE);
          //updateHomeState(status: Constants.VISIT_STATUS_NONE);
          //_homeState = Constants.VISIT_STATUS_NONE;
          break;
        }
        this.currentVisit = await getVisit(currState.visitPath, false);
        if(this.currentVisit != null && this.currentVisit.status != currState.visitStatus) {
          //received stored visit object which has'nt been updated yet
          this.currentVisit = await getVisit(currState.visitPath, true);
        }
        if(this.currentVisit == null || this.currentVisit.status != currState.visitStatus) {
          log.error("Couldnt identify visit. Defaulting HomeState");
//          _homeState = Constants.VISIT_STATUS_NONE;
          currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE);
          break;
        }
        this.currentAssistant = await getAssistant(this.currentVisit.aId);
        if(this.currentAssistant == null) {
          log.error("Couldnt identify Upcoming Visit Assistant. Defaulting HomeState");
//          _homeState = Constants.VISIT_STATUS_NONE;
          currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE);
          break;
        }
        if(currState.visitStatus == Constants.VISIT_STATUS_COMPLETED
            && cachedStatus != Constants.VISIT_STATUS_COMPLETED) {
          //only triggered once after visit completed
          this.userStats = await getUserStats(true);
        }
        break;
      }
    }
    if(!_verifyHomeState(currState)) {
      log.debug("Expired/Irrelevant state still active. Removing state and defaulting to Home");
      bool flag = await _dbModel.updateUserActivityState(firebaseUser.uid, new UserState(visitStatus: Constants.VISIT_STATUS_NONE));
      if(flag) currState = new UserState(visitStatus: Constants.VISIT_STATUS_NONE); //update cache only if db change went through
    }

    updateHomeState(status: currState.visitStatus, visitPath: currState.visitPath, timestamp: currState.modifiedTime); //await not needed
    return _homeState;
  }

  bool _verifyHomeState(UserState presentState) {
    Timestamp rTime = presentState.modifiedTime;
    if(rTime == null) return true;  //cant verify without timestamp
    DateTime dayTime = rTime.toDate();
    DateTime today = DateTime.now();
    int dtCode = encodeTimeRequest(dayTime);
    int nowCode = encodeTimeRequest(today);
    bool flag = true;
    switch(presentState.visitStatus) {
      case Constants.VISIT_STATUS_NONE:case Constants.VISIT_STATUS_COMPLETED:{
        log.debug("HomeState verification not required");
        break;
      }
      case Constants.VISIT_STATUS_SEARCHING: {
        if(today.day != dayTime.day || nowCode-dtCode > Constants.ALLOWED_VISIT_SEARCH_BUFFER) flag = false;
        break;
      }
      case Constants.VISIT_STATUS_UPCOMING: {
        if(this.currentVisit == null) flag = false;  //visit not available
        if(today.day != dayTime.day || nowCode-this.currentVisit.vis_st_time > Constants.ALLOWED_VISIT_UPCOMING_BUFFER) flag = false;
        break;
      }
      case Constants.VISIT_STATUS_ONGOING: {
        if(this.currentVisit == null) flag = false;  //visit not available
        if(today.day != dayTime.day || nowCode-this.currentVisit.vis_en_time > Constants.ALLOWED_VISIT_ONGOING_BUFFER) flag = false;
        break;
      }
      default: {
        flag = true;
        break;
      }
    }
    return flag;
  }

  Future<UserStats> getUserStats(bool refreshRequired) async{
    UserStats stats = await _lModel.getUserStats();
    if(stats == null || refreshRequired) {
      stats = await _dbModel.getUserStats(firebaseUser.uid);
      if(stats != null && stats.isValid()) {
        _lModel.saveUserStats(stats);
      }else{
        _lModel.saveUserStats(new UserStats(compVisits: 0,totalMins: 0));
      }
    }
    return stats;
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

  Future<bool> updateHomeState({@required int status, String visitPath, Timestamp timestamp}) async{
    try {
      this._homeState = status;
      currentUserState = new UserState(
          visitStatus: status, visitPath: visitPath, modifiedTime: timestamp);
      await _cModel.saveHomeStatus(currentUserState);
      return true;
    }catch(e) {
      log.error('Failed to cache current home status: ' + e.toString());
      return false;
    }
  }

//  isSignedIn() =>  (firebaseUser != null && myUser != null);

  String encodeServiceList(List<String> selectedServiceList) {
    if(selectedServiceList == null || selectedServiceList.isEmpty)return null;
    if(selectedServiceList.length == 1) {
      if(selectedServiceList.contains(Constants.CLEANING)) return Constants.CLEANING_CDE;
      if(selectedServiceList.contains(Constants.UTENSILS)) return Constants.UTENSILS_CDE;
      if(selectedServiceList.contains(Constants.DUSTING)) return Constants.DUSTING_CDE;
    }
    else if(selectedServiceList.length == 2) {
      if(selectedServiceList.contains(Constants.CLEANING) && selectedServiceList.contains(Constants.UTENSILS)) return Constants.CLEAN_UTENSIL_CDE;
      if(selectedServiceList.contains(Constants.CLEANING) && selectedServiceList.contains(Constants.DUSTING)) return Constants.CLEAN_DUST_CDE;
      if(selectedServiceList.contains(Constants.DUSTING) && selectedServiceList.contains(Constants.UTENSILS)) return Constants.DUST_UTENSIL_CDE;
    }
    return Constants.CLEAN_DUST_UTENSIL_CDE;
  }

  String decodeService(String code) {
    switch(code) {
      case Constants.CLEANING_CDE: return Constants.CLEANING;
      case Constants.UTENSILS_CDE: return Constants.UTENSILS;
      case Constants.DUSTING_CDE: return Constants.DUSTING;
      case Constants.CLEAN_UTENSIL_CDE: return Constants.CLEANING +' and ' + Constants.UTENSILS;
      case Constants.CLEAN_DUST_CDE:  return Constants.CLEANING +' and ' + Constants.DUSTING;
      case Constants.DUST_UTENSIL_CDE: return Constants.DUSTING +' and ' + Constants.UTENSILS;
      case Constants.CLEAN_DUST_UTENSIL_CDE: return Constants.CLEANING + ', ' + Constants.DUSTING + ' and ' + Constants.UTENSILS;
      default: return code;
    }
  }

  int validateRequestTime(TimeOfDay time) {
    if(time == null) return Constants.TIME_ERROR_NOT_SELECTED;

    int currentTimeVal = encodeTimeOfDay(TimeOfDay.now());
    int outOfBoundStart = encodeTimeOfDay(Constants.outOfBoundTimeStart);
    int outOfBoundEnd = encodeTimeOfDay(Constants.outOfBoundTimeEnd);
    if(currentTimeVal >= outOfBoundStart && currentTimeVal <= outOfBoundEnd) return Constants.TIME_ERROR_SERVICE_OFF;

    int timeVal = encodeTimeOfDay(time);
    int serviceTimeStart = encodeTimeOfDay(Constants.dayStartTime);
    int serviceTimeEnd = encodeTimeOfDay(Constants.dayEndTime);

    if(timeVal+60 < currentTimeVal)return Constants.TIME_ERROR_PAST; //give a room of one minute while validating
    else if(timeVal < serviceTimeStart || timeVal > serviceTimeEnd)return Constants.TIME_ERROR_OUTSIDE_WINDOW;
    else return Constants.TIME_VERIFIED;
  }

  AuthCredential generateAuthCredential(String verificationId, String smsCode) {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return credential;
  }

  Future<bool> authenticateUser(AuthCredential credential) {
    log.debug("Verification credetials: " + credential.toString());
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

  int encodeTimeOfDay(TimeOfDay tod) {
    return ((tod.hour * 3600) + (tod.minute)*60);
  }

  String decodeTime(int enTime) {
    if(enTime == null) return Constants.DEFAULT_TIME;
    //45000 = 12:30pm
    int product = (enTime/60).truncate();
    int hours = (product/60).truncate();
    int mins = (product%60);
    String minutes = mins.toString().padLeft(2, '0');
    String ap = (hours < 12) ? "am" : "pm";
    hours = (hours <= 12)?hours:hours-12;
    return '$hours:$minutes $ap';
  }
  
  Future<bool> signOut() async{
    try{
      await FirebaseAuth.instance.signOut();
      log.debug('Signed Out Firebase User');
      await _lModel.deleteLocalAppData();
      log.debug('Cleared local cache');
      return true;
    }catch(e) {
      log.error('Failed to clear data/sign out user: ' + e.toString());
      return false;
    }
  }

  showNoInternetAlert(BuildContext context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(
        Icons.error,
        size: 28.0,
        color: Colors.white,
      ),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      title: "No Internet",
      message: "Please check your network connection and try again",
      duration: Duration(seconds: 2),
      backgroundColor: Colors.red,
      boxShadows: [BoxShadow(color: Colors.red[800], offset: Offset(0.0, 2.0), blurRadius: 3.0,)],
    )..show(context);
  }

  showPositiveAlert(String title, String message, BuildContext context) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(
        Icons.flag,
        size: 28.0,
        color: Colors.white,
      ),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      title: title,
      message: message,
      duration: Duration(seconds: 3),
      backgroundGradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.lightBlueAccent, UiConstants.primaryColor]),
//      backgroundColor: Colors.lightBlueAccent,
      boxShadows: [BoxShadow(color: UiConstants.positiveAlertColor, offset: Offset(0.0, 2.0), blurRadius: 3.0,)],
    )..show(context);
  }

  showNegativeAlert(String title, String message, BuildContext context, {int seconds}) {
    Flushbar(
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(
        Icons.assignment_late,
        size: 28.0,
        color: Colors.white,
      ),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      title: title,
      message: message,
      duration: Duration(seconds: seconds??3),
      backgroundColor: UiConstants.negativeAlertColor,
      boxShadows: [BoxShadow(color: UiConstants.negativeAlertColor, offset: Offset(0.0, 2.0), blurRadius: 3.0,)],
    )..show(context);
  }

  static Widget getAppBar() {
    return AppBar(
      elevation: 2.0,
      backgroundColor: Colors.white70,
      iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
      title: Text('${Constants.APP_NAME}',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 30.0)),
    );
  }

  bool isSignedIn() => (firebaseUser != null && firebaseUser.uid != null);

  bool isActiveUser() => (_myUser != null && !_myUser.hasIncompleteDetails());

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