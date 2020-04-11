import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/ui/dialog/form_dialog.dart';
import 'package:flutter_app/ui/elements/request_button.dart';
import 'package:flutter_app/ui/pages/home/cancelled_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/home_layout.dart';
import 'package:flutter_app/ui/pages/home/ongoing_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/rate_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/searching_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/upcoming_visit_layout.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/connection_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../base_util.dart';
import '../../core/fcm_handler.dart';
import '../../core/ops/db_ops.dart';

class Dashboard extends StatefulWidget {
  final ValueChanged<int> onLoginRequest;

  Dashboard({this.onLoginRequest});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Log log = new Log("DashboardHomeLayout");
  BaseUtil baseProvider;
  DBModel reqProvider;
  FcmHandler handler;
  CalendarUtil cUtil = new CalendarUtil();
  int homeState = Constants.VISIT_STATUS_NONE;
  bool _isCallbackInitialized = false;
  StreamSubscription _connectionChangeStream;
  bool _isOffline = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController _defaultHomeRequestButtonController = new RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    _isCallbackInitialized = false;
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      _isOffline = !hasConnection;
    });
  }

  _initListeners() {
    if(_isCallbackInitialized || baseProvider == null)return;
    if (handler != null) {
      _isCallbackInitialized = true;  //requires initialization only once
      handler.setHomeScreenCallback(onVisitStatusChanged: (status) {  //register callback to allow handler to notify change in ui,
        log.debug("Visit Status Changed. Refreshing UI");
        setState(() {
          homeState = status;
        });
      });
      handler.setVisitCompleteCallback(onVisitCompleted: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => RateVisitLayout(
            rateVisit: baseProvider.currentVisit,
            rateAssistant: baseProvider.currentAssistant,
            actionComplete: () {    //handled in RateVisitLayout
//                setState(() {
//                  homeState = Constants.VISIT_STATUS_NONE;
//                });
            })));
      });
      handler.setNoAstAvailableCallback(onNoAStAvailableMsg: () {
        baseProvider.showNegativeAlert('No Assistant Available', 'Please try again in sometime', context, seconds: 5);
        setState(() {
          homeState = Constants.VISIT_STATUS_NONE;
        });
      });
      handler.setServerErrorCallback(onServerErrorMsg: () {
        baseProvider.showNegativeAlert('Internal Error', 'We encountered an issue. Please try again in sometime', context, seconds: 5);
        setState(() {
          homeState = Constants.VISIT_STATUS_NONE;
        });
      });
    }
    if(reqProvider != null) {
      reqProvider.addUserStatusListener((userState) {
        if(userState.visitStatus != null && userState.visitStatus != homeState??baseProvider.homeState) {
          baseProvider.setupCurrentState(userState);
          setState(() {
            homeState = baseProvider.homeState;
          });
        }
      });
      reqProvider.subscribeUserActivityStatus(baseProvider.myUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
    handler = Provider.of<FcmHandler>(context);
    _initListeners();
    homeState = (baseProvider.homeState != null) ? baseProvider.homeState : Constants.VISIT_STATUS_NONE;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white70,
          title: Text('${Constants.APP_NAME}',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('beta',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0)),
                  Icon(Icons.info_outline, color: Colors.black54)
                ],
              ),
            )
          ],
        ),
        body: StaggeredGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: <Widget>[
            (baseProvider.firebaseUser == null ||
                    baseProvider.myUser == null ||
                    baseProvider.myUser.hasIncompleteDetails())
                ? _buildLoginTile()
                : _buildStatsTile(),
            _buildTile(__buildVisitLayout(homeState)),
            _buildHistoryTile(),
            _buildTile(
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Material(
                          color: Colors.amber,
                          shape: CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.feedback,
                                color: Colors.white, size: 30.0),
                          )),
                      Padding(padding: EdgeInsets.only(bottom: 16.0)),
                      Text('Feedback',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0)),
                      Text('Help us improve ',
                          style: TextStyle(color: Colors.black45)),
                    ]),
              ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => FormDialog(
                        title: "Tell us what you think",
                        description: "We'd really appreciate it",
                        buttonText: "Submit",
                        dialogAction: (String fdbk) {
                          if(_isOffline) baseProvider.showNoInternetAlert(context);
                          else{
                            if(fdbk != null && fdbk.isNotEmpty){
                              //feedback submission allowed even if user not signed in
                              reqProvider.submitFeedback((baseProvider.firebaseUser == null || baseProvider.firebaseUser.uid == null)?'UNKNOWN':
                              baseProvider.firebaseUser.uid, fdbk).then((flag) {
                                if(flag) {
                                  baseProvider.showPositiveAlert('Thank You', 'You help us get better!', _scaffoldKey.currentContext);
                                }
                              });
                              Navigator.of(context).pop();
                            }
                          }
                        },
                    ),
                  );
                }
            ),
            _buildTile(
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Options',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24.0)),
                          Text('lorem ipsum',
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                      Material(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Center(
                              child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.settings,
                                color: Colors.white, size: 30.0),
                          )))
                    ]),
              ),
              onTap: () =>Navigator.of(context).pushNamed('/profile')  
                  //Navigator.of(context).push(MaterialPageRoute(builder: (_) => ShopItemsPage())),
            )
          ],
          staggeredTiles: [
            StaggeredTile.extent(2, 110.0),
            //StaggeredTile.fit(2), //for the login button
            StaggeredTile.extent(2, 360.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(1, 180.0),
            StaggeredTile.extent(2, 110.0),
          ],
        ));
  }

  Widget _buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Color(0x802196F3),
        child: InkWell(
            onTap: onTap != null
                ? () {
                HapticFeedback.vibrate();
                if(_isOffline){
                  log.debug('No internet connection.');
                  baseProvider.showNoInternetAlert(context);
                }
                else
                  onTap();
              }: () {
                log.debug('No action set for tile.');
              },
            child: child
        )
    );
  }

  Widget _buildLoginTile() {
    String btnText = "Login";
    int pageNo = 0; //mobile no page
    if (baseProvider.firebaseUser != null) {
      //user logged in but has incomplete details
      btnText = "Confirm Details";
      pageNo = 2; //name input page
    }
    return _buildTile(
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(btnText,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 34.0)),
                    Text('click to ${btnText} ',
                        style: TextStyle(color: Colors.black45)),
                  ],
                ),
                Material(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(24.0),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(Icons.verified_user,
                          color: Colors.white, size: 30.0),
                    )))
              ]),
        ), onTap: () {
      if (widget.onLoginRequest != null) {
        log.debug("onLoginRequest callback for pageNo: " + pageNo.toString());
        widget.onLoginRequest(pageNo);
      }
    });
  }

  Widget _buildStatsTile() {
    return _buildTile(
      //Total Mins used
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Total Mins',
                      style: TextStyle(color: Colors.blueAccent)),
                  Text('49',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 34.0))
                ],
              ),
              Material(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(24.0),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        Icon(Icons.timeline, color: Colors.white, size: 30.0),
                  )))
            ]),
      ),
    );
  }
  
  Widget _buildHistoryTile() {
    return _buildTile(
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Material(
                  color: Colors.teal,
                  shape: CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(Icons.history,
                        color: Colors.white, size: 30.0),
                  )),
              Padding(padding: EdgeInsets.only(bottom: 16.0)),
              Text('History',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.0)),
              Text('Past Visits',
                  style: TextStyle(color: Colors.black45)),
            ]),
      ),
      onTap: () {
        if(_isOffline){
          log.debug('No internet connection.');
          baseProvider.showNoInternetAlert(context);
        }
        else if(!baseProvider.isSignedIn()) {
          log.debug('History clicked:: Not signed in yet');
          baseProvider.showNegativeAlert('Sign In', 'Please Sign in to continue', context);
        }
        else if(!baseProvider.isActiveUser()) {
          log.debug('History Clicked:: Incomplete details');
          baseProvider.showNegativeAlert('Update details', 'Please complete your details to continue', context);
        }
        else
          Navigator.of(context).pushNamed('/history');
      }
    );
  }

  Widget __buildVisitLayout(int homeState) {
    switch (homeState) {
      case Constants.VISIT_STATUS_UPCOMING:
        {
          if (baseProvider.currentVisit == null ||
              baseProvider.currentAssistant == null) return buildHomeLayout();
          return UpcomingVisitLayout(
              upVisit: baseProvider.currentVisit,
              upAssistant: baseProvider.currentAssistant);
        }
      case Constants.VISIT_STATUS_ONGOING:
        {
          if (baseProvider.currentVisit == null ||
              baseProvider.currentAssistant == null) return buildHomeLayout();
          return OngoingVisitLayout(
              onVisit: baseProvider.currentVisit,
              onAssistant: baseProvider.currentAssistant);
        }
      case Constants.VISIT_STATUS_CANCELLED:
        {
          if (baseProvider.currentVisit == null ||
              baseProvider.currentAssistant == null) return buildHomeLayout();
          return CancelledVisitLayout(
              canVisit: baseProvider.currentVisit,
              canAssistant: baseProvider.currentAssistant,
              onRerouteCancelledVisit: (visit) => _rerouteCancelledVisit(visit)
          );
        }
      case Constants.VISIT_STATUS_SEARCHING:
        {
          return SearchingVisitLayout();
        }
//      case Constants.VISIT_STATUS_COMPLETED:  //Wrote shitty code and moved to the initial widget router in the launcher
//        {
//          if (baseProvider.currentVisit == null ||
//              baseProvider.currentAssistant == null) return buildHomeLayout();
//          Navigator.of(context).push(MaterialPageRoute(builder: (_) => RateVisitLayout(
//              rateVisit: baseProvider.currentVisit,
//              rateAssistant: baseProvider.currentAssistant,
//              actionComplete: () {
////                setState(() {
////                  homeState = Constants.VISIT_STATUS_NONE;
////                });
//              })));
//          break;
//        }
      case Constants.VISIT_STATUS_NONE:case Constants.VISIT_STATUS_COMPLETED: default:
        {
          return buildHomeLayout();
        }
    }
  }

  Widget buildHomeLayout() {
    return HomeLayout(
        onInitiateRequest: (params) {
          if(params != null && params.isNotEmpty) {
            try {
              TimeOfDay reqTime = params[HomeLayout.PARAM_TIME];
              String serviceCode = params[HomeLayout.PARAM_SERVICE_CODE];
              //if(reqTime != null && serviceCode != null && serviceCode.isNotEmpty)
                _onInitiateRequest(reqTime, serviceCode);
            }catch(error) {
              log.error('Failed to parse HomeLayout callback Map' + error.toString());
            }
          }
        },
        reqBtnController: _defaultHomeRequestButtonController,
    );
  }

