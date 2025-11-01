// lib/modules/module2_driver/presentation/driver_qr_scan_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:iwms_citizen_app/router/app_router.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/location_service.dart';
import 'package:iwms_citizen_app/core/theme/app_colors.dart';

class DriverQrScanScreen extends StatefulWidget {
  const DriverQrScanScreen({super.key});

  @override
  State<DriverQrScanScreen> createState() => _DriverQrScanScreenState();
}

class _DriverQrScanScreenState extends State<DriverQrScanScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  bool _locationReady = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _initGlobalLocation();
  }

  Future<void> _initGlobalLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      await LocationService.refresh(); // calls Geolocator internally
      setState(() {
        _locationReady = true;
        _isFetchingLocation = false;
      });
      debugPrint("📍 Global location ready: "
          "${LocationService.latitude}, ${LocationService.longitude}");
    } catch (e) {
      debugPrint("⚠️ Location error: $e");
      setState(() {
        _locationReady = false;
        _isFetchingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e. Please enable location.')),
      );
      context.pop(); // Go back if location fails
    }
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (!_isScanning) return;
    if (!_locationReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fetching location... please wait")),
      );
      return;
    }

    final barcode = capture.barcodes.first.rawValue ?? '';
    if (barcode.isEmpty) return;

    setState(() => _isScanning = false);
    await cameraController.stop();

    final parsedData = _parseQrData(barcode);
    final customerId = parsedData['Customer Id'] ?? 'Unknown';
    final customerName = parsedData['Owner Name'] ?? 'Unknown';
    final contactNo = parsedData['address'] ?? 'Unknown'; // 'address' in QR? ok.

    // Get coordinates globally
    final lat = LocationService.latitude.toString();
    final lon = LocationService.longitude.toString();

    // --- NEW: Navigate using GoRouter ---
    context.pushReplacement(AppRoutePaths.driverData, extra: {
      'customerId': customerId,
      'customerName': customerName,
      'contactNo': contactNo,
      'latitude': lat,
      'longitude': lon,
    });
  }

  Map<String, String> _parseQrData(String data) {
    final Map<String, String> result = {};
    for (final line in data.split('\n')) {
      final parts = line.split(':');
      if (parts.length == 2) {
        result[parts[0].trim()] = parts[1].trim();
      }
    }
    return result;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isFetchingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: 16),
                  Text("Fetching location..."),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _handleDetection,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 32),
                    onPressed: () {
                      cameraController.stop();
                      context.pop(); // --- NEW: Use context.pop() ---
                    },
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      label: const Text("Toggle Flash", style: TextStyle(color: Colors.white)),
                      onPressed: () => cameraController.toggleTorch(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}