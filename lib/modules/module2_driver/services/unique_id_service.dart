import 'package:intl/intl.dart';
import 'dart:math'; // For random number

class UniqueIdService {
  static String generateScreenUniqueId() {
    // Generates a unique ID based on timestamp
    final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    return 'SCR_$timestamp';
  }

  // FIX: Added the missing getDeviceId() method
  Future<String> getDeviceId() async {
    // This is a mock implementation.
    // In a real app, you would use a package like 'device_info_plus'
    // to get a real, persistent device ID.
    // For now, we return a random string.
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return Future.value('mock_device_id_$random');
  }
}
