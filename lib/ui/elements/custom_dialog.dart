import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';

class CustomDialog extends StatefulWidget {
  final String title, description, buttonText;
  final Function dialogAction;
  final Image image;
  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.dialogAction,
    this.image,
  });

  @override
  State createState() => _CustomDialogState();
}


class _CustomDialogState extends State<CustomDialog> {
  Log log = new Log('CustomDialog');
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
            top: UiConstants.avatarRadius + UiConstants.padding,
            bottom: UiConstants.padding,
            left: UiConstants.padding,
            right: UiConstants.padding,
          ),
          margin: EdgeInsets.only(top: UiConstants.avatarRadius),
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
              Form(
                key: _formKey,
                child: TextFormField(
                    enableSuggestions: true,
                    keyboardType: TextInputType.multiline,
                    autofocus: true,
                    maxLines: 6,
                    controller: fdbkController,
                    validator: (value) {
                      return (value == null || value.isEmpty)?'Please add some feedback':null;
                    },
                    decoration: new InputDecoration(
                      labelText: "Feedback",
                      //fillColor: Colors.white,
                      border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(
                        ),
                      ),)
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    log.debug('DialogAction clicked');
                    if(_formKey.currentState.validate()) {
                      widget.dialogAction(fdbkController.text);
                    }
                  },
                  child: Text(widget.buttonText),
                ),
              ),
            ],
          ),
        ),
        //...top circlular image part,
        Positioned(
          left: UiConstants.padding,
          right: UiConstants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: UiConstants.avatarRadius,
          ),
        ),
      ],
    );
  }
}