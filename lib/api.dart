import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';

class Api{
  final Firestore _db = Firestore.instance;
  String path;
  CollectionReference ref;

  Api();

  Future<DocumentReference> addRequestDocument(Map data) {
    //ref = _db.collection('request').document()
    CalendarUtil cal = CalendarUtil();
    ref = _db.collection(Constants.COLN_REQUESTS).document(cal.getCurrentYear()).collection(cal.getCurrentMonthCode());
    ref.add(data);
  }

}