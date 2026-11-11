import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/sub_category_model.dart';

abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategorySuccess extends SubCategoryState {
  final SubCategoryModel subCategoryModel;
  final int currentPage;
  final int lastPage;

  const SubCategorySuccess({
    required this.subCategoryModel,
    required this.currentPage,
    required this.lastPage,
  });

  @override
  List<Object?> get props => [subCategoryModel, currentPage, lastPage];
}

class SubCategoryLoadingMore extends SubCategoryState {
  final SubCategoryModel subCategoryModel;
  final int currentPage;
  final int lastPage;

  const SubCategoryLoadingMore({
    required this.subCategoryModel,
    required this.currentPage,
    required this.lastPage,
  });

  @override
  List<Object?> get props => [subCategoryModel, currentPage, lastPage];
}

class SubCategoryFailure extends SubCategoryState {
  final Failure failure;

  const SubCategoryFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
