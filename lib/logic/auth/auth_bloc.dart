import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

// New layered imports
import '../../data/repositories/auth_repository.dart'; 
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  // A Future that must complete before any event handlers are executed
  // CRITICAL: Made public (removed underscore) for SplashScreen to access for timing
  final Future<void> initialization; 

  AuthBloc({required AuthRepository authRepository}) 
      : _authRepository = authRepository, 
        // 1. Start the async initialization immediately (non-blocking)
        initialization = authRepository.initialize(), 
        super(const AuthStateInitial()) {
    
    on<AuthStatusChecked>(_onStatusChecked);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    
    // 2. The initial dispatch is handled by SplashScreen, which awaits 'initialization'.
    // We only dispatch the event here once the future resolves, as a fallback/guarantee.
    initialization.then((_) {
      add(AuthStatusChecked()); 
    });
  }
  
  void _onStatusChecked(
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

  void _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthStateInitial());

    try {
      final user = await _authRepository.login(
        mobileNumber: event.mobileNumber, 
        otp: event.otp,
      );
      
      if (user.role == 'citizen') {
        emit(AuthStateAuthenticatedCitizen(userName: user.userName));
      } else {
        await _authRepository.logout();
        emit(const AuthStateUnauthenticated());
      }

    } catch (e) {
      emit(const AuthStateUnauthenticated()); 
    }
  }

  void _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout(); 
    emit(const AuthStateUnauthenticated());
  }
}
