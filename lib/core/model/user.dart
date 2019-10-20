import 'dart:collection';

import 'package:flutter_app/util/logger.dart';

class User{
  String _mobile;
  String _name;
  String _email;
  int _bhk;
  String _flat_no;
  String _society_id;
  int _sector;
  String _district;
  String _client_token;
  static final String fldId = "mID";
  static final String fldEmail = "mEmail";
  static final String fldName = "mName";
  static final String fldBhk = "mBHK";
  static final String fldFlat_no = "mFlatNo";
  static final String fldSociety_id = "mSocietyID";
  static final String fldSector = "mSector";
  static final String fldDistrict = "mDistrict";
  static final String fldClient_token = "mClientToken";
  //final Map<String, dynamic> userMap;
  static final Log log = new Log("OnboardingPage");

//  User(this._mobile, this._name, this._email, this._bhk, this._flat_no,
//    this._society_id, this._sector, this._district, this._client_token,[this.userMap]);
  User(this._mobile, this._name, this._email, this._bhk, this._flat_no,
      this._society_id, this._sector, this._district, this._client_token);

  static List<String> fldList = [ fldEmail, fldName, fldBhk, fldFlat_no, fldSector, fldSociety_id,
  fldDistrict, fldClient_token];

  User.newUser(String mobile) : this(mobile, null, null, null, null, null, null, null, null);

  User.fromMap(Map<String, dynamic> data, String id) :
    this(id, data[fldName], data[fldEmail], data[fldBhk], data[fldFlat_no],
        data[fldSociety_id], data[fldSector], data[fldDistrict], data[fldClient_token]
  );

  String get mobile => _mobile;

  set mobile(String value) {
    _mobile = value;
  }

  toJson() {
    return {
      fldName: _name,
      fldEmail: _email,
      fldBhk: _bhk,
      fldFlat_no: _flat_no,
      fldSector: _sector,
      fldSociety_id: _society_id,
      fldDistrict: _district,
      fldClient_token: _client_token
    };
  }

  static User parseFile(List<String> contents) {
    Map<String, dynamic> gData = new HashMap();
    String id;
    for(String line in contents){
      if(line.contains(fldId)) {
        id =  line.split("\$")[1];
        continue;
      }
      else if(line.contains(fldBhk) || line.contains(fldSector)) {
        String key = line.split("\$")[0];
        String xFld = line.split("\$")[1];
        int yFld = (xFld != null)?int.parse(xFld):-1;
        gData.putIfAbsent(key, () {
          return (yFld != -1)?yFld:null;
        });
        continue;
      }
      else {
        fldList.forEach((fld) {
          if (line.contains(fld)) {
            gData.putIfAbsent(fld, () {
              String res = line.split("\$")[1];
              return (res != null && res.length > 0) ? res : " ";
            });
          }
        });
      }
    };
    return User.fromMap(gData, id);
  }

  String toFileString() {
    StringBuffer oContent = new StringBuffer();
    oContent.writeln(fldId + "\$" + _mobile);
    if(_email != null) oContent.writeln(fldEmail + "\$" +_email);
    if(_name != null) oContent.writeln(fldName + "\$" + _name);
    if(_flat_no != null)oContent.writeln(fldFlat_no + "\$" + _flat_no);
    if(_society_id != null)oContent.writeln(fldSociety_id + "\$" + _society_id);
    if(_sector != null)oContent.writeln(fldSector + "\$" + _sector.toString());
    if(_bhk != null)oContent.writeln(fldBhk + "\$" + _bhk.toString());
    if(_district != null)oContent.writeln(fldDistrict + "\$" + _district);
    if(_client_token != null)oContent.writeln(fldClient_token + "\$" + _client_token);
//    fldList.forEach((fld) {
//      if(this.userMap[fld] != null) {
//        oContent.write(fld);
//        oContent.write("\$");
//        oContent.write(this.userMap[fld]);
//        oContent.write("\n");
//      }
//    });
    log.debug("Generated FileWrite String: " + oContent.toString());
    return oContent.toString();
  }

  bool hasIncompleteDetails() {
    //TODO removed email and district from complusion
    return ((_name?.isEmpty??true) || (_bhk == null || bhk < 1) || (_flat_no?.isEmpty??true)
        || (_society_id?.isEmpty??true) || (_sector == null ));
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  int get bhk => _bhk;

  set bhk(int value) {
    _bhk = value;
  }

  String get flat_no => _flat_no;

  set flat_no(String value) {
    _flat_no = value;
  }

  String get society_id => _society_id;

  set society_id(String value) {
    _society_id = value;
  }

  int get sector => _sector;

  set sector(int value) {
    _sector = value;
  }

  String get district => _district;

  set district(String value) {
    _district = value;
  }

  String get client_token => _client_token;

  set client_token(String value) {
    _client_token = value;
  }
}