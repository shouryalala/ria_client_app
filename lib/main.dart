import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/ui/pages/login/login_dialog.dart';
import 'package:flutter_app/ui/pages/login/login_widget.dart';
import 'package:flutter_app/ui/pages/onboarding/onboarding_widget.dart';
import 'package:flutter_app/ui/pages/profile/history_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:provider/provider.dart';

import 'base_util.dart';
import 'ui/pages/app_canvas.dart';
import 'core/model/local_db_model.dart';
import 'ui/pages/launcher_screen.dart';

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
          '/login': (BuildContext context) => LoginDialog(),
          '/history': (BuildContext context) => HistoryPage(),
          '/profile': (BuildContext context) => ProfileOptions(),
        },
      )
    );
  }
}
