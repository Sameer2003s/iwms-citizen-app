// lib/modules/module2_driver/presentation/driver_data_screen.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart'; // <-- USE DIO
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


// --- Import Main App Components ---
import 'package:iwms_citizen_app/router/route_observer.dart'; // For routeObserver
import 'package:iwms_citizen_app/core/di.dart'; // For getIt<Dio>()
import 'package:iwms_citizen_app/core/theme/app_colors.dart';
import 'package:iwms_citizen_app/router/app_router.dart';

// --- Import Module 2 Services ---
import '../services/bluetooth_service.dart';
import '../services/unique_id_service.dart';
import '../services/image_compress_service.dart';


class DriverDataScreen extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String contactNo;
  final String latitude;
  final String longitude;

  const DriverDataScreen({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.contactNo,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DriverDataScreen> createState() => _DriverDataScreenState();
}

class _DriverDataScreenState extends State<DriverDataScreen>
    with WidgetsBindingObserver, RouteAware { // Keep RouteAware
      
  final ImagePicker _picker = ImagePicker();
  late String screenUniqueId;
  late Dio _dio; // --- Use Dio ---

  final bluetooth = BluetoothService();
  bool connected = false;
  String latestWeight = "--";
  bool _isSubmitting = false;
  BluetoothConnection? _connection;
  String? activeType; 

  List<Map<String, dynamic>> wasteTypes = [];
  Map<String, Map<String, dynamic>> _wasteData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _dio = getIt<Dio>(); // --- Get Dio from GetIt ---
    screenUniqueId = UniqueIdService.generateScreenUniqueId();
    _wasteData.clear();
    latestWeight = "--";

    Future.delayed(const Duration(seconds: 1), () async {
      debugPrint("♻️ Reinitializing Bluetooth adapter...");
      await FlutterBluetoothSerial.instance.cancelDiscovery();
      await FlutterBluetoothSerial.instance.requestEnable();
      await _resetBluetooth();
      await _initBluetooth();
    });

    _fetchWasteTypes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the global routeObserver from main.dart
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  Future<void> _resetBluetooth() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _connection = null;
        connected = false;
        debugPrint("🔌 Bluetooth connection reset successfully");
      }
    } catch (e) {
      debugPrint("⚠️ Error while resetting Bluetooth: $e");
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    try {
      _connection?.dispose();
      connected = false;
    } catch (_) {}
    super.dispose();
  }

  @override
  void didPopNext() {
    // This is called when navigating *back* to this screen
    debugPrint("🔄 Returned → reconnecting");
    _reconnectBluetoothWithRetry();
  }

  Future<void> _reconnectBluetoothWithRetry({int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        await _resetBluetooth();
        await _initBluetooth();
        if (connected) {
          debugPrint("✅ Reconnected on attempt ${i + 1}");
          return;
        }
      } catch (e) {
        debugPrint("⚠️ Retry ${i + 1} failed: $e");
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !connected) {
      _initBluetooth();
    }
  }

  // ==================== FETCH WASTE TYPES (using Dio) ====================
  Future<void> _fetchWasteTypes() async {
    try {
      // --- Use Dio ---
      final response = await _dio.get(
        'https://zigma.in/iwms_app/api/waste/get_waste_type.php',
      );
      final data = response.data; // Dio automatically decodes JSON

      if (data['status'] == 'success') {
        setState(() {
          wasteTypes = List<Map<String, dynamic>>.from(data['data']);
          _wasteData = {
            for (var item in wasteTypes)
              item['waste_type_name'].toString().toLowerCase(): {
                'waste_type_id': item['id'], 
                'unique_id': null, 
                'image': null,
                'weight': '--',
                'finalWeight': null,
                'isAdded': false,
              }
          };
        });
      }
    } catch (e) {
      debugPrint('Error fetching waste types: $e');
    }
  }

  // ==================== IMAGE CAPTURE ====================
  Future<File?> _captureImage(String type) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;

    final original = File(picked.path);
    final compressed = await ImageCompressService.compress(original);

    setState(() {
      activeType = type;
      final updated = Map<String, dynamic>.from(_wasteData[type]!);
      updated['image'] = compressed;
      updated['weight'] = latestWeight;
      _wasteData = {
        ..._wasteData,
        type: updated,
      };
    });
    return compressed;
  }

  // ==================== FETCH WASTE RECORD (using Dio) ====================
  Future<void> _fetchWasteRecord(String type) async {
    try {
      final response = await _dio.post(
        'https://zigma.in/iwms_app/api/waste/get_saved_waste.php',
        data: {
          'screen_unique_id': screenUniqueId,
          'customer_id': widget.customerId,
          'waste_type': _wasteData[type]!['waste_type_id'].toString(),
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final data = response.data;
      if (data['status'] == 'success' && data['data'] != null) {
        final record = data['data'];

        setState(() {
          final updated = Map<String, dynamic>.from(_wasteData[type]!);
          updated['unique_id'] = record['unique_id']; 
          updated['waste_type_id'] =
              _wasteData[type]!['waste_type_id']; 
          updated['weight'] = record['weight'] ?? '--';
          updated['finalWeight'] = record['weight'] ?? '--';
          updated['isAdded'] = true;

          _wasteData = {..._wasteData, type: updated};
        });
      } 
    } catch (e) {
      debugPrint('⚠️ Error fetching record for $type: $e');
    }
  }

  // ==================== HANDLE ADD/UPDATE (using Dio) ====================
  Future<void> _handleAdd(String type) async {
    final data = _wasteData[type]!;

    if (data['image'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture image for $type first')),
      );
      return;
    }

    if (latestWeight == "--") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please ensure weight is recorded for $type')),
      );
      return;
    }

    final currentWeight = latestWeight;
    setState(() => _isSubmitting = true);

    try {
      final image = data['image'] as File;
      final bool isUpdate = data['isAdded'] == true;
      final uri = isUpdate
          ? 'https://zigma.in/iwms_app/api/waste/update_waste_sub.php'
          : 'https://zigma.in/iwms_app/api/waste/insert_waste_sub.php';

      // --- Create FormData for Dio ---
      final formData = FormData.fromMap({
        'screen_unique_id': screenUniqueId,
        'customer_id': widget.customerId,
        'waste_type': _wasteData[type]!['waste_type_id'].toString(),
        'weight': currentWeight,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'image': await MultipartFile.fromFile(image.path, 
                    filename: image.path.split('/').last),
      });

      if (isUpdate && data['unique_id'] != null) {
        formData.fields.add(MapEntry('id', data['unique_id'].toString()));
      } else if (isUpdate && data['id'] != null) {
        formData.fields.add(MapEntry('id', data['id'].toString()));
      }
      
      // --- Make Dio POST request ---
      final response = await _dio.post(uri, data: formData);
      final result = response.data;

      if (result['status'] == 'success') {
        await _fetchWasteRecord(type);
        setState(() {
          activeType = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUpdate
                  ? '$type waste updated successfully'
                  : '$type waste added successfully',
            ),
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Failed to save $type');
      }
    } catch (e, stack) {
      debugPrint('⚠️ Error saving $type: $e');
      debugPrint(stack.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving $type: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ==================== SUBMIT MAIN FORM (using Dio) ====================
  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    try {
      final uri = 'https://zigma.in/iwms_app/api/waste/insert_waste_main.php';
      
      // --- Create FormData for Dio ---
      final formData = FormData.fromMap({
        'screen_unique_id': screenUniqueId,
        'customer_id': widget.customerId,
        'entry_type': 'app', 
        'total_waste_collected':
            _wasteData.values.fold<double>(0, (sum, e) {
          final w = double.tryParse(
                  e['finalWeight']?.toString() ?? e['weight'].toString()) ??
              0;
          return sum + w;
        }).toString(),
      });

      // --- Make Dio POST request ---
      final response = await _dio.post(uri, data: formData);
      final result = response.data;

      if (result['status'] == 'success') {
        await _resetBluetooth();
        await Future.delayed(const Duration(milliseconds: 500));
        await _initBluetooth();

        setState(() {
          _wasteData.clear();
          latestWeight = "--";
          screenUniqueId = UniqueIdService.generateScreenUniqueId();
        });
        
        // --- Show dialog and then pop back to home ---
        _showDialog('Success', 'Main record submitted successfully!', () {
          // On OK, pop this screen and go back to Driver Home
          context.go(AppRoutePaths.driverHome);
        });

      } else {
        throw Exception(result['message'] ?? 'Failed to submit main record');
      }
    } catch (e) {
      _showDialog('Error', 'Submission failed: $e', () {
         Navigator.of(context).pop(); // Just close dialog
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ==================== DIALOG ====================
  void _showDialog(String title, String msg, VoidCallback onOk) {
    showDialog(
      context: context,
      barrierDismissible: false, // Don't allow closing by tapping outside
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: onOk,
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  // ==================== UI HELPERS ====================
  Widget _buildCustomerInfo() => Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Customer Name', widget.customerName),
            _infoTile('Customer ID', widget.customerId),
            _infoTile('Contact No', widget.contactNo),
          ],
        ),
      );

  Widget _infoTile(String label, String value) => ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      );

  Widget _buildWasteSection(String type, String displayName) {
    final data = _wasteData[type]!;
    final image = data['image'] as File?;
    final isAdded = data['isAdded'] as bool;
    final displayWeight = data['finalWeight'] ?? data['weight'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: (type == activeType && !isAdded) ? AppColors.primaryBlue : Colors.black12,
          width: (type == activeType && !isAdded) ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (image != null)
              GestureDetector(
                onTap: () => _showPreview(image),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(image,
                      width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.camera_alt_outlined,
                    size: 50, color: Colors.grey),
              ),
            const SizedBox(height: 10),
            Text(
              "Weight: ${displayWeight == '--' ? '--' : '$displayWeight kg'}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final file = await _captureImage(type);
                    if (file != null) {
                      setState(() {
                        data['image'] = file;
                        data['weight'] = latestWeight;
                      });
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdded
                        ? AppColors.warning // <-- FIX 1
                        : AppColors.success,
                  ),
                  onPressed: () => _handleAdd(type),
                  icon: Icon(isAdded ? Icons.refresh : Icons.add, color: Colors.white),
                  label: Text(isAdded ? "Update" : "Add", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(File image) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(image),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  // ==================== MAIN UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: wasteTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.blueGrey.shade50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "📟 Live Weight: ${latestWeight == '--' ? '--' : '$latestWeight kg'}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCustomerInfo(),
                        const SizedBox(height: 15),
                        ...wasteTypes.map((w) {
                          final type =
                              w['waste_type_name'].toString().toLowerCase();
                          final name = w['waste_type_name'];
                          return _buildWasteSection(type, name);
                        }),
                        const SizedBox(height: 25),
                        _isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 12),
                                ),
                                onPressed: _submitForm,
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ==================== BLUETOOTH INIT ====================
  Future<void> _initBluetooth() async {
    if (connected) return;

    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse, // Geolocation also needs this
    ].request();

    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    if (devices.isEmpty) {
      debugPrint("⚠️ No bonded Bluetooth devices found.");
      return;
    }

    final hc05 = devices.firstWhere(
      (d) => (d.name ?? "").toUpperCase().contains("HC"),
      orElse: () => devices.first, // Fallback
    );

    try {
      debugPrint("🔌 Connecting to ${hc05.name}...");
      final conn = await BluetoothConnection.toAddress(hc05.address);
      setState(() {
        _connection = conn;
        connected = true;
      });

      String buffer = "";
      conn.input?.listen((Uint8List data) {
        final text = utf8.decode(data);
        buffer += text;
        if (buffer.contains('\n')) {
          final parts = buffer.split('\n');
          for (var line in parts.take(parts.length - 1)) {
            final trimmed = line.trim();
            if (trimmed.isEmpty) continue;

            bluetooth.updateWeight(trimmed);

            setState(() {
              latestWeight = trimmed;
              if (activeType != null && _wasteData.containsKey(activeType)) {
                final current = _wasteData[activeType!]!;
                if (current['isAdded'] == false) {
                  final updated = Map<String, dynamic>.from(current);
                  updated['weight'] = trimmed;
                  _wasteData = {
                    ..._wasteData,
                    activeType!: updated,
                  };
                }
              }
            });
          }
          buffer = parts.last;
        }
      }).onDone(() {
        setState(() => connected = false);
      });
    } catch (e) {
      debugPrint("⚠️ Bluetooth connection error: $e");
    }
  }
}