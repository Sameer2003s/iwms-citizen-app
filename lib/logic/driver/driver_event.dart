part of 'driver_bloc.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class DriverDataSubmitted extends DriverEvent {
  final String qrData;
  final String lat;
  final String long;
  final String uniqueId;
  final String staffId;
  final XFile? imageFile;
  final String? weight; // Optional weight

  const DriverDataSubmitted({
    required this.qrData,
    required this.lat,
    required this.long,
    required this.uniqueId,
    required this.staffId,
    this.imageFile,
    this.weight,
  });

  @override
  List<Object?> get props => [qrData, lat, long, uniqueId, staffId, imageFile, weight];
}
