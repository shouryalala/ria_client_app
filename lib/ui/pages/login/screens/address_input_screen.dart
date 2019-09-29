import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:provider/provider.dart';

import '../../../../base_util.dart';

class AddressInputScreen extends StatefulWidget{
  final addressInputScreenState = _AddressInputScreenState();
  @override
  State<StatefulWidget> createState() => addressInputScreenState;
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  static DBModel dbProvider;
  static Map<int, Set<Society>> dMap;
  static int _selected_sector;
  static String _selected_society;
  static String _selected_society_id;
  static String _flat_no;
  static String _district;

  @override
  void initState() {
    super.initState();
    dbProvider = Provider.of<DBModel>(context);
    dbProvider.getServicingApptList().then((map) => dMap);
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
                child: DropdownButton(
                  items: dMap.keys.map((sector){
                    return new DropdownMenuItem(
                        value: sector,
                        child: new Text(sector.toString())
                    );
                  }).toList(),
                  onChanged: ((selection){
                    selected_sector = selection;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: DropdownButton(
                  items: (selected_sector == null)?null:
                  dMap[selected_sector].map((society){
                    return new DropdownMenuItem(
                        value: society.sId,
                        child: new Text(society.enName)
                    );
                  }).toList(),
                  onChanged: ((selection){
                    selected_society_id = selection.toString();
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Address',
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

  static String get district => _district;

  static set district(String value) {
    _district = value;
  }

  static String get flat_no => _flat_no;

  static set flat_no(String value) {
    _flat_no = value;
  }

  static String get selected_society_id => _selected_society_id;

  static set selected_society_id(String value) {
    _selected_society_id = value;
  }

  static String get selected_society => _selected_society;

  static set selected_society(String value) {
    _selected_society = value;
  }

  static int get selected_sector => _selected_sector;

  static set selected_sector(int value) {
    _selected_sector = value;
  }


}