//  buildHomeLayout() {
//    return HomeLayout(onLoginRequest: (pageNo) {
//      //wont need onLoginRequest to be passed on to the HomeLayout either
//      if (widget.onLoginRequest != null) {
//        log.debug("onLoginRequest callback for pageNo: " + pageNo.toString());
//        widget.onLoginRequest(pageNo);
//      }
//    });
//  }

  ///Validate request and show appropirate messages
  bool _validateRequest(TimeOfDay requestTime, String serviceCode) {
    bool flag = true;
    if(_isOffline){
      log.debug('No internet connection.');
      flag = false;
      baseProvider.showNoInternetAlert(context);
    }
    else if(!baseProvider.isSignedIn()) {
      log.debug('Request check:: Not signed in yet');
      flag = false;
      baseProvider.showNegativeAlert('Sign In', 'Please Sign in to continue', context);
    }
    else if(!baseProvider.isActiveUser()) {
      log.debug('Request check:: Incomplete details');
      flag = false;
      baseProvider.showNegativeAlert('Update details', 'Please complete your details to continue', context);
    }
    else if(serviceCode == null){
      log.debug('Request check:: Service code invalid');
      flag = false;
      baseProvider.showNegativeAlert('Action Required', 'Please select atleast one service', context);
    }
    else if(!baseProvider.validateRequestTime(requestTime)) {
      log.debug('Request check:: Invalid Time');
      flag = false;
      baseProvider.showNegativeAlert('Action Required', '${Constants.APP_NAME} is available from ${BaseUtil.dayStartTime.hour}:${BaseUtil.dayStartTime.minute.toString().padLeft(2, '0')} AM '
          'to ${BaseUtil.dayEndTime.hour-12}:${BaseUtil.dayEndTime.minute.toString().padLeft(2, '0')} PM', context);
    }
    return flag;
  }

  void _onInitiateRequest(TimeOfDay requestTime, String serviceCode) {
    if(_validateRequest(requestTime, serviceCode)) {
//    if (baseProvider.firebaseUser == null
//        || baseProvider.myUser == null
//        || baseProvider.myUser.hasIncompleteDetails()
//        || selectedServiceList.isEmpty
//        || !baseProvider.validateRequestTime(requestTime)) { //TODO fix time validation
//      ///validation message to be assigned on priority basis: Not signed in -- Incomplete details -- Service not selected
//      String message;
//      //_selected time validation does'nt need a snack message. done by its validator
//      if(!baseProvider.validateRequestTime(requestTime))message='${Constants.APP_NAME} is available from ${BaseUtil.dayStartTime.hour}:${BaseUtil.dayStartTime.minute.toString().padLeft(2, '0')} AM '
//                  'to ${BaseUtil.dayEndTime.hour-12}:${BaseUtil.dayEndTime.minute.toString().padLeft(2, '0')} PM';
//      if(selectedServiceList.isEmpty)message="Please select atleast one service";
//      if(baseProvider.myUser.hasIncompleteDetails())message="Please add your home address";
//      if(baseProvider.firebaseUser == null) message="Please sign in to continue";
//      if(message!=null)baseProvider.showNegativeAlert('Action required', message, context);
//      return;
//    }
//    if(_isOffline) baseProvider.showNoInternetAlert(context);
      Request req = Request(
          user_id: baseProvider.firebaseUser.uid,
          user_mobile: baseProvider.myUser.mobile,
          date: cUtil.now.day,
          service: serviceCode,
          address: baseProvider.myUser.flat_no,
          society_id: baseProvider.myUser.society_id,
          req_time: baseProvider.encodeTimeOfDay(requestTime),
          timestamp: FieldValue.serverTimestamp());
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) {
            return CostConfirmModalSheet(
                request: req, onRequestConfirmed: (cost) async {
              Navigator.of(context).pop(); //close Cost Sheet
              req.cost = cost;
              log.debug("onRequestConfirmed called for: " + req.toString());
              //if(widget.onPushRequest != null)widget.onPushRequest(req);
              _onConfirmRequest(baseProvider.firebaseUser.uid, req);
              _defaultHomeRequestButtonController.start();  //request button animation
            });
          }
      );
    }
  }

  void _rerouteCancelledVisit(Visit canVisit) async{

  }


  ///Called by CostConfirmModalSheet
  void _onConfirmRequest(String userId, Request request) async{
    if(userId == null || userId.isEmpty || request == null) {
      log.error('Invalid parameters recevied for new request. Skipping request');
      //TODO inform user?
      return;
    }
    log.debug('New push request: ' + request.toString());
    bool flag = await reqProvider.pushRequest(userId, request);
    if(flag) {
      _defaultHomeRequestButtonController.success();
      baseProvider.updateHomeState(status: Constants.VISIT_STATUS_SEARCHING);
      setState(() {
        homeState = Constants.VISIT_STATUS_SEARCHING;
      });
    }
  }

  //state changer when request is confirmed
  onAssistantAvailable(state) {
    setState(() {
      homeState = state;
    });
  }
}
