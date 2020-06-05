import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiConstants{
  UiConstants._();

//  static final Color primaryColor = Colors.greenAccent[400];
  static final Color primaryColor = Colors.blue[800];
  static final Color accentColor = Colors.grey[800];
  static final Color secondaryColor = Colors.blue;
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