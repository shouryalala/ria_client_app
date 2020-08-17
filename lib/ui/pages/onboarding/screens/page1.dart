import 'package:flutter/material.dart';
import 'package:flutter_app/ui/elements/circles_with_image.dart';
import 'package:flutter_app/util/assets.dart';

const double IMAGE_SIZE = 320.0;

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: double.infinity,
      width: double.infinity,
      decoration: new BoxDecoration(
          gradient: LinearGradient(
              colors: [
//                Colors.green[400],
//                Colors.blue[600],
//                Colors.blue[900],
                Colors.grey[50],
                Colors.grey[50],
                Colors.grey[100],
              ],
              begin: Alignment(0.5, -1.0),
              end: Alignment(0.5, 1.0)
          )
      ),
      child: Stack(
        children: <Widget>[
          new Positioned(
            child: new CircleWithImage(Assets.pose1),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          new Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: Image(
                    image: AssetImage(Assets.onboardingSlide[0]),
                    fit: BoxFit.contain,
                  ),
                  height: IMAGE_SIZE,
                  width: IMAGE_SIZE,
                ),
                SizedBox(
                  height: 40.0,
                ),
                new Padding(
                  //padding: const EdgeInsets.all(18.0),
                  padding: const EdgeInsets.fromLTRB(18.0, 25, 18.0, 18.0),
                  child: Text(Assets.onboardingHeader[0],
                    style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  //padding: const EdgeInsets.all(18.0),
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0.0),
                    child:Text(Assets.onboardingDesc[0],
                        style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.grey[800]),
                        textAlign: TextAlign.center,
                      )
              ),
              ],
            ),
          )
        ],
        alignment: FractionalOffset.center,
      ),
    );
  }
}