import 'package:dio/dio.dart';
import 'dart:io';

import 'add_product_service.dart';
import '../../core/utils/permission_utils.dart';

class AddProductController {
  final AddProductService _service = AddProductService();

  bool isLoading = false;

  Future<String?> addProduct({
    required String title,
    required int price,
    required String imagePath,
  }) async {
    isLoading = true;

    try {
      // 1️⃣ Ask storage permission
      final hasPermission = await PermissionUtils.requestStoragePermission();

      if (!hasPermission) {
        isLoading = false;
        return 'Storage permission denied';
      }

      // 2️⃣ Verify file exists
      final file = File(imagePath);
      if (!file.existsSync()) {
        isLoading = false;
        return 'File does not exist';
      }

      // 3️⃣ Create multipart file
      final imageFile = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );

      // 4️⃣ CALL API (this was missing ❗)
      await _service.addProduct(title: title, price: price, image: imageFile);

      isLoading = false;
      return null; // success
    } on DioException catch (e) {
      isLoading = false;

      if (e.type == DioExceptionType.connectionTimeout) {
        return 'Upload timeout. Try again.';
      }

      return 'Failed to upload product';
    } catch (e) {
      isLoading = false;
      return 'Unexpected error: $e';
    }
  }
}
