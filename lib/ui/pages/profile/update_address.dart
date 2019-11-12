import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/ui/pages/login/screens/address_input_screen.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
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
  final _addressInputScreen = new AddressInputScreen();
  static BaseUtil  baseProvider;
  static DBModel dbProvider;
  static LocalDBModel localDbProvider;

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
    localDbProvider = Provider.of<LocalDBModel>(context);
    return Stack(
      children: <Widget>[
        new Positioned.fill(
          child: _addressInputScreen,
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
                            Society selSociety = _addressInputScreen.getSociety();
                            String selFlatNo = _addressInputScreen.getFlatNo();
                            int selBhk = _addressInputScreen.getBhk();
                            if(selSociety == null) {
                              UiConstants.offerSnacks(context,"Please select your appt");
                              return;
                            }
                            if(selFlatNo == null || selFlatNo.isEmpty) {
                              _addressInputScreen.setFlatNoInvalid();
                              return;
                            }
                            if(selBhk == null) {
                              UiConstants.offerSnacks(context, "Please select your house size");
                              return;
                            }
                            baseProvider.myUser.flat_no = selFlatNo;
                            baseProvider.myUser.society_id = selSociety.sId;
                            baseProvider.myUser.sector = selSociety.sector;
                            baseProvider.myUser.bhk = selBhk;
                            //TODO add the spinner here
                            dbProvider.updateUser(baseProvider.myUser).then((flag) {
                              if(flag){
                                log.debug("User object saved successfully");
                                localDbProvider.saveUser(baseProvider.myUser).then((flag) {
                                  if (flag) {
                                    log.debug("User object saved locally");
                                    Navigator.of(context).pop();
                                    //Navigator.of(context).pushReplacementNamed('/home');
                                  }
                                });
                              }
                              else{
                                //TODO signup failed! YIKES please try again later
                              }
                            });
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
    );
  }
}