import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/catalog_model.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogSuccess extends CatalogState {
  final CatalogPage catalogPage;
  const CatalogSuccess({required this.catalogPage});
  @override
  List<Object?> get props => [catalogPage];
}

class CatalogLoadingMore extends CatalogState {
  final CatalogPage catalogPage;
  const CatalogLoadingMore({required this.catalogPage});
  @override
  List<Object?> get props => [catalogPage];
}

class CatalogFailure extends CatalogState {
  final Failure failure;
  final CatalogPage? catalogPage;
  const CatalogFailure(this.failure, {this.catalogPage});
  @override
  List<Object?> get props => [failure, catalogPage];
}
