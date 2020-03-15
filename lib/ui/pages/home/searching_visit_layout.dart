import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/ui/dialog/assistant_details_dialog.dart';
import 'package:flutter_app/ui/elements/breathing_text_widget.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class SearchingVisitLayout extends StatefulWidget{

  @override
  State createState() => _SearchingVisitLayoutState();
}

class _SearchingVisitLayoutState extends State<SearchingVisitLayout> {
  Log log = new Log('SearchingVisitLayout');
  BaseUtil baseProvider;

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    return Scaffold(
        body:
        Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            Stack(
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
                        BreathingText(
                          alertText: 'Searching',
                          textStyle: TextStyle(color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0
                          ),
                        ),
//                        Text(
//                          'Searching',
//                          style: TextStyle(color: Colors.black,
//                              fontWeight: FontWeight.w700,
//                              fontSize: 30.0
//                          ),
//                        ),
//                        //time
                        SizedBox(height: 11,),
                        SpinKitPulse(
                          color: UiConstants.spinnerColor,
                          size: 50.0,
                        ),
//                        Text('${baseProvider.decodeTime(widget.onVisit.vis_st_time)} - ${baseProvider.decodeTime(widget.onVisit.vis_en_time)}' ,
//                          style: Theme.of(context).textTheme.body2.copyWith(color: Colors.grey[800]),
//                          textAlign: TextAlign.center,
//                        ),
//                        SizedBox(height: 11,),
//                        Text(baseProvider.decodeService(widget.onVisit.service),
//                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
//                          textAlign: TextAlign.center,
//                        ),
//                        SizedBox(height: 11,),
//                        _buildAssistantTile(),

                        //SizedBox(height: 20,),
                        //_buildActionButtonBar(),
                      ],
                    ),
                  ),
                ),

              ],
            )
        )
    );
  }

}