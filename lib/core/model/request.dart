import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/util/constants.dart';

class Request{
  final String service;
  final String user_id;
  final String user_mobile;
  final int bhk;
  final int date;
  final String address;
  final String society_id;
  final String asn_response = Constants.AST_RESPONSE_NIL;
  final String status = Constants.REQ_STATUS_UNASSIGNED;
  final int req_time;
  final FieldValue timestamp;
  double cost;
  List exceptions;

  Request({this.service, this.user_id, this.user_mobile, this.bhk, this.date, this.address, this.society_id,
       this.req_time, this.timestamp, this.cost});

  //never used
  Request.fromMap(Map<String, dynamic> data, String id)
    : this(
    service: data['service'],
    user_id: data['user_id'],
    user_mobile: data['user_mobile'],
    bhk: data['bhk'],
    date: data['date'],
    address: data['address'],
    society_id: data['society_id'],
    req_time: data['req_time'],
    timestamp: data['timestamp'],
    cost: data['cost']
  );

  toJson() {
    return {
      'service': service,
      'user_id': user_id,
      'user_mobile': user_mobile,
      'bhk': bhk,
      'date': date,
      'address': address,
      'society_id': society_id,
      'asn_response': asn_response,
      'status': status,
      'req_time': req_time,
      'timestamp': timestamp,
      'cost': cost,
      'rejections': exceptions,
    };
  }

  void addException(String aId) {
    if(exceptions == null || exceptions.length == 0) {
      exceptions = [aId];
    }
    else{
      exceptions.add(aId);
    }
  }

}