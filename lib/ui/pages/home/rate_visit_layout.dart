import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class RateVisitLayout extends StatefulWidget{
  final Visit rateVisit;
  final Assistant rateAssistant;

  RateVisitLayout({this.rateVisit, this.rateAssistant});

  @override
  State createState() => _RateVisitLayoutState();
}

class _RateVisitLayoutState extends State<RateVisitLayout> {
  BaseUtil baseProvider;

  @override
  Widget build(BuildContext context) {
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
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Service Ongoing!',
                          style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,),
                        Text('Your Visit is Ongoing \nFrom:' + baseProvider.decodeTime(widget.rateVisit.vis_st_time) + ' to ' + baseProvider.decodeTime(widget.rateVisit.vis_en_time),
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
}