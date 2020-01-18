import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class UpcomingVisitLayout extends StatefulWidget{
  final Visit upVisit;
  final Assistant upAssistant;

  UpcomingVisitLayout({this.upVisit, this.upAssistant});

  @override
  State createState() => _UpcomingVisitLayoutState();
}

class _UpcomingVisitLayoutState extends State<UpcomingVisitLayout> {
  BaseUtil baseProvider;

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    return Scaffold(
        body:  Padding(
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
                        //time
                        Text(baseProvider.decodeTime(widget.upVisit.vis_st_time),
                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        Text(baseProvider.decodeService(widget.upVisit.service),
                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        ///photo
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CachedNetworkImage(
                              imageUrl: widget.upAssistant.url,
                              placeholder: (context, url) => new CircularProgressIndicator(),
                              errorWidget: (context, url, error) => new Icon(Icons.error),
                            ),
                          ),
                        ),
                        ///name
                        Text(widget.upAssistant.name + "," + widget.upAssistant.age.toString(),
                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        ///rating
                        Text(widget.upAssistant.rating.toString(),
                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        Text("Completed Visits: " + widget.upAssistant.comp_visits.toString(),
                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
        )
    );
  }
}