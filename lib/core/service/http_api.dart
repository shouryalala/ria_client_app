import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/util/logger.dart';
import 'package:http/http.dart' as http;

class HttpApi {
  Log log = new Log('HttpApi');
  static const ERROR_CODE = -1;
  static final String SERVER_ADDRESS = 'https://us-central1-kanta-6f9f5.cloudfunctions.net/';
  static final String REQ_GET_ADHOC_CHARGE = 'getAdhocCharge';

  HttpApi();

  Future<double> getServiceRequestCost(String authToken, Map params) async {
    final response = await sendHttpRequest(REQ_GET_ADHOC_CHARGE, authToken, params);
    if (response == null || response.statusCode == 500) {
      log.error("Request failed: " + response.reasonPhrase);
      return ERROR_CODE.toDouble();
    }
    final responseJson = json.decode(response.body);
    log.debug(responseJson.toString());
    if (responseJson != null && responseJson['cost'] != null && responseJson['cost'] is double) {
      return responseJson['cost'];
    } else {
      log.error('Error parsing recevied http response');
      return ERROR_CODE.toDouble();
    }
  }

  Future<http.Response> sendHttpRequest(String subFunction, String authToken, Map params) async {
    StringBuffer paramStr = new StringBuffer('$SERVER_ADDRESS$subFunction');
    String resLink;
    if (params != null && params.isNotEmpty) {
      paramStr.write('?');
      params.forEach((key, val) {
        paramStr.write('$key=$val&');
      });
      resLink = paramStr.toString();
      resLink = resLink.substring(0,resLink.length-1); //Useless StringBuffer has no provision to remove characters
    } else {
      resLink = paramStr.toString();
    }
    try {
      return await http.get(resLink,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $authToken'});
    } catch (e) {
      log.error('Http Request failed: ' + e.toString());
      return null;
    }
  }
}
