import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/fcm_listener.dart';
import 'package:flutter_app/ui/elements/breathing_text_widget.dart';
import 'package:flutter_app/ui/elements/custom_flutter_logo.dart';
import 'package:flutter_app/ui/elements/flutter_logo_obj.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../base_util.dart';
import 'home/rate_visit_layout.dart';

class SplashScreen extends StatefulWidget {  
  @override State<StatefulWidget> createState() => LogoFadeIn();
}

class LogoFadeIn extends State<SplashScreen> {
  Log log = new Log("SplashScreen");
  bool _isSlowConnection = false;
  bool _isAnimVisible = true;
  Timer _timer, _timer2;
  FlutterLogoStyleX _logoStyle = FlutterLogoStyleX.markOnly;


  LogoFadeIn() {
    _timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        _logoStyle = FlutterLogoStyleX.horizontal;
        initialize();
      });
    });
    _timer2 = new Timer(const Duration(seconds: 6), () {
      //display slow internet message
        setState(() {
          _isSlowConnection = true;
        });
    });
  }



  initialize() async{
    final onboardProvider = Provider.of<BaseUtil>(context);
    final fcmProvider = Provider.of<FcmListener>(context);
    await onboardProvider.init();
    await fcmProvider.setupFcm();
    if(!onboardProvider.isUserOnboarded) {
      log.debug("New user. Moving to Onboarding..");
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
//    else if(onboardProvider.homeState == Constants.VISIT_STATUS_COMPLETED
//        && onboardProvider.currentVisit != null && onboardProvider.currentAssistant != null){
//       //TODO disgusting code.. please refactor dude
//        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RateVisitLayout(
//            rateVisit: onboardProvider.currentVisit,
//            rateAssistant: onboardProvider.currentAssistant,
//            actionComplete: () {})));
//    }
    else {
      log.debug("Existing User. Moving to Home..");
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    //if(!_timer.isActive)initialize();
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            Center(
              child: Container(
                child: new FlutterLogoX(
                  size: 200.0,
                  style: _logoStyle,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: _isSlowConnection,
                    child:  BreathingText(alertText: 'Connection is taking longer than usual')
                  )
              ),
            )
          ],
        )
      ),
    );
  }
}

//class AnimatedLogo extends AnimatedWidget {
//  // Make the Tweens static because they don't change.
//  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
//  static final _sizeTween = Tween<double>(begin: 0, end: 300);
//
//  AnimatedLogo({Key key, Animation<double> animation})
//      : super(key: key, listenable: animation);
//
//  Widget build(BuildContext context) {
//    final animation = listenable as Animation<double>;
//    return Center(
//      child: Opacity(
//        opacity: _opacityTween.evaluate(animation),
//        child: Container(
//          margin: EdgeInsets.symmetric(vertical: 10),
//          height: _sizeTween.evaluate(animation),
//          width: _sizeTween.evaluate(animation),
//          child: FlutterLogo(),
//        ),
//      ),
//    );
//  }
//}
