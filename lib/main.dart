import 'package:flutter/material.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/ui/pages/dashboard.dart';
import 'package:flutter_app/ui/pages/login/login_controller.dart';
import 'package:flutter_app/ui/pages/onboarding/onboarding_widget.dart';
import 'package:flutter_app/ui/pages/profile/history_widget.dart';
import 'package:flutter_app/ui/pages/profile/profile_options.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/locator.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:provider/provider.dart';

import 'base_util.dart';
import 'core/ops/cache_ops.dart';
import 'core/fcm_handler.dart';
import 'core/fcm_listener.dart';
import 'core/ops/http_ops.dart';
import 'core/ops/lcl_db_ops.dart';
//import 'ui/pages/app_canvas.dart';
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
          ChangeNotifierProvider(builder: (_) =>  locator<CacheModel>()),
          ChangeNotifierProvider(builder: (_) =>  locator<HttpModel>()),
          ChangeNotifierProvider(builder: (_) =>  locator<BaseUtil>()),
          ChangeNotifierProvider(builder: (_) =>  locator<FcmListener>()),
          ChangeNotifierProvider(builder: (_) =>  locator<FcmHandler>()),
        ],
        child: MaterialApp(
          title:'${Constants.APP_NAME}',
          color: UiConstants.secondaryColor,
          theme: ThemeData(
              primaryColor: UiConstants.primaryColor
          ),
          home: SplashScreen(),
          routes: <String, WidgetBuilder> {
            '/launcher': (BuildContext context) => SplashScreen(),
//            '/home': (BuildContext context) => AppCanvas(),
            '/home': (BuildContext context) => MainPage(onLoginRequest: (pageNo) {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => LoginController(initPage: pageNo)
              ));
            }),
            '/onboarding':(BuildContext context) => OnboardingMainPage(),
            '/login': (BuildContext context) => LoginController(),
            '/history': (BuildContext context) => HistoryPage(),
            '/profile': (BuildContext context) => ProfileOptions(),
          },
        )
    );
  }
}