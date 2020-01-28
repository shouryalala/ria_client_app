import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget{

  @override
  State createState() {
    return _HistoryList();
  }
}

class _HistoryList extends State<HistoryPage> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar:AppBar(
          title: Text('\tRIA History'),
        ),
        body: StreamBuilder(  //TODO to be fixed.
            stream: Firestore.instance.collection("visits").document("2019").collection("AUG").snapshots(),
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