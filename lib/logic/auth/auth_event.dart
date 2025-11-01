// lib/logic/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event for CITIZEN login
class AuthLoginRequested extends AuthEvent {
  final String mobileNumber;
  final String otp;

  const AuthLoginRequested({required this.mobileNumber, required this.otp});

  @override
  List<Object> get props => [mobileNumber, otp];
}

// Event for DRIVER login
class AuthDriverLoginRequested extends AuthEvent {
  final String userName;
  final String password;

  const AuthDriverLoginRequested({
    required this.userName,
    required this.password,
  });

  @override
  List<Object> get props => [userName, password];
}

// Event triggered when the user logs out
class AuthLogoutRequested extends AuthEvent {}

// Event to check status on app start
class AuthStatusChecked extends AuthEvent {}