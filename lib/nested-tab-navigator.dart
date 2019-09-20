import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/placeholder_widget.dart';
import 'package:flutter_app/ui/pages/login/login_screen.dart';
import 'package:flutter_app/ui/pages/login/login_widget.dart';
import 'package:flutter_app/ui/pages/profile/history_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';

import 'ui/pages/home_screen.dart';

class TabNavigatorRoutes {
  static const String root = '/home';
  static const String subscribe = '/subscribe';
  static const String profile = '/profile';
  static const String history = '/history';
  static const String login = '/login';
  static const String loginX = '/loginX';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.item});
  final GlobalKey<NavigatorState> navigatorKey;
  final int item;

  void _push(BuildContext context, String routeId) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(context, MaterialPageRoute(
        builder: (context) =>routeBuilders[routeId](context)
      )
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      TabNavigatorRoutes.root: (context) => HomeScreen(),
      TabNavigatorRoutes.subscribe: (context) => PlaceholderWidget(Colors.amberAccent),
      TabNavigatorRoutes.profile: (context) => ProfileOptions(
//        color: TabHelper.color(tabItem),
//        title: TabHelper.description(tabItem),
        onPush: (routeId) =>
            _push(context, routeId),
      ),
      TabNavigatorRoutes.history: (context) => HistoryPage(),
      TabNavigatorRoutes.login: (context) => LoginPage(),
      TabNavigatorRoutes.loginX: (context) => LoginScreen(),
    };
  }

  getTab(index) {
    switch(index){
      case 0: return TabNavigatorRoutes.root;
      case 1: return TabNavigatorRoutes.subscribe;
      case 2: return TabNavigatorRoutes.profile;
    }
  }

  @override
  Widget build(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    return Navigator(
        key: navigatorKey,
        initialRoute: getTab(item),
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
              builder: (context) => routeBuilders[routeSettings.name](context));
        });
  }
}