import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

// To save the file in the device
class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    // To check whether permission is given for this app or not.
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // If not we will ask for permission first
      await Permission.storage.request();
    }
    Directory directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    // final directory = await getApplicationDocumentsDirectory();
    // return directory.path;
    // To get the external path from device of download folder
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> writeCounter(Uint8List bytes, String name) async {
    final path = await _localPath;
    // Create a file for the path of
    // device and file name with extension
    File file = File('$path/$name');
    print("Save file");

    // Write the data in the file you have created
    return file.writeAsBytes(bytes);
  }
}

class FileSaveHelper {
  static Future<void> saveAndLaunchFile(
      Uint8List uint8list, String fileName) async {
    if (kIsWeb) {
      _saveAndLaunchFileWeb(uint8list, fileName);
    } else {
      _saveAndLaunchFileMobile(uint8list, fileName);
    }
  }

  static void _saveAndLaunchFileWeb(Uint8List uint8list, String fileName) {
    final blob = html.Blob([Uint8List.fromList(uint8list)]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  static void _saveAndLaunchFileMobile(
      Uint8List uint8list, String fileName) async {
    try {
      // final fileStorage = FileStorage();
      await FileStorage.writeCounter(uint8list, fileName);
      // final tempDir = Directory.systemTemp;
      // print(tempDir.path);
      // final directory = await getApplicationDocumentsDirectory();
      // print(directory.path);
      // final filePath = '/storage/emulated/0/Download/$fileName';
      // final file = File(filePath);
      // await file.writeAsBytes(uint8list, flush: true);

      try {
        // Dapatkan direktori dokumen
        final documentsDirectory = await getApplicationDocumentsDirectory();

        // Spesifikasikan path file di direktori dokumen
        final filePath = '${documentsDirectory.path}/$fileName';

        final result = await OpenFile.open(filePath);
        print(result.message);
        print(result.type);
        if (result.type == ResultType.done) {
          print("File opened with success");
        } else {
          print("Failed to open the file");
        }
      } catch (e) {
        print('Error opening file: $e');
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}
