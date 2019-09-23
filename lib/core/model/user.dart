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
  final Map<String, dynamic> userMap;
  static final Log log = new Log("OnboardingPage");

  User(this._mobile, this._name, this._email, this._bhk, this._flat_no,
    this._society_id, this._sector, this._district, this._client_token,[this.userMap]);

  static List<String> fldList = [ fldEmail, fldName, fldBhk, fldFlat_no, fldSector, fldSociety_id,
  fldDistrict, fldClient_token];

  User.fromMap(Map<String, dynamic> data, String id) :
    this(id, data[fldName], data[fldEmail], data[fldBhk], data[fldFlat_no],
        data[fldSociety_id], data[fldSector], data[fldDistrict], data[fldClient_token], data
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
    };
  }

  static User parseFile(List<String> contents) {
    Map<String, dynamic> gData;
    String id;
    contents.forEach((line) {
      if(line.contains(fldId)) {
        id =  line.split("\$")[1];
      }
      fldList.forEach((fld) {
        if(line.contains(fld)) {
          gData.putIfAbsent(fld, () {
            String res = line.split("\$")[1];
            return (res != null && res.length>0)?res:" ";
          });
        }
      });
    });
    return User.fromMap(gData, id);
  }

  String toFileString() {
    StringBuffer oContent;
    oContent.write(fldId + "\$" + _mobile + "\n");
    fldList.forEach((fld) {
      oContent.write(fld);
      oContent.write("\$");
      oContent.write(this.userMap[fld]);
      oContent.write("\n");
    });
    log.debug("Generated FileWrite String: " + oContent.toString());
    return oContent.toString();
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