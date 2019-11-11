import 'package:flutter/cupertino.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import 'local_db_ops.dart';
import 'model/visit.dart';

class FcmHandler extends ChangeNotifier {
  Log log = new Log("FcmHandler");
  LocalDBModel _lModel = locator<LocalDBModel>();
  BaseUtil _baseUtil = locator<BaseUtil>();
  static VoidCallback aUpdate;

  FcmHandler() {}

  Future<bool> handleMessage(Map data) async{
    log.debug("Data Message Recieved: " + data.toString());
    String command = data['command'];
    if(command != null && command.isNotEmpty) {
      switch(command) {
        case Constants.COMMAND_REQUEST_CONFIRMED: {
          /**
           * Compile the received Visit object
           * Cache the visit. Update current visit
           * Cache the assistant. Update current assistant
           * Trigger HomeScreen UI change
           * */
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
              status: int.parse(data[Visit.fldStatus]),            );
          }catch(error) {
            log.error("Caught exception trying to create Visit object from data message: " + error.toString());
            return false;
          }
          if(recVisit != null && recVisit.path != null && recVisit.path.isNotEmpty
            && recVisit.aId != null && recVisit.aId.isNotEmpty) {
            _baseUtil.currentVisit = recVisit;
            _baseUtil.currentAssistant = await _baseUtil.getUpcomingAssistant(recVisit.aId);  //retrieve assistant
            if(_baseUtil.currentAssistant != null) {
              _baseUtil.currentAssistant.url = await _baseUtil.getAssistantDpUrl(recVisit.aId);
              await _lModel.saveVisit(_baseUtil.currentVisit); //cache visit
              await _lModel.saveAssistant(_baseUtil.currentAssistant); //cache assistant
              if(aUpdate != null) {   //refresh Home Screen UI if its available
                aUpdate();
              }
              log.debug("Request Confirmed!");
            }else{
              log.error("Couldnt fetch upcoming visit assistant. Discarding message");
              return false;
            }
          }else{
            log.error("Couldnt process newly created visit correctly. Discarding message.");
            return false;
          }
          return true;
        }
      }
    }
    return true;
  }

  setHomeScreenCallback({VoidCallback onAssistantAvailable}) {
    aUpdate = onAssistantAvailable;
  }
}