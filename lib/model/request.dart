import 'package:flutter/cupertino.dart';

class Request{
  final String service;
  final String user_id;
  final int date;
  final String address;
  final String society_id;
  final String asn_response;
  final String status;
  final int req_time;
  final int timestamp;

  const Request({this.service, this.user_id, this.date, this.address, this.society_id,
      this.asn_response, this.status, this.req_time, this.timestamp});

  Request.fromMap(Map<String, dynamic> data, String id)
    : this(
    service: data['service'],
    user_id: data['user_id'],
    date: data['date'],
    address: data['address'],
    society_id: data['society_id'],
    asn_response: data['asn_response'],
    status: data['status'],
    req_time: data['req_time'],
    timestamp: data['timestamp']
  );

  toJson() {
    return {
      "service": service,
      "user_id": user_id,
      "date": date,
      "address": address,
      "society_id": society_id,
      "asn_response": asn_response,
      "status": status,
      "req_time": req_time,
      "timestamp": timestamp,
    };
  }
}