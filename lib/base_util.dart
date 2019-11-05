import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/local_db_model.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';
import 'dart:io' show Platform;
import 'core/model/user.dart';

class BaseUtil extends ChangeNotifier{
  final Log log = new Log("BaseUtil");
  LocalDBModel _lModel = locator<LocalDBModel>();
  DBModel _dbModel = locator<DBModel>();
  FirebaseMessaging _fcm;
  FirebaseUser firebaseUser;
  bool isUserOnboarded = false;
  User _myUser;

  BaseUtil() {
    init();
  }

  init() async {
    //fetch onboarding status and User details
    firebaseUser = await FirebaseAuth.instance.currentUser();
    isUserOnboarded = await _lModel.isUserOnboarded()==1;
    _myUser = await _lModel.getUser();
    if(_myUser != null && _myUser.mobile != null) {
      await _setupFcm();
      await _retrieveCurrentStatus();
    }
  }

  _retrieveCurrentStatus() async {
    Map<String, dynamic> res = await _dbModel.getUserActivityStatus(_myUser);
    if(res['visit_status'] != null){
      final int key = res['visit_status'];
      switch(key) {
        case Constants.VISIT_STATUS_NONE:
          log.debug("Visit Status: NONE activated");
          break;
        case Constants.VISIT_STATUS_UPCOMING:
          log.debug("Visit Status: UPCOMING activated");
          break;
        case Constants.VISIT_STATUS_ONGOING:
          log.debug("Visit Status: ONGOING activated");
          break;
        default:
          break;
      }
    }
  }

  Future<FirebaseMessaging> _setupFcm() async {
    _fcm = FirebaseMessaging();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        log.debug("onMessage recieved: " + message.toString());
      },
      onLaunch: (Map<String, dynamic> message) async {
        log.debug("onLaunch recieved: " + message.toString());
      },
      onResume: (Map<String, dynamic> message) async {
        log.debug("onResume recieved: " + message.toString());
      },
    );
    //TODO to be tested
    if(Platform.isIOS) {
      _fcm.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
      _fcm.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }

    if(_myUser != null)await _saveDeviceToken();
    return _fcm;
  }

  _saveDeviceToken() async {
    bool flag = true;
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null && _myUser != null && _myUser.mobile != null
        && (_myUser.client_token == null || (_myUser.client_token != null && _myUser.client_token != fcmToken))) {
      log.debug("Updating FCM token to local and server db");
      _myUser.client_token = fcmToken;
      flag = await _dbModel.updateClientToken(_myUser, fcmToken);
      if(flag)await _lModel.saveUser(_myUser);  //user cache has client token field available
    }
    return flag;
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


}