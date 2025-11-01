// lib/modules/module2_driver/services/bluetooth_service.dart
import 'dart:async';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothService {
  StreamSubscription? _subscription;
  String weight = '--';

  void updateWeight(String newWeight) {
    weight = newWeight;
  }

  void dispose() {
    _subscription?.cancel();
  }
}