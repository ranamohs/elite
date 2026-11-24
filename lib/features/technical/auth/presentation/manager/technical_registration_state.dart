import 'package:equatable/equatable.dart';
import '../../../auth/data/models/technical_registration_model.dart';
import '../../../auth/data/models/technical_registration_failure.dart';

abstract class TechnicalRegistrationState extends Equatable {
  const TechnicalRegistrationState();
  @override
  List<Object?> get props => [];
}

class TechnicalRegistrationInitial extends TechnicalRegistrationState {}

class TechnicalRegistrationLoading extends TechnicalRegistrationState {}

class TechnicalRegistrationSuccess extends TechnicalRegistrationState {
  final TechnicalRegistrationModel result;
  const TechnicalRegistrationSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class TechnicalRegistrationFailed extends TechnicalRegistrationState {
  final TechnicalRegistrationFailure failure;
  const TechnicalRegistrationFailed(this.failure);
  @override
  List<Object?> get props => [failure];
}
