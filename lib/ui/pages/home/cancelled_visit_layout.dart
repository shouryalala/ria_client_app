import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/request.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/util/calendar_util.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class CancelledVisitLayout extends StatefulWidget{
  final ValueChanged<Visit> onRerouteCancelledVisit;
  final Visit canVisit;
  final Assistant canAssistant;

  CancelledVisitLayout({this.canVisit, this.canAssistant, this.onRerouteCancelledVisit});

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
                        /*RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          elevation: 4.0,
                          child: Text('Request Again'),   //TODO inform user of params before adding request
                          onPressed: () {
                            Request req = Request(
                                user_id: baseProvider.firebaseUser.uid,
                                user_mobile: baseProvider.myUser.mobile,
                                bhk: baseProvider.myUser.bhk,
                                date: cUtil.now.day,
                                service: widget.canVisit.service,
                                address: baseProvider.myUser.flat_no,
                                society_id: baseProvider.myUser.society_id,
                                cost: widget.canVisit.cost,
                                req_time: baseProvider.encodeTimeRequest(
                                    new DateTime.now()),
                                timestamp: FieldValue.serverTimestamp());

                            ////TODO CANCELLED VIST IN RUINS!


                            req.addException(widget.canAssistant.id);
                            if(widget.onRerouteCancelledVisit != null)widget.onRerouteCancelledVisit(widget.canVisit);
                          },
                        ),*/
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

                  },
                ),

              ),
            ),
            Expanded(
              //child: RaisedButton(onPressed: () {},child: Text("Filter"),color: Colors.black,textColor: Colors.white,)
              child:Material(
                child: MaterialButton(
                  color: Colors.white70,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child:Padding(
                    padding: EdgeInsets.all(20),
                    child:    Text('Request',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                  ),
                  onPressed: () {
                    if(widget.onRerouteCancelledVisit != null && !baseProvider.isRerouteRequestInitiated) {
                      baseProvider.isRerouteRequestInitiated = true;
                      widget.onRerouteCancelledVisit(widget.canVisit);
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