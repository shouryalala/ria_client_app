import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class IOUtil {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/onboarded.txt');
  }

  Future<int> isUserOnboarded() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeOnboardStatus(int flag) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$flag');
  }
}