import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class BreathingText extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  //final opacityAnimation = Tween<double>(begin: 0.1, end: 1).animate(controller);
  BreathingText({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
        //margin: EdgeInsets.symmetric(vertical: 10),
        //height: animation.value,
        //width: animation.value,
      opacity: _opacityTween.evaluate(animation),
      child: Text(
        'Connection is taking longer than usual',
        style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20
        ),
      ),
      );
    //);
  }
}

class PoorConnectionAlert extends StatefulWidget {
  _PoorConnectionAlertState createState() => _PoorConnectionAlertState();
}

// #docregion print-state
class _PoorConnectionAlertState extends State<PoorConnectionAlert> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(milliseconds: 1400), vsync: this);
    animation = Tween<double>(begin: 0.1, end: 1).animate(controller)
    // #enddocregion print-state
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      })
    // #docregion print-state
      ..addStatusListener((state) {}
      //print('$state')
    );
    controller.forward();
  }
  // #enddocregion print-state

  @override
  Widget build(BuildContext context) => BreathingText(animation: animation);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
// #docregion print-state
}