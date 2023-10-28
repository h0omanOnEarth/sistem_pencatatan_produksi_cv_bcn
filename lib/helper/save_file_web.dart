import 'dart:typed_data';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:open_file/open_file.dart' as open_file;
import 'package:flutter/foundation.dart' show kIsWeb;

class FileSaveHelper {
  static Future<void> saveAndLaunchFile(Uint8List uint8list, String fileName) async {
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

  static void _saveAndLaunchFileMobile(Uint8List uint8list, String fileName) async {
    try {
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(uint8list);

      final result = await open_file.OpenFile.open(filePath);
      if (result.type == open_file.ResultType.done) {
        print("File opened with success");
      } else {
        print("Failed to open the file");
      }
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}
