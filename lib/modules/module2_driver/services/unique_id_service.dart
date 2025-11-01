// lib/modules/module2_driver/services/unique_id_service.dart
import 'package:intl/intl.dart';

class UniqueIdService {
  static String generateScreenUniqueId() {
    // Generates a unique ID based on timestamp
    final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    return 'SCR_$timestamp';
  }
}