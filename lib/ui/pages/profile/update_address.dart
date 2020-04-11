import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/ui/pages/login/screens/address_input_screen.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class UpdateAddressScreen extends StatefulWidget{

  @override
  State createState() {
    return _UpdateAddressScreenState();
  }
}

class _UpdateAddressScreenState extends State<UpdateAddressScreen> {
  Log log = new Log("UpdateAddressScreen");
  final _addressScreenKey = new GlobalKey<AddressInputScreenState>();
  static BaseUtil  baseProvider;
  static DBModel dbProvider;
  static LocalDBModel localDbProvider;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
    localDbProvider = Provider.of<LocalDBModel>(context);
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white70,
          title: Text('${Constants.APP_NAME}',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
        ),
        body: Stack(
          children: <Widget>[
            new Positioned.fill(
              child: new AddressInputScreen(key: _addressScreenKey),
            ),
            new Positioned(
              bottom: 10.0,
              left: 0.0,
              right: 0.0,
              child: new SafeArea(
                child: new Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Container(
                          width: 150.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [
                                  Colors.green[400],
                                  Colors.green[600],
//                                  Colors.orange[600],
//                                  Colors.orange[900],
                                ],
                                begin: Alignment(0.5, -1.0),
                                end: Alignment(0.5, 1.0)
                            ),
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: new Material(
                            child: MaterialButton(
                              child: Text('UPDATE',
                                style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                              ),
                              onPressed: (){
                                if(_addressScreenKey.currentState.formKey.currentState.validate()) {
                                  Society selSociety = _addressScreenKey.currentState.selected_society;
                                  String selFlatNo = _addressScreenKey.currentState.flat_no;
                                  int selBhk = _addressScreenKey.currentState.bhk;
                                  if(selSociety != null && selFlatNo != null && selBhk != 0) {  //added safegaurd
                                    baseProvider.myUser.flat_no = selFlatNo;
                                    baseProvider.myUser.society_id = selSociety.sId;
                                    baseProvider.myUser.sector = selSociety.sector;
                                    baseProvider.myUser.bhk = selBhk;
                                    //if nothing was invalid:
                                    dbProvider.updateUser(baseProvider.myUser).then((flag) {
                                      if (flag) {
                                        log.debug("User object saved successfully");
                                        localDbProvider.saveUser(baseProvider.myUser).then((flag) {
                                          baseProvider.showPositiveAlert('Complete', 'Address updated', _scaffoldKey.currentContext); //TODO NOT WORKING. Widget already gone before calling snack
                                          Navigator.of(context).pop();
                                        });
                                      } else {
                                        baseProvider.showNegativeAlert('Failed', 'Address couldnt be updated. Please try again later', _scaffoldKey.currentContext);
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  }
                                }
                              },
                              highlightColor: Colors.orange.withOpacity(0.5),
                              splashColor: Colors.orange.withOpacity(0.5),
                            ),
                            color: Colors.transparent,
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}