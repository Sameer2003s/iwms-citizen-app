// lib/logic/auth/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart'; 
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  final Future<void> initialization; 

  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository, 
        initialization = authRepository.initialize(), 
        super(const AuthStateInitial()) {
    
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDriverLoginRequested>(_onDriverLoginRequested); // <-- Handler added

    initialization.then((_) {
      add(AuthStatusChecked()); 
    });
  }
  
  Future<void> _onStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateInitial()); 
    
    final user = await _authRepository.getAuthenticatedUser(); 

    if (user != null) {
      switch (user.role) {
        case 'citizen':
          emit(AuthStateAuthenticatedCitizen(userName: user.userName));
          break;
        case 'driver':
          emit(AuthStateAuthenticatedDriver(userName: user.userName));
          break;
        default:
          await _authRepository.logout();
          emit(const AuthStateUnauthenticated());
          break;
      }
    } else {
      emit(const AuthStateUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateInitial()); // Set loading state
    try {
      // CITIZEN login
      final user = await _authRepository.login(
        mobileNumber: event.mobileNumber, 
        otp: event.otp,                 
      );
      emit(AuthStateAuthenticatedCitizen(userName: user.userName));
    } catch (e) {
      emit(AuthStateFailure(message: e.toString()));
    }
  }

  Future<void> _onDriverLoginRequested(
    AuthDriverLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateInitial()); // Set loading state
    try {
      // DRIVER login (now calls the repo)
      final user = await _authRepository.loginDriver(
        userName: event.userName,
        password: event.password,
      );
      emit(AuthStateAuthenticatedDriver(userName: user.userName));
    } catch (e) {
      emit(AuthStateFailure(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout(); 
    emit(const AuthStateUnauthenticated());
  }
}