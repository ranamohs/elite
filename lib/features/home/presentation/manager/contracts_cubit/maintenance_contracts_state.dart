import 'package:equatable/equatable.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';

abstract class MaintenanceContractsState extends Equatable {
  const MaintenanceContractsState();

  @override
  List<Object?> get props => [];
}

class MaintenanceContractsInitial extends MaintenanceContractsState {
  const MaintenanceContractsInitial();
}

class MaintenanceContractsLoading extends MaintenanceContractsState {
  const MaintenanceContractsLoading();
}

class MaintenanceContractsSuccess extends MaintenanceContractsState {
  final MaintenanceContractsModel contractsModel;

  const MaintenanceContractsSuccess(this.contractsModel);

  @override
  List<Object?> get props => [contractsModel];
}

class MaintenanceContractsFailure extends MaintenanceContractsState {
  final Failure failure;

  const MaintenanceContractsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
