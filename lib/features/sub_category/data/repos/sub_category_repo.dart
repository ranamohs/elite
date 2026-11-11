import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../models/sub_category_model.dart';

abstract class SubCategoryRepo {
  Future<Either<Failure, SubCategoryModel>> getSubCategories({
    required int subCategoryId,
    int? page,
  });
}
