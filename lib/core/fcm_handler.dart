import 'package:flutter/cupertino.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/ops/cache_ops.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

import 'model/assistant.dart';
import 'model/visit.dart';

class FcmHandler extends ChangeNotifier {
  Log log = new Log("FcmHandler");
  //LocalDBModel _lModel = locator<LocalDBModel>();
  CacheModel _cModel = locator<CacheModel>();
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
              status: int.parse(data[Visit.fldStatus]),
            );
          }catch(error) {
            log.error("Caught exception trying to create Visit object from data message: " + error.toString());
            return false;
          }
          if(recVisit != null && recVisit.path != null && recVisit.path.isNotEmpty){
            _baseUtil.currentVisit = recVisit;
            await _cModel.saveVisit(_baseUtil.currentVisit); //cache visit
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(recVisit.aId);
            if(_baseUtil.currentAssistant != null){
              if(aUpdate != null) {   //refresh Home Screen UI if its available
                log.debug("Refreshing Home Screen layout to Upcoming Visit Workflow");
                aUpdate();
              }
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
        case Constants.COMMAND_VISIT_ONGOING: {
          String visPath;
          int status;
          try {
            visPath = data[Visit.fldVID];
            status = int.parse(data[Visit.fldStatus]);
          }catch(error){
            log.error("Couldnt parse status int value: "+ error);
          }
          if(visPath == null || status != Constants.VISIT_STATUS_ONGOING) {
            log.error("Couldnt parse visit Path/Invalid status recevied. Skipping");
            return false;
          }
          if(_baseUtil.currentVisit == null || _baseUtil.currentVisit.path == null || _baseUtil.currentVisit.path != visPath){
            log.debug("Current Visit details not available to provide to ongoing visit workflow. Needs to be newly fetched");
            _baseUtil.currentVisit = await _baseUtil.getVisit(visPath);
          }
          if(_baseUtil.currentVisit != null && _baseUtil.currentVisit.path != null && _baseUtil.currentVisit.path.isNotEmpty){
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(_baseUtil.currentVisit.aId);
            if(_baseUtil.currentAssistant != null){
              if(aUpdate != null) {   //refresh Home Screen UI if its available
                log.debug("Refreshing Home Screen layout to Ongoing Visit Workflow");
                aUpdate();
              }
            }else{
              log.error("Couldnt fetch ongoing visit assistant. Discarding message");
              return false;
            }
          }
          else{
            log.error("Couldnt fetch visit object. Discarding message");
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