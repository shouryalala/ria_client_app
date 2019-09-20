import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/local_db_model.dart';
import 'package:flutter_app/util/locator.dart';

import 'core/model/user.dart';

class BaseUtil extends ChangeNotifier{
  LocalDBModel _lModel = locator<LocalDBModel>();
  bool isUserOnboarded = false;
  User myUser;
  //final Log log = new Log("")
  BaseUtil() {
    init();
  }

  init() async {
    //fetch onboarding status and User details
    isUserOnboarded = await _lModel.isUserOnboarded()==1;
    myUser = await _lModel.getUser();
  }
}