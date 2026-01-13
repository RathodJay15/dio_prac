import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // 🔹 Android 13+ → photos permission
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) {
      return true;
    }

    final photosRequest = await Permission.photos.request();
    if (photosRequest.isGranted) {
      return true;
    }

    // 🔹 Android 12 and below → storage permission
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return true;
    }

    final storageRequest = await Permission.storage.request();
    if (storageRequest.isGranted) {
      return true;
    }

    // 🔹 If permanently denied, open settings
    if (photosRequest.isPermanentlyDenied ||
        storageRequest.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }
}
