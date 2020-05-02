import 'package:flutter/cupertino.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/model/user_status.dart';
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
  static VoidCallback visitComplete;
  static VoidCallback noAstAvailable;
  static VoidCallback serverError;

  FcmHandler() {}

  Future<bool> handleMessage(Map data) async{
    return true;
  }

  /*Future<bool> handleMessage(Map data) async{
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
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(recVisit.aId);  //fetches and caches assistant
//            await _cModel.saveHomeStatus(recVisit.status, recVisit.path);
//            _baseUtil.homeState = recVisit.status; //update baseUtil
            await _baseUtil.updateHomeState(status: recVisit.status, visitPath: recVisit.path);
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
        case Constants.COMMAND_VISIT_ONGOING: case Constants.COMMAND_VISIT_CANCELLED: {
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
          _baseUtil.setupCurrentState(new UserState(visitStatus: status,visitPath: visPath));
          if(aUpdate != null) {
            log.debug("Refreshing Home Screen layout to $command Visit Workflow");
            aUpdate(status);
          }
          //Update the current visit details
          /*_baseUtil.currentVisit = await _baseUtil.getVisit(visPath, true);
          if(_baseUtil.currentVisit != null && _baseUtil.currentVisit.path != null && _baseUtil.currentVisit.path.isNotEmpty){
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(_baseUtil.currentVisit.aId);  //update and cache assistant
            await _baseUtil.updateHomeState(status: status, visitPath: visPath);
            if(_baseUtil.currentAssistant != null){
              if(aUpdate != null) {   //refresh Home Screen UI if available
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
          }*/
          return true;
        }
        case Constants.COMMAND_VISIT_COMPLETED: {
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
          if(status != Constants.VISIT_STATUS_COMPLETED){
            log.error('Invalid Visit status recevied. Skipping request');
            return false;
          }
          //Update the current visit details
          _baseUtil.setupCurrentState(new UserState(visitStatus: status, visitPath: visPath));
          if(visitComplete != null) {   //refresh Home Screen UI if available
            log.debug("Moving to Ratings page");
            visitComplete();
          }
          /*_baseUtil.currentVisit = await _baseUtil.getVisit(visPath, true);
          if(_baseUtil.currentVisit != null && _baseUtil.currentVisit.path != null && _baseUtil.currentVisit.path.isNotEmpty){
            _baseUtil.currentAssistant = await _baseUtil.getAssistant(_baseUtil.currentVisit.aId);  //update and cache assistant
            await _baseUtil.updateHomeState(status: status, visitPath: visPath);
            _baseUtil.homeState = status; //update baseUtil
            if(_baseUtil.currentAssistant != null){
              if(visitComplete != null) {   //refresh Home Screen UI if available
                log.debug("Moving to Ratings page");
                visitComplete();
              }
            }else{
              log.error("Couldnt fetch ongoing/cancelled visit assistant. Discarding message");
              return false;
            }
          }
          else{
            log.error("Couldnt fetch visit object. Discarding message");
            return false;
          }*/
          return true;
        }
        case Constants.COMMAND_MISC_MESSAGE: {
          String type;
          int status;
          try{
            type = data['msg_type'];
            status = int.parse(data[Visit.fldStatus]);
          }catch(error) {
            log.error('Couldnt parse msg_type sent in the MISC MESSAGE command'+  error.toString());
          }
          if(type != null) {
            if(type == Constants.NO_AVAILABLE_AST && noAstAvailable != null) {
              log.debug('No Assistant Availble message received and posting');
              await _baseUtil.updateHomeState(status: status);
              _baseUtil.homeState = status; //update baseUtil
              noAstAvailable();
            }
            else if(type == Constants.SERVER_ERROR && serverError != null) {
              log.debug('Server Error msg recevied and posting');
              await _baseUtil.updateHomeState(status: status);
              //TODO server error should be able to refresh dashboard to any visit layout for future-proofing
              _baseUtil.homeState = status; //update baseUtil
              serverError();
            }
            else{
              log.debug('MISC MESSAGE of type: ' + type + " recevied. Discarding");
            }
          }
          break;
        }
      }
    }
    return true;
  }*/

  setHomeScreenCallback({ValueChanged onVisitStatusChanged}) {
    aUpdate = onVisitStatusChanged;
  }

  setVisitCompleteCallback({VoidCallback onVisitCompleted}) {
    visitComplete = onVisitCompleted;
  }

  setNoAstAvailableCallback({VoidCallback onNoAStAvailableMsg}) {
    noAstAvailable = onNoAStAvailableMsg;
  }

  setServerErrorCallback({VoidCallback onServerErrorMsg}) {
    serverError = onServerErrorMsg;
  }
}