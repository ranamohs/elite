import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'package:elite/features/home/data/repos/contracts_repo/maintenance_contracts_repo.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contracts_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MaintenanceContractsCubit extends Cubit<MaintenanceContractsState> {
  final MaintenanceContractsRepo maintenanceContractsRepo;

  MaintenanceContractsCubit({required this.maintenanceContractsRepo})
      : super(const MaintenanceContractsInitial());

  Future<void> getMaintenanceContracts() async {
    emit(const MaintenanceContractsLoading());

    final Either<Failure, MaintenanceContractsModel> result =
    await maintenanceContractsRepo.getMaintenanceContracts();

    result.fold(
          (failure) => emit(MaintenanceContractsFailure(failure)),
          (model) => emit(MaintenanceContractsSuccess(model)),
    );
  }

  Future<void> refreshMaintenanceContracts() async {
    await getMaintenanceContracts();
  }
}
