import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/service/http_api.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import '../../base_util.dart';

class HttpModel extends ChangeNotifier{
  HttpApi _api = locator<HttpApi>();
  BaseUtil _baseUtil = locator<BaseUtil>(); //required to fetch client token
  final Log log = new Log('HttpModel');

  Future<double> getRequestCost(Request request) async{
    String idToken;
    if(_baseUtil != null && _baseUtil.firebaseUser != null) {
      idToken = (await _baseUtil.firebaseUser.getIdToken()).token;
      log.debug('Fetched user IDToken: ' + idToken);
    }
    if(idToken != null && idToken.isNotEmpty){
      Map<String, String> params = new Map();
      params['service'] = request.service;
      params['socId'] = request.society_id;
      params['reqTime'] = request.req_time.toString();
      double cost = await _api.getServiceRequestCost(idToken, params);
      return double.parse((cost).toStringAsFixed(2));
    }
    else {
      log.error('Couldnt find a auth id token to be attached with request. Header population failed. Not sending request.');
      return HttpApi.ERROR_CODE.toDouble();
    }
  }
}