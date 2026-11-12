import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/catalog_model.dart';

abstract class CatalogRepo {
  Future<Either<Failure, CatalogPage>> getItems({
    required int categoryId,
    required bool isProduct,
    int page = 1,
  });
}
