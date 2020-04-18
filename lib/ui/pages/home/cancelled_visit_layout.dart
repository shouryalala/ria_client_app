import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class CancelledVisitLayout extends StatefulWidget{
  final ValueChanged<Visit> onRerouteCancelledVisit;
  final VoidCallback onCancelRerequest;
  final Visit canVisit;
  final Assistant canAssistant;

  CancelledVisitLayout({this.canVisit, this.canAssistant, this.onRerouteCancelledVisit, this.onCancelRerequest});

  @override
  State createState() => _CancelledVisitLayoutState();
}

class _CancelledVisitLayoutState extends State<CancelledVisitLayout> {
  BaseUtil baseProvider;
  DBModel reqProvider;
  CalendarUtil cUtil = new CalendarUtil();

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
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
                        Text('Visit Cancelled!',
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1
                              .copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,),
                        Text('${widget.canAssistant.name} had to cancel her visit. ' +
                            '\n Would you like to request for a different Assistant?',
                          style: Theme
                              .of(context)
                              .textTheme
                              .body1
                              .copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        _buildActionButtonBar(),
                      ],
                    ),
                  )
              ),
            ],
          )
      ),
    );
  }

  Widget _buildActionButtonBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child:ListTile(
        title: Row(
          children: <Widget>[
            Expanded(
              child:
              //  RaisedButton(onPressed: () {},child: Text("Clear"),color: Colors.black,textColor: Colors.white,)
              Material(
                child: MaterialButton(
                  child:Padding(
                    padding: EdgeInsets.all(2),
                    child: Text('Cancel',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  onPressed: () {
                    if(widget.onCancelRerequest!=null)widget.onCancelRerequest();
                  },
                ),

              ),
            ),
            Expanded(
              //child: RaisedButton(onPressed: () {},child: Text("Filter"),color: Colors.black,textColor: Colors.white,)
              child:Material(
                child: MaterialButton(
                  color: UiConstants.secondaryColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child:Padding(
                    padding: EdgeInsets.all(20),
                    child: (!baseProvider.isRerouteRequestInitiated)?Text('Request',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ):SpinKitThreeBounce(
                      color: UiConstants.spinnerColor2,
                      size: 20.0,
                    ),
                  ),
                  onPressed: () {
                    if(widget.onRerouteCancelledVisit != null && !baseProvider.isRerouteRequestInitiated) {
                      widget.onRerouteCancelledVisit(widget.canVisit);
                      setState(() {
                        baseProvider.isRerouteRequestInitiated = true;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}