import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../../base_util.dart';

class NameInputScreen extends StatefulWidget{
  static const int index = 2; //pager index
  final nameInputScreenState = _NameInputScreenState();
  @override
  State<StatefulWidget> createState() => _NameInputScreenState();

  String getName() => "x";//nameInputScreenState.name;

  String getEmail() => "x";//nameInputScreenState.email;

  setNameInvalid() => nameInputScreenState.setError();

  bool validate() => true;//nameInputScreenState._formKey.currentState.validate();
}

class _NameInputScreenState extends State<NameInputScreen> {
  String _name;
  String _email;
  bool _isInitialized = false;
  bool _validate = true;
  TextEditingController _nameFieldController;
  TextEditingController _emailFieldController;
  static BaseUtil authProvider;
  final _formKey = GlobalKey<FormState>();
  Log log = new Log("NameInputScreen");

  @override
  void initState() {
    super.initState();
  }


  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("YO"),
    );
  }
*/
  @override
  Widget build(BuildContext context) {
    if(!_isInitialized) {
      _isInitialized = true;
      authProvider = Provider.of<BaseUtil>(context);
      _nameFieldController = (authProvider.myUser != null && authProvider.myUser.name != null)?
      new TextEditingController(text: authProvider.myUser.name):new TextEditingController();
      _emailFieldController = (authProvider.myUser != null && authProvider.myUser.email != null)?
      new TextEditingController(text: authProvider.myUser.email):new TextEditingController();
    }
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Form(
                key:_formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          18.0, 18.0, 18.0, 18.0),
                      child: TextFormField(
                        controller: _nameFieldController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
//                          hintText: 'Name',
//                          errorText: _validate ? null : "Tell us your name",
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                        ),
                      validator: (value) {
                          return (value != null && value.isNotEmpty)?null:'Please enter your name';
                      },
                      onFieldSubmitted: (v) {
                        FocusScope.of(context).nextFocus();
                      },
//                        onChanged: (value) {
//                          //this._name = value;
//                          if (!_validate) setState(() {
//                            _validate = true;
//                          });
//                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          18.0, 18.0, 18.0, 18.0),
                      child: TextFormField(
                        controller: _emailFieldController,
                        decoration: InputDecoration(
                          //hintText: 'Email(optional)',
                          //errorText: _validate ? null : "Invalid!",
                          labelText: 'Email (optional)',
                          prefixIcon: Icon(Icons.email),
                        ),
//                        onChanged: (value) {
                          //this._email = value;
//                    if(!_validate) setState(() {
//                      _validate = true;
//                    });
//                        },
                      ),
                    ),
                  ],
                )
        )
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