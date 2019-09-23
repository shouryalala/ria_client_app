import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MobileInputScreen extends StatefulWidget {
  final mobileInputScreenState = _MobileInputScreenState();
  @override
  State<StatefulWidget> createState() => mobileInputScreenState;

  getMobile() => mobileInputScreenState.phoneNo;

  setMobileTextError() => mobileInputScreenState.setError();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  String _phoneNo;
  bool _validate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Phone number',
                    errorText: _validate ? null : "Invalid!",
                ),
                onChanged: (value) {
                  this._phoneNo = value;
                  if(!_validate) setState(() {
                    _validate = true;
                  });
                },
              ),
            ),
          ),
          //TODO add limited availability warning
          Container(
            width: 150.0,
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(30.0),
              border: Border.all(color: Colors.green, width: 1.0),
              color: Colors.transparent,
            ),
            child: new Material(
              child: MaterialButton(
                child: Text('We are currently servicing only select societies',
                  style: Theme.of(context).textTheme.button.copyWith(color: Colors.green),
                ),
                onPressed: (){

                },
                highlightColor: Colors.white30,
                splashColor: Colors.white30,
              ),
              color: Colors.transparent,
              borderRadius: new BorderRadius.circular(30.0),
            ),
          ),
        ],
      )
    );
  }

  setError() {
    setState(() {
      _validate = false;
    });
  }

  String get phoneNo => _phoneNo;
}