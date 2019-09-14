import 'package:flutter/material.dart';
import '../ui/custom_dialog.dart';
import 'history_widget.dart';
import 'package:flutter_app/nested-tab-navigator.dart';

class ProfileOptions extends StatefulWidget{
  ProfileOptions({this.onPush});
  final ValueChanged<String> onPush;
  @override
  State createState() {
    return _OptionsList(onPush: onPush);
  }
}

class _OptionsList extends State<ProfileOptions> {
  _OptionsList({this.onPush});
  final ValueChanged<String> onPush;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool isHistoryClicked = false;
  final List<String> _list = [
    "History",
    "About Us",
    "Feedback",
    "Sign In",
  ];
  @override
  Widget build(BuildContext context) {
//    if(isHistoryClicked) {
//      return HistoryPage();
//    }
//    if(!isHistoryClicked) {
      return _buildSuggestions();
//    }
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/
          final index = i ~/ 2; /*3*/
          return _buildRow(_list[index]);
        },
        itemCount: 7,);
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
        //Navigator.of(context).pushNamed('/history');
//        isHistoryClicked = true;
//        Navigator.of(context).popAndPushNamed('/home');


//        setState(() {
//
//        });
        onPush('/history');
        break;
      }
      case "Feedback": {
        _showSnackBar(key);
        break;
      }
      case "About Us": {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
              title: "Header",
              description: "LoReM IpSuM",
              buttonText: "Got it!"),
        );
        break;
      }
      case "Sign In": {
        //Navigator.of(context).pop();
        //Navigator.of(context).pushNamed('/login');
        onPush('/loginX');
        break;
      }
    }
  }
  _showSnackBar(String key) {
    final snackBar = SnackBar(
      content: Text(key + " pressed!"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}