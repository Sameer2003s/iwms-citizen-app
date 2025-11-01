import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_event.dart';
import 'package:iwms_citizen_app/logic/auth/auth_state.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/location_service.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/unique_id_service.dart';
import 'package:iwms_citizen_app/router/app_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DriverQrScanScreen extends StatefulWidget {
  const DriverQrScanScreen({super.key});

  @override
  State<DriverQrScanScreen> createState() => _DriverQrScanScreenState();
}

class _DriverQrScanScreenState extends State<DriverQrScanScreen> {
  String? _staffId;
  String? _uniqueId;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() async {
    // FIX: Call the static method from your unique_id_service.dart
    _uniqueId = UniqueIdService.generateScreenUniqueId();

    // Get staff ID from Auth BLoC
    final authState = context.read<AuthBloc>().state;
    // FIX: Use the correct state name 'AuthStateAuthenticated'
    if (authState is AuthStateAuthenticated) {
      // Use userName, as it holds the staff ID/name from your auth_repository
      _staffId = authState.userName;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isNotEmpty) {
      final String? qrData = capture.barcodes.first.rawValue;
      if (qrData != null) {
        // Stop the camera
        _scannerController.stop();

        // Get current location
        // FIX: Call the static 'refresh' method from your location_service.dart
        LocationService.refresh().then((_) {
          // FIX: Read from the static variables
          final lat = LocationService.latitude.toString();
          final long = LocationService.longitude.toString();

          // Navigate to Data Screen
          context.push(
            AppRoutePaths.driverData,
            extra: {
              'customerId': qrData,
              'customerName': 'N/A', // You'll get this from API
              'contactNo': 'N/A', // You'll get this from API
              'latitude': lat,
              'longitude': long,
            },
            // Re-start camera when we return
          ).then((_) {
            if(mounted) {
              _scannerController.start();
            }
          });
        }).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error getting location: $e')),
            );
            // Re-start camera on error
            _scannerController.start();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Customer QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _scannerController, // Assign controller
              onDetect: _onDetect,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Text(
                'Staff: ${_staffId ?? "Loading..."}\nUID: ${_uniqueId ?? "Loading..."}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

