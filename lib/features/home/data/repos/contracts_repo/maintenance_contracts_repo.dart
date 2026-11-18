import 'package:elite/core/errors/failure.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'package:dartz/dartz.dart';

abstract class MaintenanceContractsRepo {
  Future<Either<Failure, MaintenanceContractsModel>> getMaintenanceContracts();
}
