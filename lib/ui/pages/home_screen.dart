import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/ui/elements/mutli_select_chip.dart';
import 'package:flutter_app/ui/elements/time_picker_model.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';

import '../../core/db_model.dart';

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
  static const String CLEANING = "Cleaning";
  static const String UTENSILS = "Utensils";
  List<String> serviceList = [CLEANING, UTENSILS];
  List<String> selectedServiceList = [CLEANING];
  DBModel reqProvider;
  BaseUtil baseProvider;
  FcmHandler handler;
  CalendarUtil cUtil;
  /**
   * Possible UI States
   * - Deafult Home screen
   * - Assistant matched and enroute
   * - Visit ongoing
   * */

  @override
  void initState() {
    super.initState();
    homeState = (homeState == null)?Constants.VISIT_STATUS_NONE:homeState;
    cUtil = new CalendarUtil();
    //register callback to allow handler to notify change in ui
  }

  @override
  Widget build(BuildContext context) {
    reqProvider = Provider.of<DBModel>(context);
    baseProvider = Provider.of<BaseUtil>(context);
    handler = Provider.of<FcmHandler>(context);
    if(handler != null) {
      handler.setHomeScreenCallback(onAssistantAvailable: () => onAssistantAvailable());
    }
    switch(homeState) {
      case Constants.VISIT_STATUS_NONE: {
       return buildHomeLayout();
      }
      case Constants.VISIT_STATUS_UPCOMING:{
        if(baseProvider.currentVisit == null) return buildHomeLayout();
        return buildUpcomingVisitLayout(baseProvider.currentVisit);
      }
      case Constants.VISIT_STATUS_ONGOING:{
        return buildHomeLayout();
      }
      default:{
        return buildHomeLayout();
      }
    }
  }

  onAssistantAvailable() {
    setState(() {
      homeState = Constants.VISIT_STATUS_UPCOMING;
    });
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
                          onPressed: () async {
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
                                user_id: baseProvider.myUser.mobile,
                                date: cUtil.now.day,
                                service: decodeMultiChip(),
                                address: baseProvider.myUser.flat_no,
                                society_id: baseProvider.myUser.society_id,
                                asn_response: Constants.AST_RESPONSE_NIL,
                                status: Constants.REQ_STATUS_UNASSIGNED,
                                req_time: baseProvider.encodeTimeRequest(reqTime),
                                timestamp: FieldValue.serverTimestamp());
                            reqProvider.pushRequest(req);
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

  Widget buildUpcomingVisitLayout(Visit upVisit) {
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
                       ///time
                       ///photo
                       ///name
                       ///rating
                       Text(upVisit.toFileString()),

                     ],
                   ),
                 ),
               )
             ],
           )
       )
     );
  }

  String decodeMultiChip() {
    if(selectedServiceList.contains(CLEANING) && selectedServiceList.contains(UTENSILS)) return Constants.CLEAN_UTENSIL_CDE;
    else if(selectedServiceList.contains(CLEANING)) return Constants.CLEANING_CDE;
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
}
