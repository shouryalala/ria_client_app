import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/ui/elements/ui_constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LocationAvailabilityDialog extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LocationAvailabilityDialogState();
}

class _LocationAvailabilityDialogState extends State<LocationAvailabilityDialog>{
  Log log = new Log("LocationAvailabilityDialog");
  DBModel _dbProvider;
  bool bodyWidgetAdded = false;
  bool isSocietyListFetched = false;
  Widget bodyWidget = new Text("Loading...");
  final _biggerFont = const TextStyle(fontSize: 20.0);
  final _mediumFont = const TextStyle(fontSize: 18.0);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UiConstants.dialogRadius),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    _dbProvider = Provider.of<DBModel>(context);
    return Container(
      height: 400,  //TODO has to be dynamic
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(UiConstants.dialogRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        //backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18.0, 25, 18.0, 18.0),
          child: Column(
            children: <Widget>[
              Text(
                'We are currently only servicing the following societies',
                style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10, 10.0, 10.0),
                child: Text(
                  'Dwarka, New Delhi',
                  style: _biggerFont,
                  textAlign: TextAlign.center,
                ),
              ),
              _societyList(),
            ],
          ),
        )
    );
  }

  Widget _societyList() {
    if(!isSocietyListFetched) {
      this.bodyWidget = new Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
          child: SpinKitDoubleBounce(
            color: UiConstants.spinnerColor,
            size: 50.0,
            //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
          ),
      );
      _dbProvider.getServicingApptList().then((sMap) {
        log.debug("Entered fetched societies then clause");
        isSocietyListFetched = true;
        List<Widget> widgets = new List<Widget>();
        if(sMap != null) {
          sMap.forEach((key, value) {
            widgets.add(Text(
              "Sector: " + key.toString(),
              style: TextStyle(decoration: TextDecoration.underline, fontSize: 18.0),
              textAlign: TextAlign.center,
            ));
            StringBuffer sector_societies = new StringBuffer();
            for (Society society in value) {
              sector_societies.write(society.enName);
              sector_societies.write("\n");
            }
            widgets.add(Text(
              sector_societies.toString(),
              style: _mediumFont,
              textAlign: TextAlign.center,
            ));
          });
        }
        setState(() {
          if (sMap == null ||sMap.isEmpty) {
            log.error("Data fetch failed");
            this.bodyWidget = new Text("Unable to fetch data. Try again later.");
            this.bodyWidgetAdded = true;
          }else{
            this.bodyWidget = new Column(
                children: widgets
            );
            this.bodyWidgetAdded = true;
          }
        });
      });
    }
    return this.bodyWidget;
  }
}