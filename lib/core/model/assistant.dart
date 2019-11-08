import 'dart:collection';

import 'package:flutter_app/util/logger.dart';

class Assistant {
  static Log log = new Log("Assistant");
  String _id;
  String _name;
  String _mobile;
  int _comp_visits;
  int _age;
  double _rating;
  String _url;  //generated from Firebase Storage
  //client token not needed
  static final String fldId = "id";
  static final String fldAge = "age";
  static final String fldCmpVisits = "comp_visits";
  static final String fldMobile = "mobile";
  static final String fldName = "name";
  static final String fldRating = "rating";
  static final String fldDpUrl = "dp_url";

  Assistant(this._id, this._name, this._mobile, this._age, this._comp_visits, this._rating);

  Assistant.fromMap(Map<String, dynamic> data, String id)
      : this(id, data[fldName], data[fldMobile], data[fldAge], data[fldCmpVisits], data[fldRating]);

  toFileString() {
    StringBuffer oContent = new StringBuffer();
    oContent.writeln(fldId + "\$" + _id.trim());
    oContent.writeln(fldName + "\$" + _name.trim());
    if(_mobile != null)oContent.writeln(fldMobile + "\$" + _mobile.trim());
    if(_age != null)oContent.writeln(fldAge + "\$" + _age.toString());
    if(_comp_visits != null)oContent.writeln(fldCmpVisits + "\$" + _comp_visits.toString());
    if(_rating != null)oContent.writeln(fldRating + "\$" + _rating.toString());
    if(_url != null)oContent.writeln(fldDpUrl + "\$" + _url.toString());
    log.debug("Generated FileWrite String: " + oContent.toString());
    return oContent.toString();
  }

  static Assistant parseFile(List<String> contents) {
    try {
      Map<String, dynamic> gData = new HashMap();
      String id;
      for (String line in contents) {
        if (line.contains(fldId)) {
          id = line.split("\$")[1];
          continue;
        }
        if (line.contains(fldRating)) {
          List<String> res = line.split("\$");
          gData.putIfAbsent(res[0], () {
            return (res[1] != null && res[1].length > 0)? double.parse(res[1]): "";
          });
          continue;
        }
        else if (line.contains(fldCmpVisits) || line.contains(fldAge)) {
          List<String> res = line.split("\$");
          String key = res[0];
          int yFld = (res[1] != null) ? int.parse(res[1]) : -1;
          gData.putIfAbsent(key, () {
            return (yFld != -1) ? yFld : null;
          });
          continue;
        }
        else {
          List<String> res = line.split("\$");
          gData.putIfAbsent(res[0], () {
            return (res[1] != null && res[1].length > 0) ? res[1] : "";
          });
          continue;
        }
      }
      return Assistant.fromMap(gData, id);
    } catch (e) {
      log.error(
          "Caught Exception while parsing local Assistant file: " + e.toString());
      return null;
    }
  }

  double get rating => _rating;

  set rating(double value) {
    _rating = value;
  }

  int get age => _age;

  set age(int value) {
    _age = value;
  }

  int get comp_visits => _comp_visits;

  set comp_visits(int value) {
    _comp_visits = value;
  }

  String get mobile => _mobile;

  set mobile(String value) {
    _mobile = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }


  String get url => _url;

  set url(String value) {
    _url = value;
  }

  @override
  String toString() {
    return 'Assistant{_id: $_id, _name: $_name, _mobile: $_mobile, _comp_visits: $_comp_visits, _age: $_age, _rating: $_rating}';
  }
}