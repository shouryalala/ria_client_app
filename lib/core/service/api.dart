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
  
  Future<void> updateUserClientToken(String userId, Map data) {
    ref = _db.collection(Constants.COLN_USERS).document(userId).collection(Constants.SUBCOLN_USER_FCM);
    return ref.document(Constants.DOC_USER_FCM_TOKEN).setData(data);
  }

  Future<void> updateUserStatus(String userId, Map data) {
    ref = _db.collection(Constants.COLN_USERS).document(userId).collection(Constants.SUBCOLN_USER_ACTIVITY);
    return ref.document(Constants.DOC_USER_ACTIVITY_STATUS).setData(data, merge: false);  //fresh doc. remove earlier fields
  }

  Future<void> updateDeviceLog(String devId, String userId) {
    ref = _db.collection(Constants.COLN_USERS);
    Map<String, dynamic> map = {devId : FieldValue.arrayUnion([userId])};
    return ref.document(Constants.DOC_DEVICE_LOG).updateData(map);
  }

  Future<QuerySnapshot> getSocietyColn() {
    ref = _db.collection(Constants.COLN_SOCIETIES);
    return ref.getDocuments();
  }
  /**
   * return Doc:: status:  {visit_id: xyz, visit_status: VISIT_CDE}
   * */
  Future<DocumentSnapshot> getUserActivityDocument(String id) {
    ref = _db.collection(Constants.COLN_USERS).document(id).collection(Constants.SUBCOLN_USER_ACTIVITY);
    return ref.document(Constants.DOC_USER_ACTIVITY_STATUS).get();
  } 

  Future<DocumentSnapshot> getVisitByPath(String yearDoc, String monthSubColn, String id) {
    ref = _db.collection(Constants.COLN_VISITS).document(yearDoc).collection(monthSubColn);
    return ref.document(id).get();
  }

  Future<void> updateVisitDocument(String yearDoc, String monthSubColn, String id, Map data) {
    ref = _db.collection(Constants.COLN_VISITS).document(yearDoc).collection(monthSubColn);
    return ref.document(id).setData(data, merge: true);
  }

  Future<DocumentSnapshot> getAssistantById(String id) {
    ref = _db.collection(Constants.COLN_ASSISTANTS);
    return ref.document(id).get();
  }

  Future<void> batchRateAndUpdateStatus(String userId, String astId, String yearDoc, String monthSubColn, String id, Map statusMap, Map visMap, Map fdbkMap) {
    WriteBatch batch = _db.batch();
    DocumentReference ref1 = _db.collection(Constants.COLN_USERS).document(
        userId).collection(Constants.SUBCOLN_USER_ACTIVITY).document(
        Constants.DOC_USER_ACTIVITY_STATUS);
    DocumentReference ref2 = _db.collection(Constants.COLN_VISITS).document(
        yearDoc).collection(monthSubColn).document(id);
    if (fdbkMap != null) {
      DocumentReference ref3 = _db.collection(Constants.COLN_ASSISTANTS)
          .document(astId).collection(Constants.SUBCOLN_AST_FEEDBACK)
          .document();
      batch.setData(ref3, fdbkMap, merge: false); //each feedback is a doc of its own
    }
    batch.setData(ref1, statusMap, merge: false); //fresh doc. remove earlier fields
    batch.setData(ref2, visMap, merge: true);
    return batch.commit();
  }

  Stream<QuerySnapshot> getUserVisitDocuments(String userId, String yearDoc, String monthSubColn) {
    CollectionReference _cRef = _db.collection(Constants.COLN_VISITS).document(yearDoc).collection(monthSubColn);
    return _cRef.where('userId', isEqualTo: userId).orderBy('timestamp',descending: true).getDocuments().asStream();
  }

  Future<void> addFeedbackDocument(Map data) {
    return _db.collection(Constants.COLN_FEEDBACK).add(data);
  }

  Future<void> addCallbackDocument(Map data) {
    return _db.collection(Constants.COLN_CALLBACK).add(data);
  }
}