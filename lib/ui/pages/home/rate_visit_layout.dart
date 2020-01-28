import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/ui/elements/star_display.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class RateVisitLayout extends StatefulWidget{
  final VoidCallback  actionComplete;
  final Visit rateVisit;
  final Assistant rateAssistant;

  RateVisitLayout({this.actionComplete, this.rateVisit, this.rateAssistant});

  @override
  State createState() => _RateVisitLayoutState();
}

class _RateVisitLayoutState extends State<RateVisitLayout> {
  Log log = new Log("RateVisitLayout");
  BaseUtil baseProvider;
  DBModel dbProvider;
  int rating=0;
  final fdbkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
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
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  elevation: 4.0,
                  child: Text("Skip"),
                  onPressed: () {
                    log.debug("User skipped rating for assistant");
                    dbProvider.rateVisitAndUpdateUserStatus(baseProvider.myUser.uid, widget.rateAssistant.id, widget.rateVisit.path, 0, null);
                    if(widget.actionComplete != null) widget.actionComplete();
                  },
                ),
              ),
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Rating helps us serve you better',
                          style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,),
                        SizedBox(
                          height: 40.0,
                        ),
                        StatefulBuilder(
                          builder: (context, setState) {
                            return StarRating(
                              onChanged: (index) {
                                setState(() {
                                  rating = index;
                                });
                              },
                              value: rating,
                            );
                          },
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        Container(
                            padding: EdgeInsets.all(12.0),
                            child : TextField(
                                controller: fdbkController,
                                autocorrect: true,
                                decoration: InputDecoration(
                                  hintText: 'Provide feedback for ${widget.rateAssistant.name}',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                )
                            )
                        ),
                      ],
                    ),
                  )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child:SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    elevation: 4.0,
                    child: Text("Submit",
                      style: Theme.of(context).textTheme.button.copyWith(color: Colors.grey[800]),
                      textAlign: TextAlign.center,),
                    onPressed: () {
                      if(this.rating == 0){
                        final snackBar = SnackBar(
                          content: Text('Please add a rating'),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                        return;
                      }
                      if(widget.rateVisit.path != null && widget.rateAssistant.id != null)
                        dbProvider.rateVisitAndUpdateUserStatus(baseProvider.myUser.uid, widget.rateAssistant.id,
                            widget.rateVisit.path, rating, fdbkController.text).then((flag) {
                          log.debug("Rated Visit, added Feedback, and updated User Activity Status: $flag");
                          if(widget.actionComplete != null){
                            final snackBar = SnackBar(
                              content: Text('Thank you! :D'),
                            );
                            Scaffold.of(context).showSnackBar(snackBar);
                            widget.actionComplete();
                          }
                        });
                    },
                  )
                ),
              ),
            ],
          )
      ),
    );
  }
}

//class StatefulStarRating extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    int rating = 0;
//    return StatefulBuilder(
//      builder: (context, setState) {
//        return StarRating(
//          onChanged: (index) {
//            setState(() {
//              rating = index;
//            });
//          },
//          value: rating,
//        );
//      },
//    );
//  }
//}