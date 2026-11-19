import 'package:equatable/equatable.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contract_details_model.dart';

abstract class MaintenanceContractDetailsState extends Equatable {
  const MaintenanceContractDetailsState();

  @override
  List<Object?> get props => [];
}

class MaintenanceContractDetailsInitial extends MaintenanceContractDetailsState {
  const MaintenanceContractDetailsInitial();
}

class MaintenanceContractDetailsLoading extends MaintenanceContractDetailsState {
  const MaintenanceContractDetailsLoading();
}

class MaintenanceContractDetailsSuccess extends MaintenanceContractDetailsState {
  final MaintenanceContractDetailsModel detailsModel;

  const MaintenanceContractDetailsSuccess(this.detailsModel);

  @override
  List<Object?> get props => [detailsModel];
}

class MaintenanceContractDetailsFailure extends MaintenanceContractDetailsState {
  final Failure failure;

  const MaintenanceContractDetailsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
