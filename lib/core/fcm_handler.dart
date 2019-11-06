import 'package:flutter/cupertino.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import 'local_db_model.dart';
import 'model/visit.dart';

class FcmHandler extends ChangeNotifier {
  Log log = new Log("FcmHandler");
  LocalDBModel _lModel = locator<LocalDBModel>();
  BaseUtil _baseUtil = locator<BaseUtil>();
  static VoidCallback aUpdate;

  void handleMessage(Map<String, dynamic> data) {
    log.debug("Data Message Recieved: " + data.toString());
    String command = data['command'];
    if(command != null && command.isNotEmpty) {
      switch(command) {
        case Constants.COMMAND_REQUEST_CONFIRMED: {
          log.debug("Request Confirmed!");
          //create Visit object
          Visit recVisit;
          try {
            recVisit = new Visit(
              path: data[Visit.fldVID],
              aId: data[Visit.fldAID],
              uId: data[Visit.fldUID],
              req_st_time: int.parse(data[Visit.fldReqStTime]),   //all values received as Strings
              vis_st_time: int.parse(data[Visit.fldVisStTime]),
              vis_en_time: int.parse(data[Visit.fldVisEnTime]),
              date: int.parse(data[Visit.fldDate]),
              service: data[Visit.fldService],
              status: int.parse(data[Visit.fldStatus]),
            );
          }catch(error) {
            log.error("Caught exception trying to create Visit object from data message: " + error.toString());
          }
          if(recVisit != null && recVisit.path != null && recVisit.path.isNotEmpty) {
            //save visit
            _lModel.saveVisit(recVisit);
            //refresh Home Screen UI if its available
            _baseUtil.currentVisit = recVisit;
            if(aUpdate != null) {
              aUpdate();
            }
          }
        }
      }
    }
  }

  setHomeScreenCallback({VoidCallback onAssistantAvailable}) {
    aUpdate = onAssistantAvailable;
  }
}