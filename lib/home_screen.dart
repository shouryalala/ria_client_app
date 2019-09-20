import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/request.dart';
import 'package:flutter_app/ui/custom_time_picker.dart';
import 'package:flutter_app/ui/mutli_select_chip.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';

import 'model/db_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _time = "Not set";
  static final String CLEANING = "Cleaning";
  static final String UTENSILS = "Utensils";
  final Log log = new Log("HomeScreen");
  List<String> serviceList = [CLEANING, UTENSILS];
  List<String> selectedServiceList = List();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reqProvider = Provider.of<DBModel>(context);

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
              alignment: Alignment.topRight,
              child: Container(
                width: 100.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: new BorderRadius.circular(30.0),
                  border: Border.all(color: Colors.green, width: 1.0),
                  color: Colors.transparent,
                ),
                child: new Material(
                  child: MaterialButton(
                    child: Text('LOGIN',
                      style: Theme.of(context).textTheme.button.copyWith(color: Colors.green),
                    ),
                    onPressed: (){},
                    highlightColor: Colors.white30,
                    splashColor: Colors.white30,
                  ),
                  color: Colors.transparent,
                  borderRadius: new BorderRadius.circular(30.0),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)
                      ),
                      elevation: 4.0,
                      onPressed: () {
                        DatePicker.showPicker(context,
                            theme: DatePickerTheme(
                              containerHeight: 210.0,
                            ),
                            showTitleActions: true, onConfirm: (time) {
                              print('confirm $time');
                              _time = '${time.hour} : ${time.minute}';
                              setState(() {});
                            },
                            pickerModel:
                            CustomTimePickerModel(DateTime.now(), LocaleType.en));
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
                                      Text(
                                        " $_time",
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
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      child: MultiSelectChip(
                        serviceList,
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
                        FirebaseUser fUser= await FirebaseAuth.instance.currentUser();
                        if (fUser == null) {
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
}
