import 'package:flutter_app/util/logger.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/io_util.dart';

class SplashScreen extends StatefulWidget {  
  @override State<StatefulWidget> createState() => LogoFadeIn();
}

class LogoFadeIn extends State<SplashScreen> {
  Log log = new Log("SplashScreen");
  Timer _timer, _timer2;
  FlutterLogoStyle _logoStyle = FlutterLogoStyle.markOnly;

  LogoFadeIn() {
    _timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        _logoStyle = FlutterLogoStyle.horizontal;
      });
    });
    _timer2 = new Timer(const Duration(seconds: 6), () {
      initialize();
    });
  }

  initialize() {
    new IOUtil().isUserOnboarded().then((flag) {
        if(flag == 0) {
          log.debug("New user. Moving to Onboarding..");
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }else{
          log.debug("Existing User. Moving to Home..");
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/home');
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    //if(!_timer.isActive)initialize();
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            child: new FlutterLogo(
              size: 200.0, style: _logoStyle,
            ),
          ),
        ),
      ),
    );
  }
}