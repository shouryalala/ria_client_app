import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UiConstants{
  UiConstants._();

  static final Color primaryColor = Colors.greenAccent[400];
  static final Color secondaryColor = Colors.greenAccent;
  static final Color spinnerColor = Colors.grey[400];
  //dimens
  static final double dialogRadius = 20.0;
  static const double padding = 16.0;
  static const double avatarRadius = 66.0;

  static offerSnacks(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
    return;
  }

}