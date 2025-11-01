// lib/logic/auth/auth_state.dart
import 'package:equatable/equatable.dart';

// The Roles for the whole "super app"
enum UserRole {
  unknown,
  unauthenticated,
  citizen,
  operator,
  driver,
  supervisor,
  engineer,
  admin,
}

// The base class for all Auth States.
class AuthState extends Equatable {
  final UserRole role;
  final String? userName;

  const AuthState({this.role = UserRole.unknown, this.userName});

  @override
  List<Object?> get props => [role, userName];
}

// 1. Initial/Loading State
class AuthStateInitial extends AuthState {
  const AuthStateInitial() : super(role: UserRole.unknown);
}

// 2. Not Logged In
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated() : super(role: UserRole.unauthenticated);
}

// 3. Base class for ANY authenticated user
abstract class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated({required UserRole role, required String userName})
      : super(role: role, userName: userName);
}

// 4. Logged In as a Citizen
class AuthStateAuthenticatedCitizen extends AuthStateAuthenticated {
  const AuthStateAuthenticatedCitizen({required String userName})
      : super(role: UserRole.citizen, userName: userName);
}

// 5. Logged In as a Driver
class AuthStateAuthenticatedDriver extends AuthStateAuthenticated {
  const AuthStateAuthenticatedDriver({required String userName})
      : super(role: UserRole.driver, userName: userName);
}

// 6. Failure State
class AuthStateFailure extends AuthState {
  final String message;
  const AuthStateFailure({required this.message}) : super(role: UserRole.unknown);

  @override
  List<Object?> get props => [role, userName, message];
}