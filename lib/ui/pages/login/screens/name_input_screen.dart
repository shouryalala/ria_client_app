import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../../base_util.dart';

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
  TextEditingController _nameFieldController;
  TextEditingController _emailFieldController;
  static BaseUtil authProvider;
  Log log = new Log("NameInputScreen");

  @override
  void initState() {
    authProvider = Provider.of<BaseUtil>(context);
    _nameFieldController = (authProvider.myUser != null && authProvider.myUser.name != null)?
    new TextEditingController(text: authProvider.myUser.name):new TextEditingController();
    _emailFieldController = (authProvider.myUser != null && authProvider.myUser.email != null)?
    new TextEditingController(text: authProvider.myUser.email):new TextEditingController();
  }

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
                  controller: _nameFieldController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    errorText: _validate ? null : "Tell us your name",
                  ),
                  onChanged: (value) {
                    //this._name = value;
                    if(!_validate) setState(() {
                      _validate = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: TextField(
                  controller: _emailFieldController,
                  decoration: InputDecoration(
                    hintText: 'Email(optional)',
                    //errorText: _validate ? null : "Invalid!",
                  ),
                  onChanged: (value) {
                    //this._email = value;
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

  String get email => _emailFieldController.text;

  set email(String value) {
    _emailFieldController.text = value;
    //_email = value;
  }

  String get name => _nameFieldController.text;

  set name(String value) {
    //_name = value;
    _nameFieldController.text = value;
  }

}