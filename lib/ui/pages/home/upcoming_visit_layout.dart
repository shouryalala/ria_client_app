import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/ui/dialog/assistant_details_dialog.dart';
import 'package:flutter_app/ui/dialog/confirm_action_dialog.dart';
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
  DBModel dbProvider;

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
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
                          style: TextStyle(color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 30.0
                          ),
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
                    child: Text('Reschedule',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => ConfirmActionDialog(
                          title: 'Are you sure?',
                          description: 'The assistant\'s schedule will be affected',
                          buttonText: 'Yes Reschedule',
                          cancelBtnText: 'Back',
                          confirmAction: () async{
                            log.debug("User cancelled visit");
                            await dbProvider.cancelVisitUpdateStatus(baseProvider.firebaseUser.uid, widget.upVisit);
                            Navigator.of(context).pop();
                          },
                          cancelAction: () {
                            Navigator.of(context).pop();
                            return false;
                          },
                        )
                    );
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
                    child:    Text('Track',
                      style: TextStyle(
                          color: Colors.black
                      ),
                    ),
                  ),
                  onPressed: () {
                    try {
                      _initCall(widget.upAssistant.mobile);
                    }catch(e) {
                      //TODO
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
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.star,
                          color: Colors.grey[800],
                          size: 16,
                        ),
                        Text(
                          widget.upAssistant.rating.toString().substring(0,3),
                          style: TextStyle(height: 1)
                        ),
                      ],
                    ),
                    //Text(widget.upAssistant.age.toString(), style: TextStyle(height: 0.8))
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
    //TODO there is nothing in this dependency. Can be removed + Release version not working

     //await new CallNumber().callNumber('+91' + phone);
  }
}