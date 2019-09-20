import 'package:flutter/material.dart';
import 'package:flutter_app/model/request.dart';

import '../service/api.dart';
import '../util/locator.dart';
import 'user.dart';
import '../util/logger.dart';

class DBModel extends ChangeNotifier{
  Api _api = locator<Api>();
  final Log log = new Log("DBModel");

  Future pushRequest(Request request) async{
    var result = await _api.addRequestDocument(request.toJson());
    return ;
  }

  Future<User> getUser(String id) async{
    var doc = await _api.getUserById(id);
    return User.fromMap(doc.data, id);
  }

}