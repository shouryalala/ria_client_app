import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomPicker({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    int hr = this.currentTime.hour;
    this.setLeftIndex((hr > 12)?hr-12:hr);
    this.setMiddleIndex(this.currentTime.minute);
    this.setRightIndex((hr > 12)?1:0);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index > 0 && index < 13) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index == 0){
      return "AM";
    }else if(index == 1) {
      return "PM";
    }else{
      return null;
    }
  }

  @override
  String leftDivider() {
    return " ";
  }

  @override
  String rightDivider() {
    return " ";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    int hr = this.currentLeftIndex();
    int min = this.currentMiddleIndex();
    int am_pm = this.currentRightIndex();
    if(am_pm == 1) {
      if(hr == 12) {
        hr = 0;
      }else{
        hr += 12;
      }
    }
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day,
        hr, min, 0) : DateTime(currentTime.year, currentTime.month, currentTime.day, hr,
        min, 0);
  }
}