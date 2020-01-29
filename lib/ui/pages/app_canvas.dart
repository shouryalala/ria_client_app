import 'package:flutter/material.dart';
import 'package:flutter_app/ui/elements/bottom_navy_bar.dart';
import 'package:flutter_app/ui/pages/home/home_controller.dart';
import 'package:flutter_app/ui/pages/profile/history_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';

import 'login/login_dialog.dart';

class AppCanvas extends StatefulWidget{
  @override
  State createState() => _AppCanvasState();
}

class _AppCanvasState extends State<AppCanvas> {
  Log log = new Log("AppCanvas");
  int _currentIndex = 0;
  //TabItem currentItem = TabItem.Home;
//  final navigatorKey = GlobalKey<NavigatorState>();
//  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
//    0 : GlobalKey<NavigatorState>(),
//    1 : GlobalKey<NavigatorState>(),
//    2 : GlobalKey<NavigatorState>(),
//  };

  //not currently being used.. using navigator
//  final List<Widget> _children = [
//    HomeController(onLoginRequest: (pageNo) =>
//        _pushLoginScreen(context, pageNo),
//    PlaceholderWidget(Colors.deepOrange),
//    ProfileOptions()
//  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => Navigator.of(context).maybePop()
           // () async => !await navigatorKeys[_currentIndex].currentState.maybePop()
        ,
    child:
    Scaffold(
      appBar: AppBar(
        title: Text('\t${Constants.APP_NAME}'),
      ),
      body: Center(
        child:
//        new PageView.builder(
//            physics: NeverScrollableScrollPhysics(),
//            itemBuilder: (BuildContext context, int index) {
//              return getTab(index, context);
//            },
//            itemCount: 2,
//            controller: _controller,
//            onPageChanged: (int p) {
//              setState(() {
//                log.debug("How many times do ineed to set the current Index??");
//                _currentIndex = p;
//              });
//            },
//        ),
          getTab(_currentIndex, context)
      ),
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
//            _pageController.animateToPage(index,
//                duration: Duration(milliseconds: 300), curve: Curves.ease);
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

//      BottomNavigationBar(
//        onTap: onTabTapped, // new
//        currentIndex: _currentIndex, // new
//        items: [
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.home),
//            title: new Text('Home'),
//          ),
//          BottomNavigationBarItem(
//            icon: new Icon(Icons.mail),
//            title: new Text('Subscribe'),
//          ),
//          BottomNavigationBarItem(
//              icon: Icon(Icons.person),
//              title: Text('Profile')
//          )
//        ],
//      ),
    ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      //currentTab = TabItem[index];
    });
  }

//  Widget _buildOffstageNavigator(int index, BuildContext context) {
//    return Offstage(
//      offstage: _currentIndex != index,
//      child: TabNavigator(
//        navigatorKey: navigatorKeys[index],
//        item: index,
//        context: context,
//      ),
//    );
//  }

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
    //var routeBuilders = _routeBuilders(context);

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

