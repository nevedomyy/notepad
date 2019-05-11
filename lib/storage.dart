import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class Storage {
  int _key;

  Storage(this._key);

  Future<String> get _localPath async{
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async{
    final path = await _localPath;
    return File('$path/note-$_key.txt');
  }

  Future<String> readFile() async{
    try {
      final file = await _localFile;
      return await file.readAsString();
    } catch (e){
      print(e.toString());
      return '';
    }
  }

  writeFile(String text) async{
    try{
      final file = await _localFile;
      file.writeAsString('$text');
    }catch (e){
      print(e.toString());
    }
  }

  deleteFile() async{
    try{
      final file = await _localFile;
      file.delete();
    }catch (e){
      print(e.toString());
    }
  }
}