import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpInputScreen extends StatefulWidget{
  final otpInputScreenState = _OtpInputScreenState();
  @override
  State<StatefulWidget> createState() => otpInputScreenState;

  String getOtp() => otpInputScreenState.otp;
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  String _otp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
            child: PinFieldAutoFill(  //TODO This AutoFill doesn't work
              currentCode: "123456",
              onCodeChanged: pinFieldCodeChanged,
              onCodeSubmitted: pinFieldCodeSubmitted,
              codeLength: 6,
            ),
          ),
        )
    );
  }

  pinFieldCodeChanged(String otp) {
    print("onCodeChanged Triggered!" + otp);
    this._otp = otp;
  }

  pinFieldCodeSubmitted(String otp) {
    print("onCodeSubmitted Triggered!" + otp);
    this._otp = otp;
  }

  String get otp => _otp;
}