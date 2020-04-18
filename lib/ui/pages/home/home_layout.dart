import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
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

import '../../../base_util.dart';

class HomeLayout extends StatefulWidget{
  final ValueChanged<Map> onInitiateRequest;
  static const String PARAM_TIME = 'homeTime';
  static const String PARAM_SERVICE_CODE = 'serviceCode';

  HomeLayout({this.onInitiateRequest});

  @override
  State createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  Log log = new Log("HomeLayout");
  BaseUtil baseProvider;
  DBModel reqProvider;
  String _time;
  TimeOfDay _selectedTime;
  DateTime reqTime = new DateTime.now();
  List<String> serviceList = [Constants.CLEANING, Constants.UTENSILS, Constants.DUSTING];
  List<String> selectedServiceList = [Constants.CLEANING];
  CalendarUtil cUtil = new CalendarUtil();
  _HomeLayoutState();

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
    if(_selectedTime == null)_selectedTime=TimeOfDay.now();
//    return Scaffold(
//        body:
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  color: Colors.white10,
                ),
                //buildLoginButton(),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Request',
                          style: TextStyle(color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0
                          ),
                        ),
                        SizedBox(height: 24.0,),
                        buildTimeButton(),
                        SizedBox(height: 24.0,),
                        Container(
                          child: MultiSelectChip(
                            serviceList,
                            selectedServiceList,
                            onSelectionChanged: (selectedList) {
                              HapticFeedback.vibrate();
                              setState(() {
                                selectedServiceList = selectedList;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 24.0,),
                        Material(
                          color: UiConstants.secondaryColor,
                          borderRadius: new BorderRadius.circular(10.0),
                          elevation: 3,
                          child: MaterialButton(
                            child: (!baseProvider.isRequestInitiated)?Text(
                              'Request',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0
                              ),
                            ):SpinKitThreeBounce(
                              color: UiConstants.spinnerColor2,
                              size: 25.0,
                            ),
                            onPressed: () {
                              if(widget.onInitiateRequest != null && !baseProvider.isRequestInitiated) {
                                Map<String, dynamic> reqParams = {
                                  HomeLayout.PARAM_TIME: _selectedTime,
                                  HomeLayout.PARAM_SERVICE_CODE: baseProvider.encodeServiceList(selectedServiceList)
                                };
                                widget.onInitiateRequest(reqParams);
                              }
                            },
                            minWidth: double.infinity,
                          ),

                        ),
//                        RaisedButton(
//                          shape: RoundedRectangleBorder(
//                              borderRadius: BorderRadius.circular(5.0)),
//                          elevation: 4.0,
//                          onPressed: () {
//
//                          },
//                          child: Text("Request!"),
//                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
        );
    //);
  }

  Widget buildTimeButton() {
    return RaisedButton(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0)
    ),
      elevation: 4.0,
      onPressed: () async{
          _selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          log.debug(_selectedTime.toString());
          setState(() {
            int timeFlag = baseProvider.validateRequestTime(_selectedTime);
            if(timeFlag == Constants.TIME_ERROR_OUTSIDE_WINDOW || timeFlag == Constants.TIME_ERROR_NOT_SELECTED) {
              log.debug('Request check:: Invalid Time');
              baseProvider.showNegativeAlert('Action Required', '${Constants.APP_NAME} is available from ${Constants.dayStartTime.hour}:${Constants.dayStartTime.minute.toString().padLeft(2, '0')} AM '
                'to ${Constants.dayEndTime.hour-12}:${Constants.dayEndTime.minute.toString().padLeft(2, '0')} PM', context);
              _selectedTime=TimeOfDay.now();
            }
            else if(timeFlag == Constants.TIME_ERROR_SERVICE_OFF) {
              log.debug('Request check:: Invalid Time');
              //No need to notify unless they initiate request
            }
          });
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
                      Text(_displayTime(_selectedTime),
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

  String _displayTime(TimeOfDay time) {
    if(time == null) return '';
    String am_pm = (time.hour>11)?'pm':'am';
    int hr = (time.hour > 12)?time.hour-12:time.hour;
    String mins = time.minute.toString().padLeft(2, '0');
    return '${hr.toString()}:${mins} ${am_pm}';
  }

  Widget buildTimeButton2() {
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

//  Widget buildLoginButton() {
//    if(baseProvider.firebaseUser == null || baseProvider.myUser == null || baseProvider.myUser.hasIncompleteDetails()) {
//      String btnText = "LOGIN";
//      int pageNo = MobileInputScreen.index; //mobile no page
//      if(baseProvider.firebaseUser != null ) {
//        //user logged in but has incomplete details
//        btnText = "Confirm Details";
//        pageNo = NameInputScreen.index; //name input page
//      }
//      Align loginBtn =
//      Align(
//        alignment: Alignment.topRight,
//        child: Container(
//          width: 100.0,
//          height: 40.0,
//          decoration: BoxDecoration(
//            borderRadius: new BorderRadius.circular(30.0),
//            border: Border.all(color: UiConstants.primaryColor, width: 1.0),
//            color: Colors.transparent,
//          ),
//          child: new Material(
//            child: MaterialButton(
//              child: Text(btnText,
//                style: Theme
//                    .of(context)
//                    .textTheme
//                    .button
//                    .copyWith(color: UiConstants.primaryColor),
//              ),
//              onPressed: () {
//                if(widget.onLoginRequest != null) {
//                  log.debug("onLoginRequest callback for pageNo: " + pageNo.toString());
//                  widget.onLoginRequest(pageNo);
//                }
//              },
//              highlightColor: Colors.white30,
//              splashColor: Colors.white30,
//            ),
//            color: Colors.transparent,
//            borderRadius: new BorderRadius.circular(30.0),
//          ),
//        ),
//      );
//      return loginBtn;
//    }
//    //user already logged in and all important user details already available
//    return new Container(width: 0, height: 0,);
//  }
}

class CostConfirmModalSheet extends StatefulWidget {
  final Request request;
  final ValueChanged<double> onRequestConfirmed;
  final bool isFree = true;

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
  BaseUtil baseProvider;

  Widget build(BuildContext context) {
    httpProvider = Provider.of<HttpModel>(context);
    baseProvider = Provider.of<BaseUtil>(context);
    return Container(
      margin: EdgeInsets.only(left: 18, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
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
                new Text(
                  'Service: ${baseProvider.decodeService(widget.request.service)}'
                      '\nTime: ${baseProvider.decodeTime(widget.request.req_time)}',  //TODO add address
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    new Text(
                      'Charge: ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    (widget.isFree)?Row(
                     children: <Widget>[
                       Text(
                           '₹${resCost}',
                           style: TextStyle(
                               fontSize: 24,
                               fontWeight: FontWeight.w600,
                               decoration: TextDecoration.lineThrough
                           )
                       ),
                       Text(
                           '\t₹0',
                           style: TextStyle(
                               fontSize: 24,
                               fontWeight: FontWeight.w600,
                           )
                       ),
                     ],
                    ):
                    new Text(
                      resCost.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30,),
                Material(
                  color: UiConstants.secondaryColor,
                  borderRadius: new BorderRadius.circular(10.0),
                  elevation: 3,
                  child: MaterialButton(
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0
                      ),
                    ),
                    onPressed: () {
                      if(widget.onRequestConfirmed != null) {
                        log.debug('Confirm Request clicked. Sending callback to homeScreen');
                        widget.onRequestConfirmed(resCost);
                      }else{
                        log.error('Callback not set. Cost confirmation discarded');
                      }
                    },
                    minWidth: double.infinity,
                  ),
                ),
//                new RaisedButton(
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.circular(5.0)),
//                  elevation: 4.0,
//                  onPressed: () {
//                    if(widget.onRequestConfirmed != null) {
//                      log.debug('Confirm Request clicked. Sending callback to homeScreen');
//                      widget.onRequestConfirmed(resCost);
//                    }else{
//                      log.error('Callback not set. Cost confirmation discarded');
//                    }
//                  },
//                  child: Text('Confirm'),
//                ),
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



