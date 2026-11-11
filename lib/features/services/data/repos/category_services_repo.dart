import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/category_services_model.dart';

abstract class CategoryServicesRepo {
  Future<Either<Failure, CategoryServicesModel>> getCategoryServices({
    required int categoryId,
    int? page,
  });
}
