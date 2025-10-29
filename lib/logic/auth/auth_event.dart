// lib/logic/auth/auth_event.dart

import 'package:equatable/equatable.dart';

// The base class for all Auth Events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event triggered when the user attempts to log in (e.g., clicks the button)
class AuthLoginRequested extends AuthEvent {
  final String mobileNumber;
  final String otp;

  const AuthLoginRequested({required this.mobileNumber, required this.otp});

  @override
  List<Object> get props => [mobileNumber, otp];
}

// Event triggered when the user logs out (e.g., clicks 'Logout' in the Drawer)
class AuthLogoutRequested extends AuthEvent {}

// Event triggered automatically to check if a user is already logged in 
// (e.g., when the app first starts).
class AuthStatusChecked extends AuthEvent {}