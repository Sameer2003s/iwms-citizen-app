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
    emit(const AuthStateInitial()); // Use AuthStateInitial as loading

    try {
      final user = await _authRepository.login(
        mobileNumber: event.mobileNumber, // This now matches the repo
        otp: event.otp,                 // This now matches the repo
      );
      
      if (user.role == 'citizen') {
        emit(AuthStateAuthenticatedCitizen(userName: user.userName));
      } else {
        await _authRepository.logout();
        emit(const AuthStateUnauthenticated());
      }

    } catch (e) {
      // This is the correct error handling for your original BLoC
      emit(const AuthStateUnauthenticated()); 
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