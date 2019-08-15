import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileOptions extends StatefulWidget{

  @override
  State createState() {
    return _OptionsList();
  }
}

class _OptionsList extends State<ProfileOptions> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool isHistoryClicked = false;
  final List<String> _list = [
    "History",
    "About Us",
    "Feedback"
  ];
  @override
  Widget build(BuildContext context) {
    if(isHistoryClicked) {
      return _displayHistory();
    }
    if(!isHistoryClicked) {
      return _buildSuggestions();
    }
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/
          final index = i ~/ 2; /*3*/
          return _buildRow(_list[index]);
        },
        itemCount: 5,);
  }

  Widget _buildRow(String key) {
    return ListTile(
      title: Text(
        key,
        style: _biggerFont,
      ),
      onTap: () => _routeOptionRequest(key),
    );
  }

  _routeOptionRequest(String key) {
    switch(key) {
      case "History": {
        setState(() {
          isHistoryClicked = true;
        });
        break;
      }
      case "Feedback": {
        _showSnackBar(key);
      }
    }
  }
  _showSnackBar(String key) {
    final snackBar = SnackBar(
      content: Text(key + " pressed!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _displayHistory() {
    return new Scaffold(
      body: StreamBuilder(
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