import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

///Storing the following in the temporary cache:
///-Single Visit objects
///-Corresponding Visit Assistant objects
///
class CacheApi{
  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File> get visitFile async {
    final path = await _localPath;
    return File('$path/currentvisit.txt');
  }

  Future<List<String>> readVisitFile() async{
    final file = await visitFile;
    return file.readAsLines();
  }

  Future<File> writeVisitFile(String content) async{
    final file = await visitFile;
    return file.writeAsString(content);
  }

  Future<File> get assistantFile async{
    final path = await _localPath;
    return File('$path/vstastnt.txt');
  }

  Future<List<String>> readAssistantFile() async{
    final file = await assistantFile;
    return file.readAsLines();
  }

  Future<File> writeAssistantFile(String content) async{
    final file = await assistantFile;
    return file.writeAsString(content);
  }
}