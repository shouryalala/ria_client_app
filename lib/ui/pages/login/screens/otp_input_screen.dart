import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class OtpInputScreen extends StatefulWidget{
  static const int index = 1;  //pager index
  OtpInputScreen({Key key}):super(key: key);
//  final otpInputScreenState = _OtpInputScreenState();

  @override
  State<StatefulWidget> createState() => OtpInputScreenState();

//  void onOtpReceived() => otpInputScreenState.onOtpReceived();
//  void onOtpTimeout() => otpInputScreenState.onOtpAutoDetectTimeout();
//  String getOtp() => otpInputScreenState.getOtp();
}

class OtpInputScreenState extends State<OtpInputScreen> {
  Log log = new Log("OtpInputScreen");
  String _otp;
  String _loaderMessage = "Detecting otp..";
  bool _otpFieldEnabled = true;
  bool _autoDetectingOtp = true;
  final _pinEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                  child: PinInputTextField(
                    enabled: _otpFieldEnabled,
                    pinLength: 6,
                    decoration: UnderlineDecoration(
                        color: Colors.grey,
                        textStyle: TextStyle(
                               fontSize: 20,
                               color: Colors.black)),
                    controller: _pinEditingController,
                    autoFocus: true,
                    textInputAction: TextInputAction.go,
                    onSubmit: (pin) {
                      log.debug("Pressed submit for pin: " + pin.toString() + "\n  No action taken.");
                    },
                  )
              ),
              SizedBox(height: 16.0),
              (_autoDetectingOtp)?Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
                child: SpinKitDoubleBounce(
                  color: UiConstants.spinnerColor,
                  //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
                ),
              ):Container(),
              (_autoDetectingOtp)?SizedBox(height: 5.0):Container(),
              Text(
                _loaderMessage,
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              (!_autoDetectingOtp)?FlatButton(
                child: Text('Resend'),
                onPressed: () {
                  log.debug("Resend action triggered");
                },
              ): Container()
            ],
          )
        )
    );
  }

  /*pinFieldCodeChanged(String otp) {
    print("onCodeChanged Triggered!" + otp);
    this._otp = otp;
  }

  pinFieldCodeSubmitted(String otp) {
    print("onCodeSubmitted Triggered!" + otp);
    this._otp = otp;
  }*/
  onOtpReceived() {
    setState(() {
      _otpFieldEnabled = false;
      _loaderMessage = "Signing in..";
    });
  }

  onOtpAutoDetectTimeout() {
    setState(() {
      _otpFieldEnabled = true;
      _autoDetectingOtp = false;
      _loaderMessage = "Couldn't auto-detect otp";
    });
  }

  String get otp => _pinEditingController.text;

}