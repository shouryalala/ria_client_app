import 'package:cached_network_image/cached_network_image.dart';
import 'package:call_number/call_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/ui/dialog/assistant_details_dialog.dart';
import 'package:flutter_app/ui/dialog/form_dialog.dart';
import 'package:flutter_app/util/logger.dart';
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
  Log log = new Log('UpcomingVisitLayout');
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
                          'Upcoming',
                          style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[400]),
                        ),
                        //time
                        SizedBox(height: 11,),
                        Text('${baseProvider.decodeTime(widget.upVisit.vis_st_time)} - ${baseProvider.decodeTime(widget.upVisit.vis_en_time)}' ,
                          style: Theme.of(context).textTheme.body2.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 11,),
                        Text(baseProvider.decodeService(widget.upVisit.service),
                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 11,),
                        ///photo
//                        Center(
//                          child: Padding(
//                            padding: EdgeInsets.all(20.0),
//                            child: CachedNetworkImage(
//                              imageUrl: widget.upAssistant.url,
//                              placeholder: (context, url) => new CircularProgressIndicator(),
//                              errorWidget: (context, url, error) => new Icon(Icons.error),
//                            ),
//                          ),
//                        ),
                        ///name
//                        Text(widget.upAssistant.name + "," + widget.upAssistant.age.toString(),
//                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
//                          textAlign: TextAlign.center,
//                        ),
//                        ///rating
//                        Text(widget.upAssistant.rating.toString(),
//                          style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
//                          textAlign: TextAlign.center,
//                        ),
//                        Text("Completed Visits: " + widget.upAssistant.comp_visits.toString(),
//                          style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
//                          textAlign: TextAlign.center,
//                        ),
                        _buildAssistantTile(),
                        SizedBox(height: 20,),
                        _buildActionButtonBar(),
                      ],
                    ),
                  ),
                ),

              ],
            )
        )
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
                    child:    Text('Call',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                  ),
                  onPressed: () {
                      //UrlLa
                    try {
                      _initCall(widget.upAssistant.mobile);
                    }catch(e) {
                      log.error('Failed to initiate call. Needs a fix asap');
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
                      imageUrl: widget.upAssistant.url,
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
                    _buildLabel(widget.upAssistant.name),
                    SizedBox(height: 11),
                    Text(widget.upAssistant.age.toString(), style: TextStyle(height: 0.8))
                  ],
                ),
              ),
            ],
          ),
        ),
      onTap: () {
          HapticFeedback.vibrate();
          //Navigator.of(context).pushNamed('/shops');
//          showDialog(
//            context: context,
//            builder: (BuildContext context) => AssistantDetailsDialog(
//              assistant: widget.upAssistant,
//            ),
//          );
      showModalBottomSheet(context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            return AssistantDetailsDialog(assistant: widget.upAssistant,);
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

  _initCall(String phone) async {
     await new CallNumber().callNumber('+91' + phone);
  }
}