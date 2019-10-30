class Visit{
  final String id;
  final String address;
  final String aId;
  final int date;
  final int req_st_time;
  final int vis_st_time;
  final int vis_en_time;
  final String service;
  final String society_id;
  final int status;
  final String uId;
  static final String fldVID = "visit_id"; //for local saving
  static final String fldAddress = "address";
  static final String fldAID = "ass_id";
  static final String fldDate = "date";
  static final String fldReqStTime = "req_st_time";
  static final String fldVisStTime = "vis_st_time";
  static final String fldVisEnTime = "vis_en_time";
  static final String fldService = "service";
  static final String fldSocietyId = "society_id";
  static final String fldStatus = "status";
  static final String fldUID = "user_id";

  Visit({this.id, this.address, this.aId, this.date, this.req_st_time, this.vis_st_time,
      this.vis_en_time, this.service, this.society_id, this.status, this.uId});

  Visit.fromMap(Map<String, dynamic> data, String id) : this (
    id: id,
    address: data[fldAddress],
    aId: data[fldAID],
    date: data[fldDate],
    req_st_time: data[fldReqStTime],
    vis_st_time: data[fldVisStTime],
    vis_en_time: data[fldVisEnTime],
    service: data[fldService],
    society_id: data[fldSocietyId],
    status: data[fldStatus],
    uId: data[fldUID],
  );

}