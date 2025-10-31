import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Layered imports
import '../../core/constants.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_event.dart';

// Dropdown items for property type
enum PropertyType { house, apartment, office, commercial, other }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  PropertyType? _selectedPropertyType;

  void _handleRegistration(BuildContext context) {
    final userName = _nameController.text.trim(); 

    if (userName.isNotEmpty && _addressController.text.isNotEmpty) {
      
      // Simulate successful registration and automatically log the user in.
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          mobileNumber: '9999999999', // Mock mobile number for this registration
          otp: '1234', // Mock OTP
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Redirecting to dashboard...'),
          backgroundColor: kPrimaryColor,
        ),
      );
      
    } else {
      // Simple error message for demo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Name and Address to complete registration.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Helper for consistent label display
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: kTextColor,
        ),
      ),
    );
  }

  // Helper for text fields (uses built-in theme for styling)
  Widget _buildInputField(String label, TextEditingController controller, {String hint = ""}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          style: const TextStyle(color: kTextColor),
          decoration: InputDecoration(hintText: hint),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New User Registration'),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tell us about your home.",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: kTextColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your address is used to link your household to a unique QR code.",
                style: TextStyle(color: kPlaceholderColor, fontSize: 16),
              ),
              const SizedBox(height: 32),

              _buildInputField("Full Name", _nameController, hint: "John Doe"),
              
              _buildInputField("Email (Optional)", _emailController, hint: "e.g., example@email.com"),
              
              const SizedBox(height: 10),

              _buildLabel("Property Type"),
              Container(
                decoration: BoxDecoration(
                  color: kContainerColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: kBorderColor, width: 1),
                ),
                child: DropdownButtonFormField<PropertyType>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: "Select your property type",
                    border: InputBorder.none, 
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  value: _selectedPropertyType,
                  items: PropertyType.values.map((PropertyType type) {
                    return DropdownMenuItem<PropertyType>(
                      value: type,
                      child: Text(type.toString().split('.').last.toUpperCase(), style: const TextStyle(color: kTextColor)),
                    );
                  }).toList(),
                  onChanged: (PropertyType? newValue) {
                    setState(() {
                      _selectedPropertyType = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              _buildInputField("Property Address", _addressController, hint: "House/Apartment Number & Street"),
              
              TextFormField(
                decoration: const InputDecoration(hintText: "City/Town/Pin Code"),
                keyboardType: TextInputType.text,
                style: const TextStyle(color: kTextColor),
              ),
              const SizedBox(height: 30),

              const Text(
                "Location Verification (GPS Tagging)",
                style: TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement GPS map picker here
                  },
                  icon: const Icon(Icons.location_on_outlined, color: kPrimaryColor),
                  label: const Text('Pin Your Exact Location (Required)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: kPrimaryColor, width: 1),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleRegistration(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Complete Registration (Generate QR)",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}