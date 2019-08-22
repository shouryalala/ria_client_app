import 'package:flutter/material.dart';
import 'package:flutter_app/profile/history_widget.dart';
import 'package:flutter_app/placeholder_widget.dart';
import 'package:flutter_app/profile/profile_options.dart';

import 'home_widget.dart';

class TabNavigatorRoutes {
  static const String root = '/home';
  static const String subscribe = '/subscribe';
  static const String profile = '/profile';
  static const String history = '/history';
}

class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.item});
  final GlobalKey<NavigatorState> navigatorKey;
  //final MorpheusTabView tabItem;
  final int item;

  void _push(BuildContext context) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(context,MaterialPageRoute(
        builder: (context) =>routeBuilders[TabNavigatorRoutes.history](context)
      )
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {int materialIndex: 500}) {
    return {
      TabNavigatorRoutes.root: (context) => PlaceholderWidget(Colors.blueGrey),
      TabNavigatorRoutes.subscribe: (context) => PlaceholderWidget(Colors.amberAccent),
      TabNavigatorRoutes.profile: (context) => ProfileOptions(
//        color: TabHelper.color(tabItem),
//        title: TabHelper.description(tabItem),
        onPush: (materialIndex) =>
            _push(context),
      ),
      TabNavigatorRoutes.history: (context) => HistoryPage(),
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