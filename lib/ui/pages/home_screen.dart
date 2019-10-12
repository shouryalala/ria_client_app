import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/base_util.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/ui/elements/custom_time_picker.dart';
import 'package:flutter_app/ui/elements/mutli_select_chip.dart';
import 'package:flutter_app/ui/elements/time_picker_model.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';

import '../../core/model/db_model.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onLoginRequest;
  HomeScreen({this.onLoginRequest});
  @override
  _HomeScreenState createState() {
    return _HomeScreenState(onLoginRequest: onLoginRequest);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueChanged<int> onLoginRequest;
  _HomeScreenState({this.onLoginRequest});
  String _time = null;
  static const String CLEANING = "Cleaning";
  static const String UTENSILS = "Utensils";
  final Log log = new Log("HomeScreen");
  List<String> serviceList = [CLEANING, UTENSILS];
  List<String> selectedServiceList = [CLEANING];
  DBModel reqProvider;
  BaseUtil baseProvider;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    reqProvider = Provider.of<DBModel>(context);
    baseProvider = Provider.of<BaseUtil>(context);
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
                        if(baseProvider.firebaseUser == null || baseProvider.myUser == null || baseProvider.myUser.hasIncompleteDetails()) {
                          final snackBar = SnackBar(
                            content: Text("Please sign in to proceed"),
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                          return;
                        }
                        Request req = Request(user_id: "9986643444", date: 14, service: decodeMultiChip(), address: "Greta"
                            , society_id: "bvx", asn_response: Constants.AST_RESPONSE_NIL, status: Constants.REQ_STATUS_UNASSIGNED,
                            req_time: 15000, timestamp: DateTime.now().millisecondsSinceEpoch);
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
      ),
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
                _time = '${time.hour} : ${time.minute}';
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
