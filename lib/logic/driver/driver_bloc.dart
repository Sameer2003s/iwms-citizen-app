import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // <-- FIX: Add this import
import 'package:image_picker/image_picker.dart';
import 'package:iwms_citizen_app/data/repositories/driver_repository.dart';

part 'driver_event.dart';
part 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRepository _driverRepository;

  DriverBloc({required DriverRepository driverRepository})
      : _driverRepository = driverRepository,
        super(DriverInitial()) {
    on<DriverDataSubmitted>(_onDataSubmitted);
  }

  Future<void> _onDataSubmitted(
    DriverDataSubmitted event,
    Emitter<DriverState> emit,
  ) async {
    emit(DriverSubmitting());
    try {
      final result = await _driverRepository.submitWasteData(
        qrData: event.qrData,
        lat: event.lat,
        long: event.long,
        uniqueId: event.uniqueId,
        staffId: event.staffId,
        imageFile: event.imageFile,
        weight: event.weight,
      );

      if (result['status'] == 1) {
        emit(DriverSubmitSuccess(
            message: result['msg'] ?? 'Data submitted successfully'));
      } else {
        emit(DriverSubmitError(error: result['error'] ?? 'Unknown error'));
      }
    } catch (e) {
      emit(DriverSubmitError(error: e.toString()));
    }
  }
}

