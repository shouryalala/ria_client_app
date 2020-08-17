import 'package:flutter/material.dart';
import 'package:flutter_app/ui/elements/circles_with_image.dart';
import 'package:flutter_app/util/assets.dart';

const double IMAGE_SIZE = 370.0;

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: double.infinity,
      width: double.infinity,
      decoration: new BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Colors.grey[50],
                Colors.grey[50],
                Colors.grey[100],
//                Colors.orange[400],
//                Colors.red[600],
//                Colors.red[900],
              ],
              begin: Alignment(0.5, -1.0),
              end: Alignment(0.5, 1.0)
          )
      ),
      child: Stack(
        children: <Widget>[
          new Positioned(
            child: new CircleWithImage(Assets.onboardingSlide[2]),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          new Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: Image(
                    image: AssetImage(Assets.onboardingSlide[2]),
                    fit: BoxFit.contain,
                  ),
                  height: IMAGE_SIZE,
                  width: IMAGE_SIZE,
                ),
                new Padding(
                  padding: const EdgeInsets.fromLTRB(18.0, 25, 18.0, 8.0),
                  child: Text(Assets.onboardingHeader[2],
                    style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  //padding: const EdgeInsets.all(18.0),
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0.0),
                    child:Text(Assets.onboardingDesc[2],
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