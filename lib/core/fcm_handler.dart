import 'package:flutter/cupertino.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/ops/cache_ops.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/logger.dart';

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
          if(recVisit != null && recVisit.path != null && recVisit.path.isNotEmpty
            && recVisit.aId != null && recVisit.aId.isNotEmpty) {
            _baseUtil.currentVisit = recVisit;
            _baseUtil.currentAssistant = await _baseUtil.getUpcomingAssistant(recVisit.aId);  //retrieve assistant
            if(_baseUtil.currentAssistant != null) {
              _baseUtil.currentAssistant.url = await _baseUtil.getAssistantDpUrl(recVisit.aId);
              await _cModel.saveVisit(_baseUtil.currentVisit); //cache visit
              await _cModel.saveAssistant(_baseUtil.currentAssistant); //cache assistant
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
          if(_baseUtil.currentVisit.path == null || _baseUtil.currentVisit.path != visPath){
            log.debug("Current Visit details not available to provide to ongoing visit workflow. Needs to be newly fetched");
            _baseUtil.currentVisit = await _baseUtil.getVisit(visPath);
          }
          if(_baseUtil.currentVisit != null && _baseUtil.currentVisit.path != null && _baseUtil.currentVisit.path.isNotEmpty
              && _baseUtil.currentVisit.aId != null && _baseUtil.currentVisit.aId.isNotEmpty) {
            _baseUtil.currentAssistant = await _baseUtil.getUpcomingAssistant(_baseUtil.currentVisit.aId);  //retrieve assistant
            if(_baseUtil.currentAssistant != null) {
              //TODO could cleanup here
              _baseUtil.currentAssistant.url = await _baseUtil.getAssistantDpUrl(_baseUtil.currentVisit.aId);
              await _cModel.saveAssistant(_baseUtil.currentAssistant); //cache assistant
              if(aUpdate != null) {   //refresh Home Screen UI if its available
                log.debug("Refreshing Home Screen layout to Ongoing Visit Workflow");
                aUpdate();
              }
            }else{
              log.error("Couldnt fetch upcoming visit assistant. Discarding message");
              return false;
            }
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