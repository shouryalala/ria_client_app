import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNo;
  String smsCode;
  final phoneFieldController = TextEditingController();
  String verificationId;

  Future<void> verifyPhone() async {
    await SmsAutoFill().listenForCode;
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print('Signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneFieldController.text,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed);
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: /*TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),*/
            PinFieldAutoFill(
              currentCode: "123456",
              onCodeChanged: pinFieldCodeChanged,
              onCodeSubmitted: pinFieldCodeSubmitted,
              codeLength: 6,
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      print("User already available..USER: " + user.toString());
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/home');
                    } else {
                      print("Signing in...");
                      Navigator.of(context).pop();
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  pinFieldCodeChanged(String otp) {
    print("onCodeChanged Triggered!" + otp);
  }

  pinFieldCodeSubmitted(String otp) {
    print("onCodeSubmitted Triggered!" + otp);
  }

  /*signIn() {
    FirebaseAuth.instance.signInWithPhoneNumber(verificationId: verificationId, smsCode: smsCode)
        .then((user) {
      Navigator.of(context).pushReplacementNamed('/homepage');
    }).catchError((e) {
      print(e);
    });
  }*/
  signIn() {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      print("Signed in: User: " + user.toString());
      Navigator.of(context).pushReplacementNamed('/home');
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                controller: phoneFieldController,
            ),
//                PhoneFieldHint(
//                controller: phoneFieldController,
//              ),
//                TextField(
//                  decoration: InputDecoration(hintText: 'Enter Phone number'),
//                  onChanged: (value) {
//                    this.phoneNo = value;
//                  },
//                ),
                SizedBox(height: 10.0),
                RaisedButton(
                    onPressed: verifyPhone,
                    child: Text('Verify'),
                    textColor: Colors.white,
                    elevation: 7.0,
                    color: Colors.blue)
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    phoneFieldController.dispose();
  }


}