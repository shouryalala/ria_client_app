import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/local_db_model.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

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
    _fcm = FirebaseMessaging();
    firebaseUser = await FirebaseAuth.instance.currentUser();
    isUserOnboarded = await _lModel.isUserOnboarded()==1;
    try {
      _myUser = await _lModel.getUser();
    }catch(e) {
      log.error("No file found");
    }
  }

  _saveDeviceToken() async {
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null && _myUser != null && _myUser.mobile != null) {
      _myUser.client_token = fcmToken;
      _dbModel.updateUser(_myUser);
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


}