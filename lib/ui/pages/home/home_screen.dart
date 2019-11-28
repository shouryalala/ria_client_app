import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/fcm_handler.dart';
import 'package:flutter_app/core/model/assistant.dart';
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

import '../../../core/ops/db_ops.dart';

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
  /// Possible UI States
  /// - Default Home screen
  /// - Assistant matched and enroute
  /// - Visit ongoing wasaa
  ///
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

  onAssistantAvailable(state) {
    setState(() {
      homeState = state;
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
                                user_id: baseProvider.myUser.uid,
                                user_mobile: baseProvider.myUser.mobile,
                                date: cUtil.now.day,
                                service: decodeMultiChip(),
                                address: baseProvider.myUser.flat_no,
                                society_id: baseProvider.myUser.society_id,
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
                       Text(decodeService(upVisit.service),
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
                  Text('Your Visit is Ongoin! \n' + baseProvider.decodeTime(onVisit.vis_st_time) + ' to ' + baseProvider.decodeTime(onVisit.vis_en_time),
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

  String decodeService(String code) {
    switch(code) {
      case Constants.CLEANING_CDE: return CLEANING;
      case Constants.UTENSILS_CDE: return UTENSILS;
      case Constants.DUSTING_CDE: return "Dusting";
      case Constants.CLEAN_UTENSIL_CDE: return "Cleaning and Utensils";
      default: return code;
    }
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
