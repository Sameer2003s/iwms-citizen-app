import 'package:flutter/material.dart';
import 'home.dart'; // Navigate to HomeScreen after registration
import '../main.dart'; // Accesses shared constants, createSlideUpRoute

// Dropdown items for property type, as suggested in the planning
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

  // Reusable custom slide-up transition function (imported from main.dart)
  Route _createRoute(Widget targetPage) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => targetPage,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _handleRegistration(BuildContext context) {
    final userName = _nameController.text.trim(); // Capture and trim the user's name

    if (userName.isNotEmpty && _addressController.text.isNotEmpty) {
      // Successful registration, navigate to Home (Dashboard) using custom transition
      // PASSING THE CAPTURED userName TO HOMESCREEN
      Navigator.of(context).pushAndRemoveUntil(
        _createRoute(HomeScreen(userName: userName)),
        (Route<dynamic> route) => false, 
      );
    } else {
      // Simple error message for demo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in Name and Address to complete registration.'),
          backgroundColor: kPrimaryColor,
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
        // Add a back button for navigation from login
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
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

              // 1. Name Field
              _buildInputField("Full Name", _nameController, hint: "John Doe"),
              
              // 2. Email Field
              _buildInputField("Email (Optional)", _emailController, hint: "e.g., example@email.com"),
              
              const SizedBox(height: 10),

              // 3. Property Type (Crucial for IWMS logistics)
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
                    border: InputBorder.none, // Remove default border since container has one
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  ),
                  initialValue: _selectedPropertyType,
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

              // 4. Address Fields
              _buildInputField("Property Address", _addressController, hint: "House/Apartment Number & Street"),
              
              TextFormField(
                decoration: const InputDecoration(hintText: "City/Town/Pin Code"),
                keyboardType: TextInputType.text,
                style: const TextStyle(color: kTextColor),
              ),
              const SizedBox(height: 30),

              // 5. Geolocation Button (Placeholder)
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

              // 6. Completion CTA
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