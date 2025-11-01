import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iwms_citizen_app/logic/auth/auth_bloc.dart';
import 'package:iwms_citizen_app/logic/auth/auth_event.dart';
import 'package:iwms_citizen_app/logic/auth/auth_state.dart'; // <-- Import states
import '../../../core/constants.dart' show kPrimaryColor;
import '../../../core/theme/app_colors.dart'; // Assuming you have this file for kPrimaryColor

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showLocationDialog();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showLocationDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showLocationDialog();
      return;
    }
  }

  void _showLocationDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Location Services'),
            content: const Text(
                'Location services are required for this app. Please enable location services.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _login() {
    final String userName = _usernameController.text;
    final String password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthDriverLoginRequested(
            userName: userName,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // --- FIX: Use your correct state name 'AuthStateFailure' ---
            if (state is AuthStateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                // --- FIX: Use the '.message' property from your state ---
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Note: Navigation on success is handled by the GoRouter redirect.
          },
          builder: (context, state) {
            // --- FIX: Use your correct loading state 'AuthStateInitial' ---
            final bool isLoading = state is AuthStateInitial;

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1),
                        Center(
                          child: Image.asset(
                            'assets/images/driver_logo.png', // Driver logo
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Username",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(102, 102, 102, 1))),
                            const SizedBox(height: 5),
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Password",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(102, 102, 102, 1))),
                            const SizedBox(height: 5),
                            TextField(
                              obscureText: _obscureText,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                ),
                                fillColor: const Color.fromRGBO(240, 240, 240, 1),
                                filled: true,
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(186, 186, 186, 1)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40.0),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  kPrimaryColor, // Use theme color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            child: const Text(
                              'LOGIN',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}