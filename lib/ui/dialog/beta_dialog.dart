import 'package:flutter/material.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';

class BetaDialog extends StatelessWidget {
  final Log log = new Log('AboutUsDialog');

  BetaDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        //...bottom card part,
        Container(
            height: 600,
            padding: EdgeInsets.only(
              top: UiConstants.padding,
              bottom: UiConstants.padding,
              left: UiConstants.padding,
              right: UiConstants.padding,
            ),
            //margin: EdgeInsets.only(top: UiConstants.avatarRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(UiConstants.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // To make the card compact
                children: <Widget>[
                  SizedBox(height: 16.0),
                  Text(
                    Constants.ABOUT_US_DESCRIPTION,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Material(
                    color: Colors.black,
                    child: MaterialButton(
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      minWidth: double.infinity,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    borderRadius: new BorderRadius.circular(10.0),
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }
}
