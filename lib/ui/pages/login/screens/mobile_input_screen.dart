import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/availability_dialog.dart';
import 'package:flutter_app/util/logger.dart';

class MobileInputScreen extends StatefulWidget {
//  final GlobalKey<FormState> formKey;
//  MobileInputScreen({this.formKey});

  static const int index = 0;  //pager index
  final mobileInputScreenState = _MobileInputScreenState();
  @override
  State<StatefulWidget> createState() => mobileInputScreenState;

  getMobile() => mobileInputScreenState.getMobile();

  //setMobileTextError() => mobileInputScreenState.setError();

  bool validate() => mobileInputScreenState._formKey.currentState.validate();
}

class _MobileInputScreenState extends State<MobileInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _validate = true;
  Log log = new Log("MobileInputScreen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:Column(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
              child:Form(
                key: _formKey,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Mobile",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  controller: _mobileController,
                  validator: (value) => _validateMobile(value),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              )
//      TextField(
//                decoration: InputDecoration(
//                    hintText: 'Enter Phone number',
//                    errorText: _validate ? null : "Invalid!",
//                ),
//                keyboardType: TextInputType.number,
//                onChanged: (value) {
//                  this._phoneNo = value;
//                  if(!_validate) setState(() {
//                    _validate = true;
//                  });
//                },
//              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
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
                  showDialog(context: context,
                    builder: (BuildContext context) => LocationAvailabilityDialog()
                  );
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

  String _validateMobile(String value) {
    Pattern pattern = "^[0-9]*\$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length != 10)
      return 'Enter a valid Mobile';
    else
      return null;
  }

  String getMobile() => _mobileController.text;
}