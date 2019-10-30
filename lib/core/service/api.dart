import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';

class Api{
  Log log = new Log("Api");
  final Firestore _db = Firestore.instance;
  String path;
  CollectionReference ref;

  Api();

  Future<DocumentReference> addRequestDocument(Map data) {
    //ref = _db.collection('request').document()
    CalendarUtil cal = CalendarUtil();
    ref = _db.collection(Constants.COLN_REQUESTS).document(cal.getCurrentYear()).collection(cal.getCurrentMonthCode());
    return ref.add(data);
  }

  Future<void> updateUserDocument(String docId, Map data) {
    ref = _db.collection(Constants.COLN_USERS);
    return ref.document(docId).setData(data, merge: true);
  }

  Future<DocumentSnapshot> getUserById(String id) {
    ref = _db.collection(Constants.COLN_USERS);
    return ref.document(id).get();
  }

  Future<QuerySnapshot> getSocietyColn() {
    ref = _db.collection(Constants.COLN_SOCIETIES);
    return ref.getDocuments();
  }

  /**
   * return Doc:: status:  {visit_id: xyz, visit_status: VISIT_CDE}
   * */
  Future<DocumentSnapshot> getUserActivityDocument(String id) {
    String activityDocKey = "status"; //fixed document key where we're storing the status
    ref = _db.collection(Constants.COLN_USERS).document(id).collection(Constants.SUBCOLN_USER_ACTIVITY);
    return ref.document(activityDocKey).get();
  }
}