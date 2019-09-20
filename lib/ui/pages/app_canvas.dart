import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/home_screen.dart';
import 'package:flutter_app/ui/pages/placeholder_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';
import 'package:morpheus/widgets/morpheus_tab_view.dart';
import '../../nested-tab-navigator.dart';

class AppCanvas extends StatefulWidget{
  @override
  State createState() {
    return _AppCanvasState();
  }
}

class _AppCanvasState extends State<AppCanvas> {
  int _currentIndex = 0;
  //TabItem currentItem = TabItem.Home;
  final navigatorKey = GlobalKey<NavigatorState>();
  Map<int, GlobalKey<NavigatorState>> navigatorKeys = {
    0 : GlobalKey<NavigatorState>(),
    1 : GlobalKey<NavigatorState>(),
    2 : GlobalKey<NavigatorState>(),
  };

  //not currently being used.. using navigator
  final List<Widget> _children = [
    HomeScreen(),
    PlaceholderWidget(Colors.deepOrange),
    ProfileOptions()
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async =>
        !await navigatorKeys[_currentIndex].currentState.maybePop(),
    child:
    Scaffold(
      appBar: AppBar(
        title: Text('\tRIA'),
      ),
      body:MorpheusTabView( child:
      Stack(children: <Widget>[
        _buildOffstageNavigator(0),
        _buildOffstageNavigator(1),
        _buildOffstageNavigator(2),
      ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
       //currentIndex: 0, // this will be set when a new tab is tapped
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.mail),
            title: new Text('Subscribe'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Profile')
          )
        ],
      ),
    ));
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      //currentTab = TabItem[index];
    });
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: TabNavigator(
        navigatorKey: navigatorKeys[index],
        item: index,
      ),
    );
  }
}

