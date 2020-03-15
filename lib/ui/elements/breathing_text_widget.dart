import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CustomAnimText extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);
  final String animText;
  final TextStyle textStyle;

  //final opacityAnimation = Tween<double>(begin: 0.1, end: 1).animate(controller);

  CustomAnimText({Key key, Animation<double> animation, this.animText, this.textStyle})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
        //margin: EdgeInsets.symmetric(vertical: 10),
        //height: animation.value,
        //width: animation.value,
      opacity: _opacityTween.evaluate(animation),
      child: Text(
        animText??'Loading',
        style: textStyle??TextStyle(
            color: Colors.grey[800],
            fontSize: 20
        ),
      ),
      );
    //);
  }
}

class BreathingText extends StatefulWidget {
  final String alertText;
  final TextStyle textStyle;
  BreathingText({this.alertText, this.textStyle});
  
  _BreathingTextState createState() => _BreathingTextState();
}

// #docregion print-state
class _BreathingTextState extends State<BreathingText> with SingleTickerProviderStateMixin {
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
  Widget build(BuildContext context) => CustomAnimText(animation: animation, animText: widget.alertText, textStyle: widget.textStyle);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
// #docregion print-state
}