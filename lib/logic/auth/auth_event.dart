// lib/logic/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event triggered when the user attempts to log in
class AuthLoginRequested extends AuthEvent {
  final String mobileNumber;
  final String otp;

  const AuthLoginRequested({required this.mobileNumber, required this.otp});

  @override
  List<Object> get props => [mobileNumber, otp];
}

// Event triggered when the user logs out
class AuthLogoutRequested extends AuthEvent {}

// Event to check status on app start
class AuthStatusChecked extends AuthEvent {}