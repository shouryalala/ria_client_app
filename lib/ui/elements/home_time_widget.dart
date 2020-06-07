import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:provider/provider.dart';

import '../../base_util.dart';

class HomeTimeWidget extends StatefulWidget{
  final BuildContext homeContext;

  HomeTimeWidget({this.homeContext, Key key}):super(key: key);

  @override
  State<StatefulWidget> createState() => HomeTimeWidgetState();
}

class HomeTimeWidgetState extends State<HomeTimeWidget> {
  Log log = new Log('HomeTimeWidget');
  BaseUtil baseProvider;
  TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 20), (Timer t) {
      TimeOfDay tod = TimeOfDay.now();
      if(baseProvider != null && _selectedTime != null) {
        int _current = baseProvider.encodeTimeOfDay(tod);
        int _selected = baseProvider.encodeTimeOfDay(_selectedTime);
        if(_selected < _current) {
          _selectedTime = tod;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    if(_selectedTime == null)_selectedTime=TimeOfDay.now();

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
          int timeFlag = baseProvider.validateRequestTime(_selectedTime);
          if (timeFlag == Constants.TIME_ERROR_PAST ||
              timeFlag == Constants.TIME_ERROR_NOT_SELECTED) {
            log.debug('Request check:: Time already past');
            baseProvider.showNegativeAlert(
                'Action Required', 'Please select a valid time', widget.homeContext);
            _selectedTime = TimeOfDay.now();
          }
          else if (timeFlag == Constants.TIME_ERROR_OUTSIDE_WINDOW) {
            log.debug('Request check:: Invalid Time');
            baseProvider.showNegativeAlert('Action Required',
                '${Constants.APP_NAME} is available from ${Constants
                    .dayStartTime.hour}:${Constants.dayStartTime.minute
                    .toString().padLeft(2, '0')} AM '
                    'to ${Constants.dayEndTime.hour - 12}:${Constants
                    .dayEndTime.minute.toString().padLeft(2, '0')} PM',
                widget.homeContext);
            _selectedTime = TimeOfDay.now();
          }
//          else if (timeFlag == Constants.TIME_ERROR_SERVICE_OFF) {
//            log.debug('Request check:: Invalid Time');
//            //No need to notify unless they initiate request
//          }
          else {
//            if (widget.onValidTimeSelected != null)
//              widget.onValidTimeSelected(_selectedTime);
          }
          setState(() {
            log.debug("Inner state refreshed");
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
                          color: UiConstants.primaryColor,
                        ),
                        Text(_displayTime(_selectedTime),
                          style: TextStyle(
                              color: UiConstants.primaryColor,
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
                    color: UiConstants.primaryColor,
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
    return '${hr.toString()}:$mins $am_pm';
  }

  TimeOfDay get selectedTime => _selectedTime;


}