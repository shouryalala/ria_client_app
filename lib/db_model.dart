import 'package:flutter/material.dart';
import 'package:flutter_app/model/request.dart';

import 'api.dart';
import 'locator.dart';

class DBModel extends ChangeNotifier{
  Api _api = locator<Api>();

  Future pushRequest(Request request) async{
    var result = await _api.addRequestDocument(request.toJson());
    return ;
  }
}