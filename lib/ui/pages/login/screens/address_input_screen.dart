import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

class AddressInputScreen extends StatefulWidget{
  final addressInputScreenState = _AddressInputScreenState();
  @override
  State<StatefulWidget> createState() => addressInputScreenState;

  Society getSociety() => addressInputScreenState.selected_society;

  String getFlatNo() => addressInputScreenState.flat_no;

  int getBhk() => addressInputScreenState.bhk;

  void setFlatNoInvalid() => addressInputScreenState.setFlatNoInvalid();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  Log log = new Log("AddressInputScreen");
  bool _isInitialised = false;
  static DBModel dbProvider;
  static Map<int, Set<Society>> dMap;
  int _selected_sector;
  String _selected_society_id;
  Society _selected_society;
  String _flat_no;
  String _district;
  int _bhk;
  bool _flatInvalid = false;
  static const List<int> BHK_OPTIONS = [1,2,3,4];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!_isInitialised) {
      _isInitialised = true;
      dbProvider = Provider.of<DBModel>(context);
      dbProvider.getServicingApptList().then((map) {
        setState(() {
          dMap = map;
        });
      });
    }
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: DropdownButton(
                  value: _selected_sector,
                  items: (dMap != null)?dMap.keys.map((sector){
                    return new DropdownMenuItem(
                        value: sector,
                        child: new Text(sector.toString())
                    );
                  }).toList():
                  null,
                  onChanged: ((selection){
                    setState(() {
                      _selected_sector = selection;
                      _selected_society = null;
                    });
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: DropdownButton<Society>(
                  hint: new Text("Pick your Society"),
                  value: _selected_society,
                  onChanged: (society) {
                    setState(() {
                      _selected_society = society;
                    });
                  },
                  items: (dMap == null || _selected_sector == null)?null:
                  dMap[_selected_sector].map((society){
                    return new DropdownMenuItem<Society>(
                        value: society,
                        child: new Text(society.enName)
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Flat No',
                    errorText: _flatInvalid ? " House no needed ": null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _flat_no = value;
                      _flatInvalid = false;
                    });
                  },

                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                child: DropdownButton(
                  hint: new Text("Appt size"),
                  value: _bhk,
                  onChanged: (bhk) {
                    setState(() {
                      _bhk = bhk;
                    });
                  },
                  items: BHK_OPTIONS.map((digit) {
                    return new DropdownMenuItem(
                        value: digit,
                        child: new Text(digit.toString() + " bhk")
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        )
    );
  }

  String get district => _district;

  set district(String value) {
    _district = value;
  }

  String get flat_no => _flat_no;

  set flat_no(String value) {
    _flat_no = value;
  }

  setFlatNoInvalid() {
    setState(() {
      _flatInvalid = true;
    });
  }

  String get selected_society_id => _selected_society_id;

  set selected_society_id(String value) {
    _selected_society_id = value;
  }

  int get selected_sector => _selected_sector;

  set selected_sector(int value) {
    _selected_sector = value;
  }

  int get bhk => _bhk;

  set bhk(int value) {
    _bhk = value;
  }

  Society get selected_society => _selected_society;

  set selected_society(Society value) {
    _selected_society = value;
  }


}