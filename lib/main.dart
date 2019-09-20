import 'package:flutter/material.dart';
import 'package:flutter_app/model/db_model.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/onboarding/onboarding_widget.dart';
import 'package:flutter_app/profile/history_widget.dart';
import 'package:flutter_app/profile/profile_options.dart';
import 'package:provider/provider.dart';

import 'base_util.dart';
import 'canvas_widget.dart';
import 'launcher_widget.dart';
import 'model/local_db_model.dart';
import 'login/login_widget.dart';

void main() {
  setupLocator();
  runApp(App());
}

class App extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) =>  locator<DBModel>()),
        ChangeNotifierProvider(builder: (_) =>  locator<LocalDBModel>()),
        ChangeNotifierProvider(builder: (_) =>  locator<BaseUtil>()),
      ],
      child: MaterialApp(
        title:"Ria",
        home: SplashScreen(),
        routes: <String, WidgetBuilder> {
          '/launcher': (BuildContext context) => SplashScreen(),
          '/home': (BuildContext context) => AppCanvas(),
          '/onboarding':(BuildContext context) => OnboardingMainPage(),
          '/login': (BuildContext context) => LoginPage(),
          '/history': (BuildContext context) => HistoryPage(),
          '/profile': (BuildContext context) => ProfileOptions(),
        },
      )
    );
  }
}
