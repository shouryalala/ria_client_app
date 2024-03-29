//import 'package:flutter/material.dart';
//import 'package:flutter_app/base_util.dart';
//import 'package:flutter_app/core/fcm_handler.dart';
//import 'package:flutter_app/core/ops/http_ops.dart';
//import 'package:flutter_app/ui/pages/home/ongoing_visit_layout.dart';
//import 'package:flutter_app/ui/pages/home/rate_visit_layout.dart';
//import 'package:flutter_app/ui/pages/home/upcoming_visit_layout.dart';
//import 'package:flutter_app/util/calendar_util.dart';
//import 'package:flutter_app/util/constants.dart';
//import 'package:flutter_app/util/logger.dart';
//import 'package:provider/provider.dart';
//
//import '../../../core/ops/db_ops.dart';
//import '../../../util/constants.dart';
//import 'cancelled_visit_layout.dart';
//import 'home_layout.dart';

//TODO NOT BEING USED!!!!!!!!

//class HomeController extends StatefulWidget {
//  final ValueChanged<int> onLoginRequest;
//  final int homeState;
//  HomeController({this.onLoginRequest, this.homeState});
//  @override
//  _HomeControllerState createState() {
//    return _HomeControllerState(onLoginRequest: onLoginRequest, homeState: homeState);
//  }
//}
//
//class _HomeControllerState extends State<HomeController> {
//  final Log log = new Log("HomeController");
//  final ValueChanged<int> onLoginRequest;
//  int homeState;
//  _HomeControllerState({this.onLoginRequest, this.homeState});
//
//  DBModel reqProvider;
//  BaseUtil baseProvider;
//  FcmHandler handler;
//  HttpModel httpProvider;
//  CalendarUtil cUtil;
//  /// Possible UI States
//  /// - Default Home screen
//  /// - Assistant matched and enroute
//  /// - Visit ongoing wasaa
//  /// - Visit Cancelled by Assistant
//  /// - Visit Completed. Rate Assistant
//  ///
//
//  @override
//  void initState() {
//    super.initState();
//    homeState = (homeState == null)?Constants.VISIT_STATUS_NONE:homeState;
//    cUtil = new CalendarUtil();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    reqProvider = Provider.of<DBModel>(context);
//    baseProvider = Provider.of<BaseUtil>(context);
//    handler = Provider.of<FcmHandler>(context);
//    if(handler != null) {
//      //handler.setHomeScreenCallback(onAssistantAvailable: (state) => onAssistantAvailable(state));  //register callback to allow handler to notify change in ui
//    }
//    switch(homeState) {
//      case Constants.VISIT_STATUS_NONE: {
//       return buildHomeLayout();
//      }
//      case Constants.VISIT_STATUS_UPCOMING:{
//        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
//        return UpcomingVisitLayout(upVisit: baseProvider.currentVisit, upAssistant: baseProvider.currentAssistant);
//      }
//      case Constants.VISIT_STATUS_ONGOING:{
//        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
//        return OngoingVisitLayout(onVisit: baseProvider.currentVisit, onAssistant: baseProvider.currentAssistant);
//      }
//      case Constants.VISIT_STATUS_CANCELLED:{
//        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
//        return CancelledVisitLayout(canVisit: baseProvider.currentVisit, canAssistant: baseProvider.currentAssistant);
//      }
//      case Constants.VISIT_STATUS_COMPLETED:{
//        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
//        return RateVisitLayout(rateVisit: baseProvider.currentVisit, rateAssistant: baseProvider.currentAssistant,
//          actionComplete: () {
//            setState(() {
//              homeState = Constants.VISIT_STATUS_NONE;
//            });
//          });
//      }
//      default: return buildHomeLayout();
//    }
//  }
//
//  Widget buildHomeLayout() {
//    return HomeLayout(onLoginRequest: (pageNo) {
//      this.onLoginRequest(pageNo);
//    });
//  }
//
//  //state changer when request is confirmed
//  onAssistantAvailable(state) {
//    setState(() {
//      homeState = state;
//    });
//  }
//
//}
//
