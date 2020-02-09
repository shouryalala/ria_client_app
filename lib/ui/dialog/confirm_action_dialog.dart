import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';

class ConfirmActionDialog extends StatefulWidget {
  final String title, description, buttonText;
  final Function confirmAction, cancelAction;
  final Image image;
  ConfirmActionDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.confirmAction,
    @required this.cancelAction,
    this.image,
  });

  @override
  State createState() => _FormDialogState();
}


class _FormDialogState extends State<ConfirmActionDialog> {
  Log log = new Log('ConfirmActionDialog');
  final _formKey = GlobalKey<FormState>();
  final fdbkController = TextEditingController();
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
          padding: EdgeInsets.only(
            top: 5+UiConstants.padding,
            bottom: UiConstants.padding,
            left: UiConstants.padding,
            right: UiConstants.padding,
          ),
          margin: EdgeInsets.all(10),
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
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FlatButton(
                      onPressed: () {
                        HapticFeedback.vibrate();
                        log.debug('DialogAction cancelled');
                        widget.cancelAction();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                      onPressed: () {
                        HapticFeedback.vibrate();
                        log.debug('DialogAction clicked');
                        widget.confirmAction();
                      },
                      child: Text(widget.buttonText),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}