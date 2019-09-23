import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameInputScreen extends StatefulWidget{
  final nameInputScreenState = _NameInputScreenState();
  @override
  State<StatefulWidget> createState() => nameInputScreenState;

  String getName() => nameInputScreenState.name;

  String getEmail() => nameInputScreenState.email;

  setNameInvalid() => nameInputScreenState.setError();
}

class _NameInputScreenState extends State<NameInputScreen> {
  String _name;
  String _email;
  bool _validate = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                    errorText: _validate ? null : "Tell us your name",
                  ),
                  onChanged: (value) {
                    this._name = value;
                    if(!_validate) setState(() {
                      _validate = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Email(optional)',
                    //errorText: _validate ? null : "Invalid!",
                  ),
                  onChanged: (value) {
                    this._email = value;
//                    if(!_validate) setState(() {
//                      _validate = true;
//                    });
                  },
                ),
              ),
            ],
          ),
        )
    );
  }

  setError() {
    setState(() {
      _validate = false;
    });
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

}