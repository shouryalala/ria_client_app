import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/elements/form_dialog.dart';
import 'package:flutter_app/ui/pages/home/cancelled_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/home_layout.dart';
import 'package:flutter_app/ui/pages/home/ongoing_visit_layout.dart';
import 'package:flutter_app/ui/pages/home/rate_visit_layout.dart';
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

class MainPage extends StatefulWidget {
  final ValueChanged<int> onLoginRequest;

  MainPage({this.onLoginRequest});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Log log = new Log("DashboardHomeLayout");
  BaseUtil baseProvider;
  DBModel reqProvider;
  FcmHandler handler;
  String _time;
  DateTime reqTime = new DateTime.now();
  List<String> serviceList = [Constants.CLEANING, Constants.UTENSILS];
  List<String> selectedServiceList = [Constants.CLEANING];
  CalendarUtil cUtil = new CalendarUtil();
  int homeState = Constants.VISIT_STATUS_NONE;
  StreamSubscription _connectionChangeStream;
  bool _isOffline = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    _connectionChangeStream = connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      _isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
    if (handler != null) {
      handler.setHomeScreenCallback(
          onAssistantAvailable: (state) => onAssistantAvailable(
              state)); //register callback to allow handler to notify change in ui
    }
    homeState = (baseProvider.homeState != null)
        ? baseProvider.homeState
        : Constants.VISIT_STATUS_NONE;
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
            StaggeredTile.extent(2, 300.0),
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
      case Constants.VISIT_STATUS_NONE:
        {
          return buildHomeLayout();
        }
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
              canAssistant: baseProvider.currentAssistant);
        }
      case Constants.VISIT_STATUS_COMPLETED:
        {
          if (baseProvider.currentVisit == null ||
              baseProvider.currentAssistant == null) return buildHomeLayout();
          return RateVisitLayout(
              rateVisit: baseProvider.currentVisit,
              rateAssistant: baseProvider.currentAssistant,
              actionComplete: () {
                setState(() {
                  homeState = Constants.VISIT_STATUS_NONE;
                });
              });
        }
      default:
        return buildHomeLayout();
    }
  }

  Widget buildHomeLayout() {
    return HomeLayout(onLoginRequest: (pageNo) {
      //wont need onLoginRequest to be passed on to the HomeLayout either
      if (widget.onLoginRequest != null) {
        log.debug("onLoginRequest callback for pageNo: " + pageNo.toString());
        widget.onLoginRequest(pageNo);
      }
    });
  }

  //state changer when request is confirmed
  onAssistantAvailable(state) {
    setState(() {
      baseProvider.homeState =
          state; //TODO should be done in the FCMHandler itself
      homeState = state;
    });
  }
}
