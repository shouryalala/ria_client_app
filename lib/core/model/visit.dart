import 'dart:collection';
import 'dart:math';

import 'package:flutter_app/util/logger.dart';

class Visit{
  static Log log = new Log("Visit");
  //Only keeping the required fields in the visit object. Not storing all fields fetched from Document.
  final String path;
  final String uId;
  final String aId;
  final int date;
  final int req_st_time;
  final int vis_st_time;
  final int vis_en_time;
  final String service;
  final double cost;
  //final String society_id;
  int status;
  bool cncld_by_user;

  static final String fldVID = "visit_path"; //for local saving
  static final String fldAID = "ass_id";
  static final String fldUID = "user_id";
  static final String fldDate = "date";
  static final String fldReqStTime = "req_st_time";
  static final String fldVisStTime = "vis_st_time";
  static final String fldVisEnTime = "vis_en_time";
  static final String fldService = "service";
  //static final String fldSocietyId = "society_id";
  static final String fldStatus = "status";
  static final String fldCost = "cost";
  static final String fldCncldByUser = "cncld_by_user";

  static List<String> _intFldList = [ fldDate, fldReqStTime, fldVisStTime, fldVisEnTime, fldStatus];  //needed for local storage

  Visit({this.path, this.aId, this.date, this.req_st_time, this.vis_st_time,
      this.vis_en_time, this.service, this.status, this.cost, this.uId});

  //to parse from server/cache
  Visit.fromMap(Map<String, dynamic> data, String path) : this (
    path: path,
    aId: data[fldAID],
    date: data[fldDate],
    req_st_time: data[fldReqStTime],
    vis_st_time: data[fldVisStTime],
    vis_en_time: data[fldVisEnTime],
    service: data[fldService],
    status: data[fldStatus],
    cost: data[fldCost],
    uId: data[fldUID],
  );

  //to send to server
  toJson() {
    return {
      fldAID: aId,
      fldUID: uId,
      fldService: service,
      fldStatus: status,
      fldReqStTime: req_st_time,
      fldVisStTime: vis_st_time,
      fldVisEnTime: vis_en_time,
      fldDate: date,
      fldCost: cost,
      fldCncldByUser: cncld_by_user,
    };
  }

  //to save to cache
  String toFileString() {
    StringBuffer oContent = new StringBuffer();
    oContent.writeln(fldVID + '\$' + path.trim());
    if(aId != null)oContent.writeln(fldAID + '\$' + aId.trim());
    if(uId != null)oContent.writeln(fldUID + '\$' + uId.trim());
    if(service != null)oContent.writeln(fldService + '\$' + service.trim());
    if(status != null)oContent.writeln(fldStatus + '\$' + status.toString());
    if(date != null)oContent.writeln(fldDate + '\$' + date.toString());
    if(cost != null)oContent.writeln(fldCost + '\$' + cost.toString());
    if(req_st_time != null)oContent.writeln(fldReqStTime + '\$' + req_st_time.toString());
    if(vis_st_time != null)oContent.writeln(fldVisStTime + '\$' + vis_st_time.toString());
    if(vis_en_time != null)oContent.writeln(fldVisEnTime + '\$' + vis_en_time.toString());
    //NOt saving cancelled as that will be the last stage for a visit and wont need saving
    log.debug("Generated FileWrite String: " + oContent.toString());
    return oContent.toString();
  }

  static Visit parseFile(List<String> contents) {
    try {
      Map<String, dynamic> gData = new HashMap();
      String path;
      for (String line in contents) {
        if (line.contains('$fldVID\$')) {
          path = line.split('\$')[1];
          continue;
        }
        if (line.contains('$fldAID\$') || line.contains('$fldUID\$') || line.contains('$fldService\$')) {
          List<String> res = line.split('\$');
          gData.putIfAbsent(res[0], () {
            return (res[1] != null && res[1].length > 0) ? res[1] : '';
          });
          continue;
        }
        else if(line.contains('$fldCost\$')) {
          String costStr = line.split('\$')[1];
          if(costStr != null && costStr.isNotEmpty) {
            gData.putIfAbsent(fldCost, () {
              return (double.parse(costStr));
            });
          }
        }
        else {
          _intFldList.forEach((fld) {
            if(line.contains('$fld\$')) {
              gData.putIfAbsent(fld, () {
                String res = line.split('\$')[1];
                return (res != null && res.length > 0) ? int.parse(res) : '';
              });
            }
          });
          continue;
        }
      }
      return Visit.fromMap(gData, path);
    }catch(e) {
      log.error("Caught Exception while parsing local Visit file: " + e.toString());
      return null;
    }
  }



}