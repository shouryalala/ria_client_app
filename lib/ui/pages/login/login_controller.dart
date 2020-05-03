import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/fcm_listener.dart';
import 'package:flutter_app/core/ops/db_ops.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/core/model/society.dart';
import 'package:flutter_app/core/model/user.dart';
import 'package:flutter_app/ui/pages/login/screens/address_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/mobile_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/name_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/otp_input_screen.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class LoginController extends StatefulWidget {
  final int initPage;

  LoginController({this.initPage});

  @override
  State<StatefulWidget> createState() => _LoginControllerState(initPage);
}

class _LoginControllerState extends State<LoginController> {
  final Log log = new Log("LoginController");
  final int initPage;
  double _formProgress = 0.2;

  _LoginControllerState(this.initPage);

  PageController _controller;
  static BaseUtil baseProvider;
  static DBModel dbProvider;
  static LocalDBModel localDbProvider;
  static FcmListener fcmProvider;

  String userMobile;
//  static MobileInputScreen mobileInScreen;
//  static OtpInputScreen otpInScreen;
//  static NameInputScreen nameInScreen;
//  static AddressInputScreen addressInScreen;
  String verificationId;
  static List<Widget> _pages;
  int _currentPage;
  final _mobileScreenKey = new GlobalKey<MobileInputScreenState>();
  final _otpScreenKey = new GlobalKey<OtpInputScreenState>();
  final _nameScreenKey = new GlobalKey<NameInputScreenState>();
  final _addressScreenKey = new GlobalKey<AddressInputScreenState>();

