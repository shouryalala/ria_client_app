import 'package:flutter/material.dart';
import 'package:flutter_app/ui/elements/bottom_navy_bar.dart';
import 'package:flutter_app/ui/pages/home/home_controller.dart';
import 'package:flutter_app/ui/pages/profile/history_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:morpheus/morpheus.dart';

import 'login/login_dialog.dart';

class AppCanvas extends StatefulWidget{
  @override
  State createState() => _AppCanvasState();
}

class _AppCanvasState extends State<AppCanvas> {
  Log log = new Log("AppCanvas");
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => Navigator.of(context).maybePop(),
    child:
    Scaffold(
      appBar: AppBar(
        title: Text('\t${Constants.APP_NAME}'),
      ),
      body: Center(
        child:
          MorpheusTabView(
              child: getTab(_currentIndex, context)
          )),
//      MorpheusTabView(
//        child:
//          Stack(children: <Widget>[
//            _buildOffstageNavigator(0, context),
//            _buildOffstageNavigator(1, context),
//            _buildOffstageNavigator(2, context),
//          ]),
//      ),
      bottomNavigationBar: BottomNavyBar(
          selectedIndex: _currentIndex,
          showElevation: true,
          onItemSelected: (index) => setState(() {
            _currentIndex = index;
          }),
          items: [
            BottomNavyBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
              activeColor: Colors.greenAccent
            ),
            BottomNavyBarItem(
                icon: Icon(Icons.settings),
                title: Text('You'),
                activeColor: Colors.greenAccent[400]
            ),
          ]
      ),
    ));
  }

  Widget getTab(int index, BuildContext context) {
    switch(index) {
      case 0: {
        return HomeController(
          onLoginRequest: (pageNo) =>
              _pushLoginScreen(context, pageNo),
        );
      }
      case 1: {
            return ProfileOptions(
              onPush: (routeId) => _pushHistoryScreen(context),
            );
      }
      default: {
        return HomeController(
          onLoginRequest: (pageNo) =>
              _pushLoginScreen(context, pageNo),
        );
      }
    }
  }

  void _pushLoginScreen(BuildContext context, int pageNo) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginDialog(initPage: pageNo)
      )
    );
  }

  void _pushHistoryScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => HistoryPage()
      )
    );
  }
}

