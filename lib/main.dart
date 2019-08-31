import 'package:flutter/material.dart';
import 'package:flutter_app/home_widget.dart';
import 'package:flutter_app/profile/history_widget.dart';
import 'launcher_widget.dart';
import 'package:flutter_app/onboarding/onboarding_widget.dart';
import 'package:flutter_app/profile/profile_options.dart';
import 'login_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:"Ria",
      home: SplashScreen(),
      routes: <String, WidgetBuilder> {
        '/launcher': (BuildContext context) => SplashScreen(),
        '/home': (BuildContext context) => Home(),
        '/onboarding':(BuildContext context) => OnboardingMainPage(),
        '/login': (BuildContext context) => LoginPage(),
        '/history': (BuildContext context) => HistoryPage(),
        '/profile': (BuildContext context) => ProfileOptions(),
      },
      
    );
  }
}
