import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/util/logger.dart';

class UserStats{
  Log log = new Log('UserStats');
  final int _compVisits;
  final int _totalMins;
  static const String fldCompVisits = 'comp_visits';
  static const String fldTotalMins = 'total_mins';

  UserStats({@required compVisits, @required totalMins}):
        _compVisits = compVisits,
        _totalMins = totalMins;


  UserStats.fromMap(Map<String, dynamic> data): this(
      compVisits: data[fldCompVisits],
      totalMins: data[fldTotalMins]
  );

  toJson() {
    return {
      fldCompVisits: compVisits,
      fldTotalMins: totalMins
    };
  }

  bool isValid() {return (this.totalMins != null && this.compVisits != null);}

  toFileString() {
    return compVisits.toString() + '\$' + totalMins.toString();
  }

  int get totalMins => _totalMins;

  int get compVisits => _compVisits;

}