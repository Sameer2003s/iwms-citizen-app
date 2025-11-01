import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/image_compress_service.dart';

class DriverRepository {
  final Dio _dio;
  final ImageCompressService _compressService;

  DriverRepository({required Dio dio, required ImageCompressService compressService})
      : _dio = dio,
        _compressService = compressService;

  Future<Map<String, dynamic>> submitWasteData({
    required String qrData,
    required String lat,
    required String long,
    required String uniqueId,
    required String staffId,
    required XFile? imageFile,
    String? weight,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'action': 'add_d2d_data',
        'qr_data': qrData,
        'lat': lat,
        'long': long,
        'uniqueid': uniqueId,
        'staffid': staffId,
        'weight': weight ?? '', // Send empty string if null
      });

      if (imageFile != null) {
        // Compress the image first
        final compressedFile = await _compressService.compressImage(imageFile);
        if (compressedFile != null) {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(
              compressedFile.path,
              filename: 'waste_image.jpg',
            ),
          ));
        }
      }

      final response = await _dio.post(
        'http://zigma.in:80/d2d_app/d2d_data.php',
        data: formData,
      );

      if (response.data is String) {
        return json.decode(response.data) as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to submit waste data: $e');
    }
  }
}
