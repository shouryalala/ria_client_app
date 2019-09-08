import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomTimePickerModel extends TimePickerModel {
  CustomTimePickerModel(DateTime initialTime, LocaleType localType)
      : super(currentTime: initialTime, locale: localType);

  @override
  String rightDivider() => "";

  @override
  List<int> layoutProportions() => [100, 100, 1];
}