import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/http_ops.dart';
import 'package:flutter_app/ui/elements/mutli_select_chip.dart';
import 'package:flutter_app/ui/elements/time_picker_model.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../core/ops/db_ops.dart';
import '../../../util/constants.dart';

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
  String _time;
  DateTime reqTime = new DateTime.now();
  List<String> serviceList = [Constants.CLEANING, Constants.UTENSILS];
  List<String> selectedServiceList = [Constants.CLEANING];
  DBModel reqProvider;
  BaseUtil baseProvider;
  FcmHandler handler;
  HttpModel httpProvider;
  CalendarUtil cUtil;
/*
  bool _isCostFetched = false;  //http request called
  bool _isCostAvailable = false;  //http request successful
  bool _isCostRequestCalled = false;
  Widget _requestCostWidget;
*/
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
    httpProvider = Provider.of<HttpModel>(context);
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
        return buildUpcomingVisitLayout(baseProvider.currentVisit, baseProvider.currentAssistant);
      }
      case Constants.VISIT_STATUS_ONGOING:{
        if(baseProvider.currentVisit == null || baseProvider.currentAssistant == null) return buildHomeLayout();
        return buildOngoingVisitLayout(baseProvider.currentVisit, baseProvider.currentAssistant);
      }
      default:{
        return buildHomeLayout();
      }
    }
  }

  Widget buildHomeLayout() {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white10,
                ),
                buildLoginButton(),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        buildTimeButton(),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          child: MultiSelectChip(
                            serviceList,
                            selectedServiceList,
                            onSelectionChanged: (selectedList) {
                              setState(() {
                                selectedServiceList = selectedList;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 4.0,
                          onPressed: () {
                            if (baseProvider.firebaseUser == null ||
                                baseProvider.myUser == null
                                || baseProvider.myUser.hasIncompleteDetails() ||
                                selectedServiceList.isEmpty) {
                              //validation message to be assigned on priority basis: Not signed in -- Incomplete details -- Service not selected
                              String message = (baseProvider.firebaseUser ==
                                  null) ? "Please sign in to continue" :
                              ((selectedServiceList.isNotEmpty)
                                  ? "Please complete your details"
                                  : "Please select atleast one service");
                              final snackBar = SnackBar(
                                content: Text(message),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                              return;
                            }
                            Request req = Request(
                                user_id: baseProvider.myUser.uid,
                                user_mobile: baseProvider.myUser.mobile,
                                date: cUtil.now.day,
                                service: decodeMultiChip(),
                                address: baseProvider.myUser.flat_no,
                                society_id: baseProvider.myUser.society_id,
                                req_time: baseProvider.encodeTimeRequest(reqTime),
                                timestamp: FieldValue.serverTimestamp());
                            showModalBottomSheet(
                                context: context,
                                builder: (context){
                                  return CostConfirmModalSheet(request: req, onRequestConfirmed: (cost) {
                                    Navigator.of(context).pop();  //close Cost Sheet
                                    //TODO add a spinner here
                                    _onRequestConfirmed(req, cost);
                                  });
                                }
                            );
                          },
                          child: Text("Request!"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
        )
    );
  }

  Widget buildUpcomingVisitLayout(Visit upVisit, Assistant upAssistant) {
     return Scaffold(
       body:  Padding(
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
                       //time
                       Text(baseProvider.decodeTime(upVisit.vis_st_time),
                         style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                         textAlign: TextAlign.center,
                       ),
                       Text(baseProvider.decodeService(upVisit.service),
                         style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                         textAlign: TextAlign.center,
                       ),
                       ///photo
                       Center(
                         child: Padding(
                           padding: EdgeInsets.all(20.0),
                           child: CachedNetworkImage(
                             imageUrl: upAssistant.url,
                             placeholder: (context, url) => new CircularProgressIndicator(),
                             errorWidget: (context, url, error) => new Icon(Icons.error),
                           ),
                         ),
                       ),
                       ///name
                       Text(upAssistant.name + "," + upAssistant.age.toString(),
                         style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                         textAlign: TextAlign.center,
                       ),
                       ///rating
                       Text(upAssistant.rating.toString(),
                         style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
                         textAlign: TextAlign.center,
                       ),
                       Text("Completed Visits: " + upAssistant.comp_visits.toString(),
                         style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                         textAlign: TextAlign.center,
                       ),
                     ],
                   ),
                 ),
               )
             ],
           )
       )
     );
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

  String decodeMultiChip() {
    if(selectedServiceList.contains(Constants.CLEANING) && selectedServiceList.contains(Constants.UTENSILS)) return Constants.CLEAN_UTENSIL_CDE;
    else if(selectedServiceList.contains(Constants.CLEANING)) return Constants.CLEANING_CDE;
    else return Constants.UTENSILS_CDE;
  }

  Widget buildLoginButton() {
    if(baseProvider.firebaseUser == null || baseProvider.myUser == null || baseProvider.myUser.hasIncompleteDetails()) {
      String btnText = "LOGIN";
      int pageNo = 0; //mobile no page
      if(baseProvider.firebaseUser != null ) {
        //user logged in but has incomplete details
        btnText = "Confirm Details";
        pageNo = 2; //name input page
      }
      Align loginBtn =
      Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 100.0,
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: new BorderRadius.circular(30.0),
            border: Border.all(color: UiConstants.primaryColor, width: 1.0),
            color: Colors.transparent,
          ),
          child: new Material(
            child: MaterialButton(
              child: Text(btnText,
                style: Theme
                    .of(context)
                    .textTheme
                    .button
                    .copyWith(color: UiConstants.primaryColor),
              ),
              onPressed: () {
//                      Navigator.of(context).pop();
//                      Navigator.of(context).pushReplacementNamed('/login');
                onLoginRequest(pageNo);
              },
              highlightColor: Colors.white30,
              splashColor: Colors.white30,
            ),
            color: Colors.transparent,
            borderRadius: new BorderRadius.circular(30.0),
          ),
        ),
      );
      return loginBtn;
    }
    //user already logged in and all important user details already available
    return new Container(width: 0, height: 0,);
  }

  Widget buildTimeButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)
      ),
      elevation: 4.0,
      onPressed: () {
        DatePicker.showPicker(context,
            theme: DatePickerTheme(
              containerHeight: 210.0,
            ),
            showTitleActions: true,
            onConfirm: (time) {
              print('confirm $time');
              setState(() {
                _time = '${time.hour} : ' + '${time.minute}'.padLeft(2,"0");
                reqTime = time;
              });
            },
            pickerModel:CustomPicker(currentTime: DateTime.now(), locale: LocaleType.en));
        setState(() {});
      },
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        size: 18.0,
                        color: Colors.teal,
                      ),
                      Text((_time == null)?new CalendarUtil().getRoundedTime():_time,
                        style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Text(
              "  Change",
              style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0),
            ),
          ],
        ),
      ),
      color: Colors.white,
    );
  }

  //Callback from BottomModalSheet
  _onRequestConfirmed(Request req, double cost) {
    req.cost = cost;
    reqProvider.pushRequest(req);
  }

  //state changer when request is confirmed
  onAssistantAvailable(state) {
    setState(() {
      homeState = state;
    });
  }

}

