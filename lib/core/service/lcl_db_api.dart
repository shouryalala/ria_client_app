import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalApi{
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get onboardFile async {
    final path = await _localPath;
    return File('$path/onboarded.txt');
  }

  Future<File> writeOnboardFile(String content) async {
    final file = await onboardFile;
    return file.writeAsString(content);
  }

  Future<File> get userFile async {
    final path = await _localPath;
    return File('$path/userdetails.txt');
  }

  Future<List<String>> readUserFile() async{
    final file = await userFile;
    return file.readAsLines();
  }

  Future<File> writeUserFile(String content) async{
    final file = await userFile;
    return file.writeAsString(content);
  }

  Future<void> deleteOnboardFile() async{
    final file = await onboardFile;
    if(file != null)return file.delete();
  }

  Future<void> deleteUserFile() async{
    final file = await userFile;
    if(file != null)return file.delete();
  }

  Future<File> get statsFile async {
    final path = await _localPath;
    return File('$path/userStats.txt');
  }

  Future<String> readStatsFile() async{
    final file = await statsFile;
    return file.readAsString();
  }

  Future<File> writeStatsFile(String content) async{
    final file = await statsFile;
    return file.writeAsString(content);
  }

  Future<void> deleteStatsFile() async{
    final file = await statsFile;
    if(file != null)return file.delete();
  }
}