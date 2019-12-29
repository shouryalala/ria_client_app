import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/util/logger.dart';
import 'package:http/http.dart' as http;

class HttpApi{
  Log log = new Log('HttpApi');

  HttpApi();

  Future<int> getServiceRequestCost(String serviceCde, String socId, String reqTime) async{
    try {
      final response = await http.get('https://us-central1-kanta-6f9f5.cloudfunctions.net/getAdhocCharge?service=$serviceCde&socId=$socId&reqTime=$reqTime',
          headers: {HttpHeaders.authorizationHeader: 'yoyoy'});
      final responseJson = json.decode(response.body);
      return int.parse(responseJson.cost);
    }catch(e) {
      log.error('getRequestCost op failed: ' + e);
      return -1;
    }
  }
}