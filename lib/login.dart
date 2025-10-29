import 'package:flutter/material.dart';
import 'home.dart'; // Navigate to HomeScreen (simulating success)
import 'register.dart'; // Navigate to RegisterScreen (simulating new user)
import '../main.dart'; // Accesses shared constants

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // List of common country codes (can be expanded)
  final List<String> _countryCodes = ['+91', '+1', '+44', '+86', '+49'];
  String _selectedCountryCode = '+91'; // Default to India

  // Reusable custom slide-up transition function
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

  void _handleContinue(BuildContext context) {
    // CRITICAL FIX: Login success leads directly to the CitizenDashboard
    const String placeholderName = "Citizen";
    
    Navigator.of(context).pushAndRemoveUntil(
      _createRoute(const CitizenDashboard(userName: placeholderName)), 
      (Route<dynamic> route) => false,
    );
  }

  // Helper widget to display the logo with a background
  Widget _appLogoAsset() {
    return Container(
      height: 100,
      width: 100,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, // Solid white circular background
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2), 
      ),
      child: Image.asset('assets/images/logo.png', width: 80, height: 80),
    );
  }

  // Custom Country Code Dropdown Menu
  Widget _buildCountryCodeDropdown() {
    return Container(
      height: 56, // Fixed height matching TextFormField
      decoration: BoxDecoration(
        color: Colors.white, // Use white
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

  void _navigateToRegister(BuildContext context) {
    // Navigate to RegisterScreen using custom transition
    Navigator.of(context).push(_createRoute(const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Background is now determined by the Scaffold's default color (white)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea( // Standard SafeArea for padding
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Standard top spacing
              
              // 1. Header/Logo
              _appLogoAsset(),
              const SizedBox(height: 32),

              // 2. Title and Subtitle 
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

              // 3. Input Form
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
                      // Country Code Dropdown Section
                      _buildCountryCodeDropdown(),
                      
                      // Input field
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(color: kTextColor, fontSize: 16),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
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

              // 4. Primary CTA
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

              // 5. Secondary Text Link
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