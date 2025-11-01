import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressService {
  // This method name 'compressImage' must match the one used
  // in DriverRepository
  Future<XFile?> compressImage(XFile imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final targetPath = '$tempPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      targetPath,
      quality: 70, // Adjust quality as needed
    );

    if (result != null) {
      return XFile(result.path);
    }
    return null;
  }
}
