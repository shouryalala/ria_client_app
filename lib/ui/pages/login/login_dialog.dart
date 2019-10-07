import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/model/db_model.dart';
import 'package:flutter_app/core/model/local_db_model.dart';
import 'package:flutter_app/ui/pages/login/screens/address_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/mobile_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/name_input_screen.dart';
import 'package:flutter_app/ui/pages/login/screens/otp_input_screen.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:provider/provider.dart';

import '../../../base_util.dart';

class LoginDialog extends StatefulWidget{
  final int initPage;
  LoginDialog({this.initPage});
  @override
  State<StatefulWidget> createState() => _LoginDialogState(initPage);
}

class _LoginDialogState extends State<LoginDialog> {
  final Log log = new Log("LoginDialog");
  final int initPage;
  _LoginDialogState(this.initPage);
  PageController _controller;
  static BaseUtil baseProvider;
  static DBModel dbProvider;
  static LocalDBModel localDbProvider;
  String userMobile;
  static final mobileInScreen = MobileInputScreen();
  static final otpInScreen = OtpInputScreen();
  static final nameInScreen = NameInputScreen();
  static final addressInScreen = AddressInputScreen();
  static const int PHONE_SCREEN = 0;
  static const int OTP_SCREEN = 1;
  static const int NAME_SCREEN = 2;
  static const int ADDRESS_SCREEN = 3;
  String verificationId;
  final List<Widget> _pages = [
    mobileInScreen,
    otpInScreen,
    nameInScreen,
    addressInScreen,
  ];
  int page;

  Future<void> verifyPhone() async {
    //await SmsAutoFill().listenForCode;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      log.debug("User mobile number format verified. Sending otp and verifying");
      //move to otp screen
      _controller.animateToPage(OTP_SCREEN, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print('verified');
      baseProvider.authenticateUser(user).then((flag) {
          if(flag){
            log.debug("User signed in successfully");
            onSignInSuccess();
          }
          else{
            log.error("User auto sign in didnt work");
        }
      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      log.error("Verification process failed:  ${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.verificationId,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 35),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }


  @override
  void initState() {
    super.initState();
    page = (initPage != null)?initPage:0;
    _controller = new PageController(initialPage: page);
  }

  @override
  Widget build(BuildContext context) {
    baseProvider = Provider.of<BaseUtil>(context);
    dbProvider = Provider.of<DBModel>(context);
    localDbProvider = Provider.of<LocalDBModel>(context);
    return Scaffold(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(10.0),
//      ),
//      elevation: 0.0,
//      backgroundColor: Colors.transparent,
//      child: dialogContent(context),
      backgroundColor: Colors.transparent,
      body: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        new Positioned.fill(
          child: new PageView.builder(
            physics: new NeverScrollableScrollPhysics(),
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index % _pages.length];
            },
            onPageChanged: (int p){
              setState(() {
                page = p;
              });
            },
          ),
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
                          child: Text('BACK',
                            style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                          ),
                          onPressed: (){
                            _controller.animateToPage(page - 1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                          },
                          highlightColor: Colors.orange.withOpacity(0.5),
                          splashColor: Colors.orange.withOpacity(0.5),
                        ),
                        color: Colors.transparent,
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                    ),
                    new Container(
                      width: 150.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: new BorderRadius.circular(30.0),
                        border: Border.all(color: Colors.green, width: 1.0),
                        color: Colors.transparent,
                      ),
                      child: new Material(
                        child: MaterialButton(
                          child: Text('NEXT',
                            style: Theme.of(context).textTheme.button.copyWith(color: Colors.green),
                          ),
                          onPressed: (){
                            processScreenInput(page);
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  processScreenInput(int currentPage) {
    switch(currentPage) {
      case PHONE_SCREEN: {
        //in mobile input screen. Get and set mobile/ set error interface if not correct
        String id = mobileInScreen.getMobile();
        if(formatMobileNumber(id) != null) {
          this.userMobile =  formatMobileNumber(id);
          this.verificationId = "+91" + this.userMobile;
          //TODO add a progress bar until smsCode sent
          verifyPhone();
        }
        else{
          mobileInScreen.setMobileTextError();
        }
        break;
      }
      case OTP_SCREEN: {
        String otp = otpInScreen.getOtp();
        if(otp != null && otp.isNotEmpty) {
          baseProvider.authenticateUser(baseProvider.generateAuthCredential(verificationId, otp)).then((flag) {
            if(flag) {
              onSignInSuccess();
            }
            else{
              //TODO
            }
          });
        }
        else{
          //TODO set otp error
        }
        break;
      }
      case NAME_SCREEN: {
        String name = nameInScreen.getName();
        String email = nameInScreen.getEmail();
        //TODO check if name, email already available in the local db
        if(name == null || name.isEmpty) {
          nameInScreen.setNameInvalid();
        }
        else {
          baseProvider.myUser.name = name;
          if(email != null && email.isNotEmpty) {
            baseProvider.myUser.email = email;
          }
          _controller.animateToPage(ADDRESS_SCREEN, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        }
        break;
      }
      case ADDRESS_SCREEN: {
          onSignUpComplete();
      }
    }
  }

  String formatMobileNumber(String pNumber) {
    if(pNumber != null && !pNumber.isEmpty) {
      if(RegExp("^[0-9+]*\$").hasMatch(pNumber)){
        if(pNumber.length == 13 && pNumber.startsWith("+91")) {
          pNumber = pNumber.substring(3);
        }
        else if(pNumber == 12 && pNumber.startsWith("91")){
          pNumber = pNumber.substring(2);
        }
        if(pNumber.length != 10)return null;
        return pNumber;
      }
    }
    return null;
  }

  void onSignInSuccess() {
    log.debug("User authenticated. Now check if details previously available.");
    //FirebaseAuth.instance.currentUser().then((fUser) => baseProvider.firebaseUser);
    FirebaseAuth.instance.currentUser().then((fUser) {
      baseProvider.firebaseUser = fUser;
      log.debug("User is set: " + fUser.uid);
      dbProvider.getUser(this.userMobile).then((user) {
        if(user == null || (user != null && user.hasIncompleteDetails())) {
          log.debug("No existing user details found or found incomplete details for user. Moving to details page");
          //Move to name input page
          if(user != null) {
            baseProvider.myUser = user;
            baseProvider.myUser.mobile = this.userMobile;
          }
          _controller.animateToPage(NAME_SCREEN, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        }
        else{
          log.debug("User details available: Name: " + user.name + "\nAddress: " + user.flat_no);
          log.debug("Storing details in the local db and moving to complete signup process");
          baseProvider.myUser = user;
          baseProvider.myUser.mobile = verificationId.substring(3);
          onSignUpComplete();
        }
      });
    });
  }

  void onSignUpComplete() {
    localDbProvider.saveUser(baseProvider.myUser);
    //TODO
  }
}
