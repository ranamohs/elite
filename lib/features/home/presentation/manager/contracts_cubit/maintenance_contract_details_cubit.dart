import 'package:dartz/dartz.dart';
import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contract_details_model.dart';
import 'package:elite/features/home/data/repos/contracts_repo/maintenance_contracts_repo.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contract_details_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceContractDetailsCubit
    extends Cubit<MaintenanceContractDetailsState> {
  final MaintenanceContractsRepo maintenanceContractsRepo;

  MaintenanceContractDetailsCubit({required this.maintenanceContractsRepo})
      : super(const MaintenanceContractDetailsInitial());

  Future<void> getMaintenanceContractDetails(int id) async {
    emit(const MaintenanceContractDetailsLoading());

    final Either<Failure, MaintenanceContractDetailsModel> result =
    await maintenanceContractsRepo.getMaintenanceContractDetails(id);

    if (isClosed) return;

    result.fold(
          (failure) => emit(MaintenanceContractDetailsFailure(failure)),
          (model) => emit(MaintenanceContractDetailsSuccess(model)),
    );
  }
}
