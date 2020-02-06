import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class HistoryPage extends StatefulWidget{

  @override
  State createState() {
    return _HistoryList();
  }
}

class _HistoryList extends State<HistoryPage> {
  static DBModel _dbProvider;
  static BaseUtil _authProvider;
  final _biggerFont = const TextStyle(fontSize: 18.0);
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
            stream: _dbProvider.getUserVisitHistory(_authProvider.myUser.uid),
            builder: (context, snapshot) {
              if(!snapshot.hasData) return const Text("Loading..");
              return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildHistoryItem(context, snapshot.data.documents[index]),
              );
            }
        )
    );
  }

  Widget _buildHistoryItem(BuildContext context, DocumentSnapshot doc) {
    return ListTile(
      title: Text(
        "Assistant: " + doc["ass_id"] + "   User: " + doc["user_id"],
        style: _biggerFont,),
    );
  }
}