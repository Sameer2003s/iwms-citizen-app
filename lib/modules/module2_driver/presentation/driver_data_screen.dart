import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iwms_citizen_app/core/di.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_state.dart';
import 'package:iwms_citizen_app/logic/driver/driver_bloc.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/image_compress_service.dart';
import 'package:iwms_citizen_app/modules/module2_driver/services/unique_id_service.dart';

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

class _DriverDataScreenState extends State<DriverDataScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  final TextEditingController _weightController = TextEditingController();
  // FIX: Call the static method
  final String _uniqueId = UniqueIdService.generateScreenUniqueId();
  String? _staffId;

  // FIX: Get the compress service from getIt
  final ImageCompressService _compressService = getIt<ImageCompressService>();

  @override
  void initState() {
    super.initState();
    // FIX: Get staffId from AuthBloc
    final authState = context.read<AuthBloc>().state;
    // FIX: Use correct state name
    if (authState is AuthStateAuthenticated) {
      // FIX: Use userName, which holds the staffId
      _staffId = authState.userName;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Initial quality before compress
    );
    setState(() {
      _imageFile = pickedFile;
    });
  }

  void _submitData(BuildContext context) async {
    if (_staffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Staff ID not found. Please re-login.')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a picture.')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // FIX: Compress the image using the instance method
    final compressedFile = await _compressService.compressImage(_imageFile!);

    // Dismiss loading dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    
    if (compressedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error compressing image.')),
        );
      }
      return;
    }

    // Dispatch event to DriverBloc
    if (mounted) {
      context.read<DriverBloc>().add(
            DriverDataSubmitted(
              qrData: widget.customerId,
              lat: widget.latitude,
              long: widget.longitude,
              uniqueId: _uniqueId,
              staffId: _staffId!,
              imageFile: compressedFile, // Send compressed file
              weight: _weightController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverBloc(driverRepository: getIt()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter Waste Details'),
        ),
        body: BlocConsumer<DriverBloc, DriverState>(
          listener: (context, state) {
            if (state is DriverSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green),
              );
              // Go back to the QR screen
              context.pop();
            }
            if (state is DriverSubmitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is DriverSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildImageCapture(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _submitData(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Data',
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer ID: ${widget.customerId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Name: ${widget.customerName}'),
            const SizedBox(height: 8),
            Text('Contact: ${widget.contactNo}'),
            const Divider(height: 20),
            Text('Lat: ${widget.latitude}'),
            const SizedBox(height: 8),
            Text('Long: ${widget.longitude}'),
            const Divider(height: 20),
            Text('Staff ID: ${_staffId ?? "Loading..."}'),
            const SizedBox(height: 8),
            Text('Screen UID: $_uniqueId'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCapture() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageFile != null
              ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
              : const Center(
                  child: Text('No image selected.',
                      style: TextStyle(color: Colors.grey))),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Take Picture'),
        ),
      ],
    );
  }
}

