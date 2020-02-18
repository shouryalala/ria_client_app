import 'package:flutter_app/util/constants.dart';

class Society{
  final String sId;
  final String enName;
  final String hiName;
  final int sector;
  final int plot;

  const Society({this.sId, this.enName, this.hiName, this.sector, this.plot});

  Society.fromMap(Map<String, dynamic> data, String id) : this (
    sId: id,
    enName: data[Constants.APPT_FIELD_LANG_EN],
    hiName: data[Constants.APPT_FIELD_LANG_HI],
    plot: data[Constants.APPT_FIELD_PLOT],
    sector: data[Constants.APPT_FIELD_SECTOR]
  );
}