import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class OngoingVisitLayout extends StatefulWidget{
  final Visit onVisit;
  final Assistant onAssistant;

  OngoingVisitLayout({this.onVisit, this.onAssistant});

  @override
  State createState() => _OngoingVisitLayoutState();
}

class _OngoingVisitLayoutState extends State<OngoingVisitLayout> {
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
                        Text('Your Visit is Ongoing \nFrom:' + baseProvider.decodeTime(widget.onVisit.vis_st_time) + ' to ' + baseProvider.decodeTime(widget.onVisit.vis_en_time),
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