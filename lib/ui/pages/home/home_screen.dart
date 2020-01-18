import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/http_ops.dart';
import 'package:flutter_app/ui/pages/home/upcoming_visit_layout.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../core/ops/db_ops.dart';
import '../../../util/constants.dart';
import 'home_layout.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onLoginRequest;
  int homeState;
  HomeScreen({this.onLoginRequest, this.homeState});
  @override
  _HomeScreenState createState() {
    return _HomeScreenState(onLoginRequest: onLoginRequest, homeState: homeState);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final Log log = new Log("HomeScreen");
  final ValueChanged<int> onLoginRequest;
  int homeState;
  _HomeScreenState({this.onLoginRequest, this.homeState});

  DBModel reqProvider;
  BaseUtil baseProvider;
  FcmHandler handler;
  HttpModel httpProvider;
  CalendarUtil cUtil;
  /// Possible UI States
  /// - Default Home screen
  /// - Assistant matched and enroute
  /// - Visit ongoing wasaa
  /// - Visit Cancelled by Assistant
  /// - Visit Completed. Rate Assistant
  ///

  //TODO add call assistant button, add internet connection background checker, add device_id fetch and storer, fix navigation back on exit
  @override
  void initState() {
    super.initState();
    homeState = (homeState == null)?Constants.VISIT_STATUS_NONE:homeState;
    cUtil = new CalendarUtil();
  }

  @override
  Widget build(BuildContext context) {
    reqProvider = Provider.of<DBModel>(context);
    baseProvider = Provider.of<BaseUtil>(context);
    handler = Provider.of<FcmHandler>(context);
    if(handler != null) {
      handler.setHomeScreenCallback(onAssistantAvailable: (state) => onAssistantAvailable(state));  //register callback to allow handler to notify change in ui
    }
    switch(homeState) {
      case Constants.VISIT_STATUS_NONE: {
       return buildHomeLayout();
      }
      case Constants.VISIT_STATUS_UPCOMING:{
        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
        return UpcomingVisitLayout(upVisit: baseProvider.currentVisit, upAssistant: baseProvider.currentAssistant);
      }
      case Constants.VISIT_STATUS_ONGOING:{
        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
        return buildOngoingVisitLayout(baseProvider.currentVisit, baseProvider.currentAssistant);
      }
      default: return buildHomeLayout();
    }
  }

  Widget buildHomeLayout() {
    return HomeLayout(onRequestConfirmed: (request){
      this._onRequestConfirmed(request);
    },onLoginRequest: (pageNo) {
      this.onLoginRequest(pageNo);
    });
  }

  Widget buildOngoingVisitLayout(Visit onVisit, Assistant onAssistant) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            color: Colors.white10,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Service Ongoing!',
                    style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                    textAlign: TextAlign.center,),
                  Text('Your Visit is Ongoing \nFrom:' + baseProvider.decodeTime(onVisit.vis_st_time) + ' to ' + baseProvider.decodeTime(onVisit.vis_en_time),
                    style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ),
        ],
       )
      ),
    );
  }

  Widget buildCancelledVisitLayout(Visit canVisit, Assistant canAssistant) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                color: Colors.white10,
              ),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Service Ongoing!',
                          style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,),
                        Text('Your Visit has been Cancelled by: ' + canAssistant.name + '\n Would you like to request for a different Assistant?',
                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 4.0,
                          child: Text('Request Again'),
                          onPressed: () {
                            Request req = Request(
                                user_id: baseProvider.myUser.uid,
                                user_mobile: baseProvider.myUser.mobile,
                                date: cUtil.now.day,
                                service: canVisit.service,
                                address: baseProvider.myUser.flat_no,
                                society_id: baseProvider.myUser.society_id,
                                req_time: baseProvider.encodeTimeRequest(new DateTime.now()),
                                timestamp: FieldValue.serverTimestamp());

                            req.addException(canAssistant.id);
                            reqProvider.pushRequest(req);

                          },
                        ),
                      ],
                    ),
                  )
              ),
            ],
          )
      ),
    );
  }

  //Callback from HomeLayout
  _onRequestConfirmed(Request req) {
    //TODO do some quick verifications
    reqProvider.pushRequest(req);
  }

  //state changer when request is confirmed
  onAssistantAvailable(state) {
    setState(() {
      homeState = state;
    });
  }

}

