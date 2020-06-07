import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiConstants{
  UiConstants._();

//  static final Color primaryColor = Colors.greenAccent[400];
  static final Color primaryColor = const Color.fromARGB(255, 58, 134, 255);
  static final Color darkPrimaryColor = const Color.fromARGB(255, 58, 120, 255);
  static final Color accentColor = Colors.grey[800];
  static final Color secondaryColor = const Color.fromARGB(255, 241, 227, 243);
  static final Color chipColor = const Color.fromARGB(255, 241, 227, 243);

  static final Color positiveAlertColor = Colors.blueAccent[400];
  static final Color negativeAlertColor = Colors.blueGrey;
//  static final Color secondaryColor = Colors.greenAccent;
  static final Color spinnerColor = Colors.grey[400];
  static final Color spinnerColor2 = Colors.grey[200];
  //dimens
  static final double dialogRadius = 20.0;
  static const double padding = 16.0;
  static const double avatarRadius = 96.0;

  static offerSnacks(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    return;
  }

}