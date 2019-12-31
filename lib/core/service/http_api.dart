import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/util/logger.dart';
import 'package:http/http.dart' as http;

class HttpApi{
  Log log = new Log('HttpApi');
  static const ERROR_CODE = -1;

  HttpApi();

  Future<double> getServiceRequestCost(String authToken, String serviceCde, String socId, String reqTime) async{
    try {
      final response = await http.get('https://us-central1-kanta-6f9f5.cloudfunctions.net/getAdhocCharge?service=$serviceCde&socId=$socId&reqTime=$reqTime',
          headers: {HttpHeaders.authorizationHeader: 'Bearer $authToken'});
      if(response.statusCode == 500) {
        log.error("Request failed: " + response.reasonPhrase);
        return ERROR_CODE.toDouble();
      }
      final responseJson = json.decode(response.body);
      //return int.parse(responseJson.cost);
      log.debug(responseJson.toString());
      if(responseJson != null && responseJson['cost'] != null) {
        if(responseJson['cost'] is double) {
          return responseJson['cost'];
        }
      }else{
        return ERROR_CODE.toDouble();
      }
    }catch(e) {
      log.error('getRequestCost op failed: ' + e.toString());
      return ERROR_CODE.toDouble();
    }
    return ERROR_CODE.toDouble();
  }


}