import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/logger.dart';

class MagicMinutes extends StatefulWidget {
  int value;
  final TextStyle textStyle;
  bool animate;
  MagicMinutes({this.value, this.textStyle, this.animate=false, Key key}):super(key: key);

  MagicMinutesState createState() => MagicMinutesState();

  //animate() => _state.animateMinutes();
}

// #docregion print-state
class MagicMinutesState extends State<MagicMinutes> with SingleTickerProviderStateMixin {
  Log log = new Log("MagicMinutes");
  Animation<double> animation;
  AnimationController controller;
  String i='0';

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
  }

  void animateMinutes(int val) {
    if(controller.status == AnimationStatus.completed)controller.reset();
    animation = Tween<double>(begin: 0, end: val.toDouble()).animate(controller)
      ..addListener(() {
        setState(() {
          i = animation.value.toStringAsFixed(0);
        });
      })..addStatusListener((status) {
        //if(status == AnimationStatus.completed);
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        (controller==null||controller.status==AnimationStatus.completed||controller.status==AnimationStatus.dismissed)?widget.value.toString():'$i',
      style: widget.textStyle,);
  }

  @override
  void didUpdateWidget(MagicMinutes oldWidget) {
    log.debug("Minute Label Animation required: " + widget.animate.toString());
    if(widget.animate) animateMinutes(widget.value);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}