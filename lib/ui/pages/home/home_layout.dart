import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/http_ops.dart';
import 'package:flutter_app/ui/dialog/beta_dialog.dart';
import 'package:flutter_app/ui/elements/home_time_widget.dart';
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
//  TimeOfDay _selectedTime;
  DateTime reqTime = new DateTime.now();
  List<String> serviceList = [Constants.CLEANING, Constants.UTENSILS, Constants.DUSTING];
  List<String> selectedServiceList = [Constants.CLEANING];
  CalendarUtil cUtil = new CalendarUtil();
  final _timeWidgetKey = GlobalKey<HomeTimeWidgetState>();

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
//    if(_selectedTime == null)_selectedTime=TimeOfDay.now();
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
                        HomeTimeWidget(homeContext: context,
                          key: _timeWidgetKey,
//                        onValidTimeSelected: (time) {
//                          _selectedTime = time;
//                          log.debug(_selectedTime.toString());
//                          setState(() {});
//                        }
                        ),
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
                          color: UiConstants.primaryColor,
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
                                  HomeLayout.PARAM_TIME: _timeWidgetKey.currentState.selectedTime,
                                  HomeLayout.PARAM_SERVICE_CODE: baseProvider.encodeServiceList(selectedServiceList)
                                };
                                widget.onInitiateRequest(reqParams);
                              }
                            },
                            minWidth: double.infinity,
                          ),

                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
        );
  }
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
    if (!_isCostRequestCalled) {
      _isCostRequestCalled = true;
      Timer(const Duration(seconds: 1), () {
        _onCostRetrieved(69.0);
      });
      //TODO disabling cost fetch for now
      //httpProvider.getRequestCost(request).then((resCost) => _onCostRetrieved(resCost));
      if (!_isCostFetched) {
        _requestCostWidget = SpinKitDoubleBounce(
          color: UiConstants.spinnerColor,
          size: 50.0,
          //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
        );
      }
    }
    return _requestCostWidget;
  }

  _onCostRetrieved(double resCost) {
    setState(() {
      _isCostFetched = true;
      if (resCost == -1.0) {
        _isCostAvailable = false;
        _requestCostWidget = new Text(
            'Couldnt fetch the cost at this moment. Please try again soon.');
      }
      else {
        _isCostAvailable = true;
        _requestCostWidget = new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _modalSheetTextRow(null, 'Service',
                baseProvider.decodeService(widget.request.service)),
            _modalSheetTextRow(
                null, 'Time', baseProvider.decodeTime(widget.request.req_time)),
            Padding(
              padding: EdgeInsets.all(3),
              child: Row(
                children: <Widget>[
                  new Text(
                    'Cost: ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  (widget.isFree) ? Row(
                    children: <Widget>[
//                      Text(
//                          '₹$resCost',
//                          style: TextStyle(
//                              fontSize: 24,
//                              fontWeight: FontWeight.w400,
//                              decoration: TextDecoration.lineThrough
//                          )
//                      ),
                      Text(
                          '₹0\t',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          )
                      ),
                      GestureDetector(
                        child: Icon(Icons.info_outline, color: Colors.black54),
                        onTap: () {
                          HapticFeedback.vibrate();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => BetaDialog()
                          );
                        },
                      ),
                    ],
                  ) :
                  new Text(
                    resCost.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,),
            Material(
              color: UiConstants.primaryColor,
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
                  if (widget.onRequestConfirmed != null) {
                    log.debug(
                        'Confirm Request clicked. Sending callback to homeScreen');
                    widget.onRequestConfirmed(resCost);
                  } else {
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
  }

  _modalSheetTextRow(Icon icon, String header, String text) {
    return Padding(
        padding: EdgeInsets.all(3.0),
        child:Row(
            children: <Widget>[
              Text(
                '$header: ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$text',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              )
            ]
        )
    );
  }
}