class CostConfirmModalSheet extends StatefulWidget {
  final Request request;
  final ValueChanged<double> onRequestConfirmed;

  CostConfirmModalSheet({this.request, this.onRequestConfirmed});

  _CostConfirmModalSheetState createState() => _CostConfirmModalSheetState();
}

class _CostConfirmModalSheetState extends State<CostConfirmModalSheet> with SingleTickerProviderStateMixin {
  _CostConfirmModalSheetState();
  Log log = new Log('CostConfirmModalSheet');
  var heightOfModalBottomSheet = 100.0;
  bool _isCostRequestCalled = false;
  bool _isCostFetched = false;
  bool _isCostAvailable = false;
  Widget _requestCostWidget;
  HttpModel httpProvider;

  Widget build(BuildContext context) {
    httpProvider = Provider.of<HttpModel>(context);
    return Container(
      child: new Wrap(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
            child: _costConfirmDialog(widget.request),
          ),
        ],
      ),
    );
  }

  Widget _costConfirmDialog(Request request) {
    if(!_isCostRequestCalled) {
      _isCostRequestCalled = true;
      httpProvider.getRequestCost(request).then((resCost) {
        setState(() {
          _isCostFetched = true;
          if(resCost == -1.0) {
            _isCostAvailable = false;
            _requestCostWidget = new Text('Couldnt fetch the cost at this moment. Please try again soon.');
          }
          else{
            _isCostAvailable = true;
            _requestCostWidget = new Column(
              children: <Widget>[
                new Text('Cost for Service: $resCost'),
                new RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    elevation: 4.0,
                    onPressed: () {
                      if(widget.onRequestConfirmed != null) {
                        log.debug('Confirm Request clicked. Sending callback to homeScreen');
                        widget.onRequestConfirmed(resCost);
                      }else{
                        log.error('Callback not set. Cost confirmation discarded');
                      }
                    },
                  child: Text('Confirm'),
                ),
              ],
            );
          }
        });
      });
      if(!_isCostFetched) {
        _requestCostWidget = SpinKitDoubleBounce(
          color: UiConstants.spinnerColor,
          size: 50.0,
          //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
        );
      }
    }
    return _requestCostWidget;
  }
}
