import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/util/logger.dart';

class UserState{
  Log log = new Log('UserState');
  final int _visitStatus;
  final String _visitPath;
  final Timestamp _modifiedTime;
  static const String fldVisitStatus = 'visit_status';
  static const String fldVisitPath = 'visit_id';
  static const String fldModifiedTime = 'modified_time';

  UserState({@required visitStatus, visitPath='', modifiedTime}):
        //assert (_visitStatus != null && _visitStatus is int),
        _visitStatus = visitStatus,
        _visitPath = visitPath,
        _modifiedTime = modifiedTime??Timestamp.now();  //TODO not sure if this gets called everytime

  UserState.fromMap(Map<String, dynamic> data): this(
    visitStatus: data[fldVisitStatus],
    visitPath: data[fldVisitPath],
    modifiedTime: data[fldModifiedTime]
  );

  toJson() {
    return {
      fldVisitStatus: visitStatus,
      fldVisitPath: (visitPath.isEmpty)?null:visitPath,
      //fldModifiedTime: modifiedTime??FieldValue.serverTimestamp()
      fldModifiedTime: modifiedTime
    };
  }

  toFileString() {
    return visitStatus.toString() + '\$' + visitPath + '\$' + _modifiedTime.millisecondsSinceEpoch.toString();
  }

  Timestamp get modifiedTime =>_modifiedTime??Timestamp.now();

  String get visitPath => _visitPath;

  int get visitStatus => _visitStatus;

}