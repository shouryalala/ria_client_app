
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/service/http_api.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

class HttpModel extends ChangeNotifier{
  HttpApi _api = locator<HttpApi>();
  final Log log = new Log('HttpModel');

  Future<int> getRequestCost(Request request) async{
     return await _api.getServiceRequestCost(request.service, request.society_id, request.req_time.toString());
  }
}