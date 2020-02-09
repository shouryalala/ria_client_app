import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/ui/elements/confirm_action_dialog.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

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
  Log log = new Log('ProfileOptions');
  BaseUtil baseProvider;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool isHistoryClicked = false;
  final List<String> _list = [
    //"History",
    "Update Address",
    "About Us",
    "Contact Us",
    "Sign Out",
  ];
  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
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
        body: _buildSuggestions(),
    );

//    if(isHistoryClicked) {
//      return HistoryPage();
//    }
//    if(!isHistoryClicked) {
//      return _buildSuggestions();
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
        itemCount: _list.length*2,);
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
      case "Update Address": {
        //Navigator.of(context).pushNamed('/history');
//        isHistoryClicked = true;
//        Navigator.of(context).popAndPushNamed('/home');


//        setState(() {
//
//        });
//        onPush('/history');
        break;
      }
      case "About Us": {
        _showSnackBar(key);
        break;
      }
      case "Contact Us": {
//        showDialog(
//          context: context,
//          builder: (BuildContext context) => CustomDialog(
//              title: "Header",
//              description: "LoReM IpSuM",
//              buttonText: "Got it!"),
//        );
        break;
      }
      case "Sign Out": {
        showDialog(
          context: context,
          builder: (BuildContext context) => ConfirmActionDialog(
            title: 'Confirm',
            description: 'Are you sure you want to sign out?',
            buttonText: 'Yes',
            confirmAction: () {
              HapticFeedback.vibrate();
              baseProvider.signOut().then((flag) {
                if(flag) {
                  log.debug('Sign out process complete');
                  baseProvider.showPositiveAlert('Signed out', 'Hope to see you soon', context);
                  Navigator.of(context).pushReplacementNamed('/onboarding');
                }else{
                  baseProvider.showNoInternetAlert(context);  //TODO change this
                  log.error('Sign out process failed');
                }
              });
            },
            cancelAction: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
          )
        );
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