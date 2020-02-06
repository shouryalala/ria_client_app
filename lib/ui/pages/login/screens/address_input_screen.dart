import 'package:flutter/material.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:provider/provider.dart';

import '../../../../base_util.dart';

class AddressInputScreen extends StatefulWidget{
  static const int index = 3; //pager index
  AddressInputScreen({Key key}):super(key: key);
  //final addressInputScreenState = _AddressInputScreenState();
  @override
  State<StatefulWidget> createState() => AddressInputScreenState();

//  Society getSociety() => addressInputScreenState.selected_society;
//
//  String getFlatNo() => addressInputScreenState.flat_no;
//
//  int getBhk() => addressInputScreenState.bhk;
//
//  void setFlatNoInvalid() => addressInputScreenState.setFlatNoInvalid();
}

class AddressInputScreenState extends State<AddressInputScreen> {
  Log log = new Log("AddressInputScreen");
  bool _isInitialised = false;
  static DBModel dbProvider;
  static Map<int, Set<Society>> dMap;
  final _formKey = GlobalKey<FormState>();
  static BaseUtil authProvider;
  int _selected_sector;
  String _selected_society_id;
  Society _selected_society;
  String _flat_no;
  String _district;
  int _bhk;
  bool _flatInvalid = false;
  final _addressController = new TextEditingController();
  static const List<int> BHK_OPTIONS = [1,2,3,4];
  static const insets = EdgeInsets.fromLTRB(30.0, 18.0, 30.0, 18.0);

  @override
  void initState() {
    super.initState();
  }

  void initialize(BuildContext context) {
    authProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
    if(!_isInitialised) {
      _isInitialised = true;
      dbProvider.getServicingApptList().then((map) {
        dMap = map;
        if(authProvider.myUser.sector != null){
          _selected_sector = authProvider.myUser.sector;
          dMap[_selected_sector].forEach((society) {
            if(society.sId == authProvider.myUser.society_id) _selected_society = society;
          });
          if(authProvider.myUser.flat_no != null) _addressController.text = authProvider.myUser.flat_no;
          if(authProvider.myUser.bhk != null) _bhk = authProvider.myUser.bhk;
        }
        setState(() {
          log.debug('Initializing address input screen with values:: Sector: ${_selected_sector??''}, '
              'SocietyName: ${_selected_society.enName??''},Address: ${_addressController.text??''},Bhk: ${_bhk??''}' );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initialize(context);
    return Form(
        //backgroundColor: Colors.transparent,
        key: _formKey,
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: insets,
                child: DropdownButtonFormField(
                  //hint: Text('Select Sector'),
                  value: _selected_sector,
                  items: (dMap != null)?dMap.keys.map((sector){
                    return new DropdownMenuItem(
                        value: sector,
                        child: new Text(sector.toString())
                    );
                  }).toList():
                  null,
                  isExpanded: true,
                  validator: (value) {
                    if(value == null)return 'Select your sector';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Sector',
                    icon: Icon(Icons.place)
                  ),
                  //focusColor: UiConstants.primaryColor,
                  onChanged: ((selection){
                    setState(() {
                      _selected_sector = selection;
                      _selected_society = null;
                    });
                  }),
                ),
              ),
              Padding(
                padding: insets,
                child: DropdownButtonFormField<Society>(
                  //hint: new Text('Select Society'),
                  value: _selected_society,
                  onChanged: (society) {
                    setState(() {
                      _selected_society = society;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Society',
                    icon: Icon(Icons.business)
                  ),
                  validator: (value) {
                    if(value == null)return 'Select your society';
                    return null;
                  },
                  items: (dMap == null || _selected_sector == null)?null:
                  dMap[_selected_sector].map((society){
                    return new DropdownMenuItem<Society>(
                        value: society,
                        child: new Text(society.enName)
                    );
                  }).toList(),
                  isExpanded: true,
                  //focusColor: UiConstants.primaryColor,
                  //underline: ,
                  //disabledHint: Text('Please select a sector'),
                ),
              ),
              Padding(
                padding: insets,
                child: TextFormField(
                  decoration: InputDecoration(
                    //errorText: _flatInvalid ? " House no needed ": null,
                    labelText: 'Building / Flat No',
                    icon: Icon(Icons.home)

                  ),
//                  onChanged: (value) {
//                    setState(() {
//                      _flat_no = value;
//                      _flatInvalid = false;
//                    });
//                  },
                  validator: (value) {
                    if(value == null || value.isEmpty)return 'Enter your address';
                    else return null;
                  },
                  controller: _addressController,
                ),
              ),
              Padding(
                padding: insets,
                child: DropdownButtonFormField(
                  //hint: new Text("Appt size"),
                  value: _bhk,
                  decoration: InputDecoration(
                    labelText: 'Appt Size',
                    icon: Icon(Icons.weekend)
                  ),
                  onChanged: (bhk) {
                    setState(() {
                      _bhk = bhk;
                    });
                  },
                  validator: (value) {
                    return (value == null)? 'Select Appt size': null;
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

  String get flat_no => _addressController.text;
//  String get flat_no => _flat_no;
//
//  set flat_no(String value) {
//    _flat_no = value;
//  }
//
//  setFlatNoInvalid() {
//    setState(() {
//      _flatInvalid = true;
//    });
//  }


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

  get formKey => _formKey;

}