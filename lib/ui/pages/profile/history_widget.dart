import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/visit.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class HistoryPage extends StatefulWidget{

  @override
  State createState() {
    return _HistoryList();
  }
}

class _HistoryList extends State<HistoryPage> {
  Log log = new Log('HistoryList');
  static DBModel _dbProvider;
  static BaseUtil _authProvider;
  final _biggerFont = const TextStyle(fontSize: 24.0);
  @override
  Widget build(BuildContext context) {
    _dbProvider = Provider.of<DBModel>(context);
    _authProvider = Provider.of<BaseUtil>(context);
    return new Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white70,
          title: Text('${Constants.APP_NAME}',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
        ),
        body: StreamBuilder(  //TODO to be fixed.
//            stream: Firestore.instance.collection("visits").document("2019").collection("AUG").snapshots(),
            stream: _dbProvider.getUserVisitHistory(_authProvider.firebaseUser.uid),
            builder: (context, snapshot) {
              log.debug(snapshot.error.toString());
              if (snapshot.error != null) {
                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'There was a problem loading the history. Please try again later.',
                          textAlign: TextAlign.center,
                          style: _biggerFont,
                        ),
                      ],
                    ),
                  )
                );
              }
              else if (!snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Loading..',
                          textAlign: TextAlign.center,
                          style: _biggerFont,
                        ),
                        SizedBox(
                          height: 24.0,
                        ),
                        SpinKitDoubleBounce(
                          color: UiConstants.spinnerColor,
                        )
                      ],
                    ),
                  )
                );
              }
              else if (snapshot.data.documents.length == 0) {
                return Container(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Image(
                          image: new AssetImage("images/cleaner.png"),
                          height: 92.0,
                          width: 92.0,
                        ),
                        Text(
                          'No recorded visits',
                          textAlign: TextAlign.center,
                          style: _biggerFont,
                        ),
                      ],
                    ),
                  )
                );
              }
              else {
                return ListView.builder(
                  itemExtent: 180.0,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                      _buildCard(context, snapshot.data.documents[index]),
                );
              }
            }
        )
    );
  }

//  Widget _buildHistoryItem(BuildContext context, DocumentSnapshot doc) {
//    Visit vItem = Visit.fromMap(doc.data, '');
//    return Card(
//      margin: EdgeInsets.fromLTRB(15, 3, 15, 3),
//      child: Padding(
//        padding: const EdgeInsets.all(10.0),
//        child: ListTile(
//          leading: CircleAvatar(
//            backgroundColor: Colors.blueAccent,
//            radius: UiConstants.avatarRadius-15,
//          ),
//          title: Text(
//            'Date: ${vItem.date}, Start Time: ${vItem.vis_st_time}',
//            style: _biggerFont,
//          ),
//        ),
//      ),
//          elevation: 3,
//    );
//    return ListTile(
//      title: Text(
//        "Assistant: " + doc["ass_id"] + "   User: " + doc["user_id"],
//        style: _biggerFont,),
//    );
//  }

  Widget _buildCard(BuildContext context, DocumentSnapshot doc) {
    Visit vItem = Visit.fromMap(doc.data, '');
    return new Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: new Stack(
          children: <Widget>[
            new Container(
              height: 159.0,
              width: double.infinity,
              margin: new EdgeInsets.only(left: 46.0),
              decoration: new BoxDecoration(
                //color: new Color(0xFF333366),
                color: Colors.white70,
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(40, 20, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[ //TODO add cost and rating
                    Text('Date: ${vItem.date}'),
                    Text('Assistant: ${vItem.aId}'),
                    Text('Timing: ${_authProvider.decodeTime(vItem.vis_st_time)} to ${_authProvider.decodeTime(vItem.vis_en_time)}'),
                    Text('Service: ${_authProvider.decodeService(vItem.service)}'),
                    //Text('Rating: ${vItem.}')
                  ],
                ),
              )
            ),
            new Container(
              margin: new EdgeInsets.symmetric(
                  vertical: 16.0
              ),
              alignment: FractionalOffset.centerLeft,
              child: new Image(
                image: new AssetImage("images/cleaner.png"),    //TODO add image
                height: 92.0,
                width: 92.0,
              ),
            ),
          ],
        )
    );
  }
}