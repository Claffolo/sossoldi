import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class CSVFilePicker {
  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      int sdkInt = androidInfo.version.sdkInt;

      if (sdkInt <= 32) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  static Future<File?> pickCSVFile() async {
    bool permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      throw Exception('Storage permission is required');
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      return File(result.files.first.path!);
    }
    return null;
  }

  static Future<String?> saveCSVFile(String csv) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      return null;
    }
    
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = join(selectedDirectory, 'sossoldi_export_$timestamp.csv');
    
    await File(filePath).writeAsString(csv);
    return filePath;
  }
}
