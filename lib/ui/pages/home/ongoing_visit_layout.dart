import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/ui/dialog/assistant_details_dialog.dart';
import 'package:flutter_app/util/logger.dart';
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
  Log log = new Log('OngoingVisitLayout');
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
                        Text(
                          'Ongoing',
                          style: TextStyle(color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0
                          ),
                        ),
                        //time
                        SizedBox(height: 11,),
                        Text('${baseProvider.decodeTime(widget.onVisit.vis_st_time)} - ${baseProvider.decodeTime(widget.onVisit.vis_en_time)}' ,
                          style: Theme.of(context).textTheme.body2.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 11,),
                        Text(baseProvider.decodeService(widget.onVisit.service),
                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 11,),
                        _buildAssistantTile(),
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

  Widget _buildAssistantTile() {
    return InkWell(
      child:
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: Offset(0, 8),
              blurRadius: 23,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: widget.onAssistant.url,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildLabel(widget.onAssistant.name),
                  SizedBox(height: 11),
                  Text(widget.onAssistant.age.toString(), style: TextStyle(height: 0.8))
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        HapticFeedback.vibrate();
        showModalBottomSheet(context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) {
              return AssistantDetailsDialog(assistant: widget.onAssistant,);
            });
      },
    );
  }
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }
}