  @override
  void initState() {
    super.initState();
    _currentPage = (initPage != null) ? initPage : MobileInputScreen.index;
    _formProgress = 0.2 * (_currentPage+1);
    _controller = new PageController(initialPage: _currentPage);
//    mobileInScreen = MobileInputScreen();
//    otpInScreen = OtpInputScreen();
    //nameInScreen = NameInputScreen(key: _nameScreenKey);
    //addressInScreen = AddressInputScreen(key: _addressScreenKey);
    _pages = [
      MobileInputScreen(key: _mobileScreenKey),
      OtpInputScreen(key: _otpScreenKey),
      NameInputScreen(key: _nameScreenKey),
      AddressInputScreen(key: _addressScreenKey),
    ];
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      //this.verificationId = verId;
      log.debug("Phone number hasnt been auto verified yet");
//      otpInScreen.onOtpTimeout();
        _otpScreenKey.currentState.onOtpAutoDetectTimeout();
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      log.debug(
          "User mobile number format verified. Sending otp and verifying");
      //move to otp screen
      //_currentPage = OtpInputScreen.index;
      _controller.animateToPage(OtpInputScreen.index,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) async{
      log.debug("Verified automagically!");
      if(_currentPage == OtpInputScreen.index){
      //  UiConstants.offerSnacks(context, "Mobile verified!");
//        otpInScreen.onOtpReceived();
          _otpScreenKey.currentState.onOtpReceived();
      }
      log.debug("Now verifying user");
      bool flag = await baseProvider.authenticateUser(user);//.then((flag) {
        if (flag) {
          log.debug("User signed in successfully");
          onSignInSuccess();
        } else {
          log.error("User auto sign in didnt work");
        }
//      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      //codes: 'quotaExceeded'
      if(exception.code == 'quotaExceeded') {
        log.error("Quota for otps exceeded");
      }
      log.error("Verification process failed:  ${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.verificationId,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
    localDbProvider = Provider.of<LocalDBModel>(context);
    fcmProvider = Provider.of<FcmListener>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: Colors.white70,
        title: Text('${Constants.APP_NAME}',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 30.0)),
      ),
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(10.0),
//      ),
//      elevation: 0.0,
//      backgroundColor: Colors.transparent,
//      child: dialogContent(context),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          LinearProgressIndicator(
              value: _formProgress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor)),
          //new Positioned.fill(
            //child:
            //Expanded(
              //child:
              new PageView.builder(
              physics: new NeverScrollableScrollPhysics(),
              controller: _controller,
              itemCount: _pages.length,
              itemBuilder: (BuildContext context, int index) {
                return _pages[index % _pages.length];
              },
              onPageChanged: (int index) {
                setState(() {
                  _formProgress = 0.2 * (index+1);
                  _currentPage = index;
                });
              },
            ),
          //)
        //  ),
          //Flexible(
            //child:
            Align(
//          bottom: 10.0,
//          left: 0.0,
//          right: 0.0,
            alignment: Alignment.bottomCenter,
            child: Padding(
//            child: new Column(
//              children: <Widget>[
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  (_currentPage == OtpInputScreen.index ||
                      _currentPage == AddressInputScreen.index)?
                  Container(
                    width: 150.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: new BorderRadius.circular(30.0),
                      border: Border.all(color: Colors.green, width: 1.0),
                      color: Colors.transparent,
                    ),
                    child: new Material(
                      child: MaterialButton(
                        child: Text(
                          'BACK',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          _currentPage--;
                          _controller.animateToPage(_currentPage,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        },
                        highlightColor: Colors.orange.withOpacity(0.5),
                        splashColor: Colors.orange.withOpacity(0.5),
                      ),
                      color: Colors.transparent,
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  )
                      :new Container(),
                  new Container(
                    width: 150.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(colors: [
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
                        child: Text(
                          'NEXT',
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: Colors.white),
                        ),
                        onPressed: () {
                          processScreenInput(_currentPage);
                          //_controller.animateToPage(page + 1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                        },
                        highlightColor: Colors.white30,
                        splashColor: Colors.white30,
                      ),
                      color: Colors.transparent,
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                  ),
                ],
              ),
//              ],
//            ),
            ),
          ),
    //      )
        ],
      )
    ),
    );
  }

  processScreenInput(int currentPage) async{
    switch (currentPage) {
      case MobileInputScreen.index:
        {
          //in mobile input screen. Get and set mobile/ set error interface if not correct
          if (_mobileScreenKey.currentState.formKey.currentState.validate()) {
            log.debug('Mobile number validated: ${_mobileScreenKey.currentState.getMobile()}');
            this.userMobile = _mobileScreenKey.currentState.getMobile();
            this.verificationId = '+91' + this.userMobile;
            verifyPhone();
          }
//          if (formatMobileNumber(id) != null) {
//            this.userMobile = formatMobileNumber(id);
//            this.verificationId = "+91" + this.userMobile;
//            //TODO add a progress bar until smsCode sent
//            verifyPhone();
//          } else {
//            mobileInScreen.setMobileTextError();
//          }
          break;
        }
      case OtpInputScreen.index:
        {
          String otp = _otpScreenKey.currentState.otp; //otpInScreen.getOtp();
          if (otp != null && otp.isNotEmpty && otp.length == 6) {
            bool flag = await baseProvider.authenticateUser(baseProvider.generateAuthCredential(verificationId, otp));
                //.then((flag) {
              if (flag) {
//                otpInScreen.onOtpReceived();
                _otpScreenKey.currentState.onOtpReceived();
                onSignInSuccess();
              } else {
                baseProvider.showNegativeAlert('Invalid Otp', 'Please enter a valid otp', context);
              }
//            });
          } else {
            //TODO set otp error
          }
          break;
        }
      case NameInputScreen.index:
        {
          //if(nameInScreen.validate()) {
          if(_nameScreenKey.currentState.formKey.currentState.validate()) {
            if (baseProvider.myUser == null) {
              //firebase user should never be null at this point
              baseProvider.myUser = User.newUser(baseProvider.firebaseUser.uid,
                  formatMobileNumber(baseProvider.firebaseUser.phoneNumber));
            }
            //baseProvider.myUser.name = nameInScreen.getName();
            baseProvider.myUser.name = _nameScreenKey.currentState.name;
            //String email = nameInScreen.getEmail();
            String email = _nameScreenKey.currentState.email;
            if (email != null && email.isNotEmpty) {
              baseProvider.myUser.email = email;
            }
            //currentPage = AddressInputScreen.index;
            _controller.animateToPage(AddressInputScreen.index,
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          }
          break;
        }
      case AddressInputScreen.index:
        {
          if(_addressScreenKey.currentState.formKey.currentState.validate()){
            Society selSociety = _addressScreenKey.currentState.selected_society;
            String selFlatNo = _addressScreenKey.currentState.flat_no;
            int selBhk = _addressScreenKey.currentState.bhk;
            if(selSociety != null && selFlatNo != null && selBhk != 0) {  //added safegaurd
              baseProvider.myUser.flat_no = selFlatNo;
              baseProvider.myUser.society_id = selSociety.sId;
              baseProvider.myUser.sector = selSociety.sector;
              baseProvider.myUser.bhk = selBhk;
              //if nothing was invalid:
              bool flag = await dbProvider.updateUser(baseProvider.myUser);//.then((flag) {
              if (flag) {
                log.debug("User object saved successfully");
                onSignUpComplete();
              } else {
                baseProvider.showNegativeAlert('Update failed', 'Please try again in sometime', context);
              }
//              });
            }
          }
//          Society selSociety = addressInScreen.getSociety();
//          String selFlatNo = addressInScreen.getFlatNo();
//          int selBhk = addressInScreen.getBhk();
//          if (selSociety == null) {
//            UiConstants.offerSnacks(context, "Please select your appt");
//            return;
//          }
//          if (selFlatNo == null || selFlatNo.isEmpty) {
//            addressInScreen.setFlatNoInvalid();
//            return;
//          }
//          if (selBhk == null) {
//            UiConstants.offerSnacks(context, "Please select your house size");
//            return;
//          }
//          baseProvider.myUser.flat_no = selFlatNo;
//          baseProvider.myUser.society_id = selSociety.sId;
//          baseProvider.myUser.sector = selSociety.sector;
//          baseProvider.myUser.bhk = selBhk;
//          //if nothing was invalid:
//          dbProvider.updateUser(baseProvider.myUser).then((flag) {
//            if (flag) {
//              log.debug("User object saved successfully");
//              onSignUpComplete();
//            } else {
//              //TODO signup failed! YIKES please try again later
//            }
//          });
        }
    }
  }

  String formatMobileNumber(String pNumber) {
    if (pNumber != null && !pNumber.isEmpty) {
      if (RegExp("^[0-9+]*\$").hasMatch(pNumber)) {
        if (pNumber.length == 13 && pNumber.startsWith("+91")) {
          pNumber = pNumber.substring(3);
        } else if (pNumber.length == 12 && pNumber.startsWith("91")) {
          pNumber = pNumber.substring(2);
        }
        if (pNumber.length != 10) return null;
        return pNumber;
      }
    }
    return null;
  }

  void onSignInSuccess() async{
    log.debug("User authenticated. Now check if details previously available.");
    //FirebaseAuth.instance.currentUser().then((fUser) => baseProvider.firebaseUser);
    baseProvider.firebaseUser = await FirebaseAuth.instance.currentUser();//.then((fUser) {
      //baseProvider.firebaseUser = fUser;
    log.debug("User is set: " + baseProvider.firebaseUser.uid);
      //dbProvider.getUser(this.userMobile).then((user) {
    User user = await dbProvider.getUser(baseProvider.firebaseUser.uid);//.then((user) {
    //user variable is pre cast into User object
    //dbProvider.logDeviceId(fUser.uid); //TODO do someday
    if (user == null || (user != null && user.hasIncompleteDetails())) {
      log.debug("No existing user details found or found incomplete details for user. Moving to details page");
      baseProvider.myUser = user ?? User.newUser(baseProvider.firebaseUser.uid, this.userMobile);
      //Move to name input page
      //_currentPage = NameInputScreen.index;
      _controller.animateToPage(NameInputScreen.index,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      log.debug("User details available: Name: " +
          user.name +
          "\nAddress: " +
          user.flat_no);
      baseProvider.myUser = user;
      //baseProvider.myUser.mobile = userMobile;
      onSignUpComplete();
    }
//    });
//    });
  }

  Future onSignUpComplete() async{
    bool flag = await localDbProvider.saveUser(baseProvider.myUser);
    if(flag) {
      log.debug("User object saved locally");
      await baseProvider.init();
      await fcmProvider.setupFcm();
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/home');
      baseProvider.showPositiveAlert('Sign In Complete',
          'Welcome to ${Constants.APP_NAME}, ${baseProvider.myUser.name}',
          context);
    }else{
      log.error("Failed to save user data to local db");
      baseProvider.showNegativeAlert('Sign In Failed', 'Please restart ${Constants.APP_NAME} and try again', context);
    }
    //process complete
    //move to home through animation
    //TODO
  }
}
