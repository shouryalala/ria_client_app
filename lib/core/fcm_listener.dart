import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';
import 'db_model.dart';
import 'local_db_model.dart';

class FcmListener{
  Log log = new Log("FcmListener");
  BaseUtil baseUtil = locator<BaseUtil>();
  LocalDBModel _lModel = locator<LocalDBModel>();
  DBModel _dbModel = locator<DBModel>();
  FcmHandler handler = locator<FcmHandler>();
  FirebaseMessaging _fcm;
  
  FcmListener() {
    _setupFcm();
  }
  
  Future<FirebaseMessaging> _setupFcm() async {
    _fcm = FirebaseMessaging();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        log.debug("onMessage recieved: " + message.toString());
        if(message['data'] != null) {
          handler.handleMessage(message['data']);
        }
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

    if(baseUtil.myUser != null && baseUtil.myUser.mobile != null)await _saveDeviceToken();
    return _fcm;
  }

  _saveDeviceToken() async {
    bool flag = true;
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null && baseUtil.myUser != null && baseUtil.myUser.mobile != null
        && (baseUtil.myUser.client_token == null || (baseUtil.myUser.client_token != null && baseUtil.myUser.client_token != fcmToken))) {
      log.debug("Updating FCM token to local and server db");
      baseUtil.myUser.client_token = fcmToken;
      flag = await _dbModel.updateClientToken(baseUtil.myUser, fcmToken);
      if(flag)await _lModel.saveUser(baseUtil.myUser);  //user cache has client token field available
    }
    return flag;
  }

  FirebaseMessaging get fcm => _fcm;

  set fcm(FirebaseMessaging value) {
    _fcm = value;
  }

}