import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/ui/dialog/about_dialog.dart';
import 'package:flutter_app/ui/dialog/confirm_action_dialog.dart';
import 'package:flutter_app/ui/dialog/contact_dialog.dart';
import 'package:flutter_app/util/connection_util.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class ProfileOptions extends StatefulWidget{
  ProfileOptions({this.onPush});
  final ValueChanged<String> onPush;
  @override
  State createState() {
    return _OptionsList(onPush: onPush);
  }
}

class _OptionsList extends State<ProfileOptions> {
  _OptionsList({this.onPush});
  final ValueChanged<String> onPush;
  Log log = new Log('ProfileOptions');
  BaseUtil baseProvider;
  DBModel reqProvider;
  static List<OptionDetail> _optionsList;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    reqProvider = Provider.of<DBModel>(context);
    _optionsList = _loadOptionsList();
    return new Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white70,
          title: Text('${Constants.APP_NAME}',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0)),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemBuilder: /*1*/ (context, i) {
            if (i.isOdd) return Divider(); /*2*/
            final index = i ~/ 2; /*3*/
            return _buildRow(_optionsList[index]);
          },
          itemCount: _optionsList.length*2,
        )
    );
  }

  Widget _buildRow(OptionDetail option) {
    return ListTile(
      title: Text(
        option.value,
        style: (option.isEnabled)?TextStyle(
          fontSize: 18.0,
          color: Colors.black
        ):TextStyle(
          fontSize: 18.0,
          color: Colors.grey[400]
        )
      ),
      onTap: () {
        HapticFeedback.vibrate();
        if(option.isEnabled)_routeOptionRequest(option.key);
      }
    );
  }

  _routeOptionRequest(String key) {
    switch(key) {
      case 'upAddress': {
        if(BaseUtil.isDeviceOffline)
          baseProvider.showNoInternetAlert(context);
        else
          Navigator.of(context).pushNamed('/updateAddress');
        break;
      }
      case 'abUs': {
          showDialog(
            context: context,
            builder: (BuildContext context) => AboutUsDialog()
          );
        break;
      }
      case 'contUs': {
        showDialog(
            context: context,
            builder: (BuildContext dialogContext) => ContactUsDialog(
                isResident: (baseProvider.isSignedIn() && baseProvider.isActiveUser()),
                isUnavailable: BaseUtil.isDeviceOffline,
                onClick: () {
                  if(BaseUtil.isDeviceOffline) {
                    baseProvider.showNoInternetAlert(context);
                    return;
                  }
                  if(baseProvider.isSignedIn() && baseProvider.isActiveUser()) {
                    reqProvider.requestCallback(baseProvider.firebaseUser.uid, baseProvider.myUser.mobile).then((flag) {
                      if(flag) {
                        Navigator.of(context).pop();
                        baseProvider.showPositiveAlert('Callback placed!', 'We\'ll contact you soon on your registered mobile', context);
                      }
                    });
                  }else{
                    baseProvider.showNegativeAlert('Unavailable', 'Callbacks are reserved for active users', context);
                  }
                },
            )
        );
        break;
      }
      case 'signOut': {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) => ConfirmActionDialog(
            title: 'Confirm',
            description: 'Are you sure you want to sign out?',
            buttonText: 'Yes',
            confirmAction: () {
              HapticFeedback.vibrate();
              baseProvider.signOut().then((flag) {
                if(flag) {
                  log.debug('Sign out process complete');
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/onboarding');
                  baseProvider.showPositiveAlert('Signed out', 'Hope to see you soon', context);
                }else{
                  Navigator.of(context).pop();
                  baseProvider.showNegativeAlert('Sign out failed', 'Couldn\'t signout. Please try again', context);
                  log.error('Sign out process failed');
                }
              });
            },
            cancelAction: () {
              HapticFeedback.vibrate();
              Navigator.of(context).pop();
            },
          )
        );
        break;
      }
    }
  }

  List<OptionDetail> _loadOptionsList() {
    return [
      new OptionDetail(key: 'upAddress', value: 'Update Address', isEnabled: (baseProvider.isSignedIn() && baseProvider.isActiveUser())),
      new OptionDetail(key: 'abUs', value: 'About ${Constants.APP_NAME}', isEnabled: true),
      new OptionDetail(key: 'contUs', value: 'Contact Us', isEnabled: true),
      new OptionDetail(key: 'signOut', value: 'Sign Out', isEnabled: (baseProvider.isSignedIn())),
    ];
  }

}

class OptionDetail {
  final String key;
  final String value;
  final bool isEnabled;
  OptionDetail({this.key, this.value, this.isEnabled});
}