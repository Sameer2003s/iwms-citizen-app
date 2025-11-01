import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Layered imports
import '../../../core/constants.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../router/app_router.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _countryCodes = ['+91', '+1', '+44', '+86', '+49'];
  String _selectedCountryCode = '+91';

  final TextEditingController _mobileController = TextEditingController(); 
  

  void _handleContinue(BuildContext context) {
    final mobileNumber = _mobileController.text.trim();
    if (mobileNumber.length == 10) { 
      // Dispatch the Login Event with mobile and mock OTP
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          mobileNumber: mobileNumber,
          otp: '123456', // Mock OTP
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _navigateToRegister(BuildContext context) {
    context.push(AppRoutePaths.citizenRegister); 
  }

  Widget _appLogoAsset() {
    return Container(
      height: 100,
      width: 100,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2), 
      ),
      child: Image.asset('assets/images/logo.png', width: 80, height: 80),
    );
  }

  Widget _buildCountryCodeDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorderColor, width: 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          icon: const Icon(Icons.arrow_drop_down, color: kTextColor),
          style: const TextStyle(fontSize: 16, color: kTextColor),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          dropdownColor: Colors.white,
          items: _countryCodes.map((String code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Text(code, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCountryCode = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // There is no BlocListener checking for AuthFailure, so this file is safe.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), 
              
              _appLogoAsset(),
              const SizedBox(height: 32),

              Text(
                "Welcome to IWMS",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: kTextColor), 
              ),
              const SizedBox(height: 8),
              Text(
                "Enter your mobile number to get started or log in.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: kTextColor.withOpacity(0.7)), 
              ),
              const SizedBox(height: 40),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: kTextColor, 
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _buildCountryCodeDropdown(),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(color: kTextColor, fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                            hintText: "Mobile Number (10 digits)",
                            hintStyle: TextStyle(color: kPlaceholderColor, fontSize: 16),
                            filled: true,
                            fillColor: kContainerColor,
                            counterText: '', 
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(color: kBorderColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(color: kBorderColor, width: 1), 
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              borderSide: BorderSide(color: kPrimaryColor, width: 2), 
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Continue (Send OTP)",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              GestureDetector(
                onTap: () => _navigateToRegister(context),
                child: Text(
                  "New user? Registration is quick and easy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: kTextColor.withOpacity(0.7),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}