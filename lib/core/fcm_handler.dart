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
  static ValueChanged<int> aUpdate;

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
          //TODO bruh just send a ping from the server and let this client app make a new call to get the visit object
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
                aUpdate(Constants.VISIT_STATUS_UPCOMING);
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
        case Constants.COMMAND_VISIT_ONGOING: case Constants.COMMAND_VISIT_CANCELLED:{
          String visPath;
          int status;
          try {
            visPath = data[Visit.fldVID];
            status = int.parse(data[Visit.fldStatus]);
          }catch(error){
            log.error("Couldnt parse status int value: "+ error);
          }
          if(visPath == null || visPath.isEmpty) {
            log.error('Couldnt parse visit Path recevied. Skipping request');
            return false;
          }
          if((command == Constants.COMMAND_VISIT_ONGOING && status != Constants.VISIT_STATUS_ONGOING) ||
              command == Constants.COMMAND_VISIT_CANCELLED && status != Constants.VISIT_STATUS_CANCELLED){
            log.error('Invalid Visit status recevied. Skipping request');
            return false;
          }
          //Update the current visit details
          _baseUtil.currentVisit = await _baseUtil.getVisit(visPath, true);
          //}
          if(_baseUtil.currentVisit != null && _baseUtil.currentVisit.path != null && _baseUtil.currentVisit.path.isNotEmpty){
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(_baseUtil.currentVisit.aId);
            if(_baseUtil.currentAssistant != null){
              if(aUpdate != null) {   //refresh Home Screen UI if its available
                log.debug("Refreshing Home Screen layout to $command Visit Workflow");
                aUpdate(status);
              }
            }else{
              log.error("Couldnt fetch ongoing/cancelled visit assistant. Discarding message");
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

  setHomeScreenCallback({ValueChanged onAssistantAvailable}) {
    aUpdate = onAssistantAvailable;
  }
}