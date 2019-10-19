import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
//import 'package:sms_autofill/sms_autofill.dart';

class OtpInputScreen extends StatefulWidget{
  final otpInputScreenState = _OtpInputScreenState();
  @override
  State<StatefulWidget> createState() => otpInputScreenState;

  void onOtpReceived() => otpInputScreenState.onOtpReceived();

  String getOtp() => otpInputScreenState.otp;
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  Log log = new Log("OtpInputScreen");
  String _otp;
  String _loaderMessage = "Detecting otp..";
  bool _otpFieldEnabled = true;
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
//                child: PinFieldAutoFill(  //TODO This AutoFill doesn't work
//                  currentCode: "123456",
//                  onCodeChanged: pinFieldCodeChanged,
//                  onCodeSubmitted: pinFieldCodeSubmitted,
//                  codeLength: 6,
//                ),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
                child: SpinKitDoubleBounce(
                  color: UiConstants.spinnerColor,
                  //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)),
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                _loaderMessage,
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              )
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

  String get otp => _pinEditingController.text;
}