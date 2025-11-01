part of 'driver_bloc.dart';
// <-- DO NOT ADD ANY IMPORTS HERE

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object> get props => [];
}

class DriverInitial extends DriverState {}

class DriverSubmitting extends DriverState {}

class DriverSubmitSuccess extends DriverState {
  final String message;
  const DriverSubmitSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class DriverSubmitError extends DriverState {
  final String error;
  const DriverSubmitError({required this.error});

  @override
  List<Object> get props => [error];
}

