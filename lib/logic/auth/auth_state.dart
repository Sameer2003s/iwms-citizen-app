// lib/logic/auth/auth_state.dart

import 'package:equatable/equatable.dart';

// The Roles from your documentation
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
  // Represents the role the user is currently authenticated as.
  final UserRole role;

  // Additional data can be stored here (e.g., token, user details).
  final String? userName;

  const AuthState({this.role = UserRole.unknown, this.userName});

  @override
  List<Object?> get props => [role, userName];

  // Helper method for easy state copying
  const AuthState.copyWith({UserRole? role, String? userName})
      : role = role ?? UserRole.unknown,
        userName = userName;
}


// --- Specific States for better clarity ---

// 1. Initial/Loading State (e.g., checking if the user has a token)
class AuthStateInitial extends AuthState {
  const AuthStateInitial() : super(role: UserRole.unknown);
}

// 2. Not Logged In
class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated() : super(role: UserRole.unauthenticated);
}

// 3. Logged In as a Citizen (Example of a specific role state)
class AuthStateAuthenticatedCitizen extends AuthState {
  const AuthStateAuthenticatedCitizen({required String userName})
      : super(role: UserRole.citizen, userName: userName);
}

// You would add more specific states for other roles (Operator, Driver, etc.) 
// in a full production app, but this gives you the start!