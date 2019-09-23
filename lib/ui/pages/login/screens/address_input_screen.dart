import 'package:flutter/material.dart';

class AddressInputScreen extends StatefulWidget{
  final addressInputScreenState = _AddressInputScreenState();
  @override
  State<StatefulWidget> createState() => addressInputScreenState;
}

class _AddressInputScreenState extends State<AddressInputScreen> {
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
                    //errorText: _validate ? null : "Tell us your name",
                  ),
                  onChanged: (value) {

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

                  },
                ),
              ),
            ],
          ),
        )
    );
  }

}