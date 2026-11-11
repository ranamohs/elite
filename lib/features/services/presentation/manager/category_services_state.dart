import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/category_services_model.dart';

abstract class CategoryServicesState extends Equatable {
  const CategoryServicesState();

  @override
  List<Object?> get props => [];
}

class CategoryServicesInitial extends CategoryServicesState {
  const CategoryServicesInitial();
}

class CategoryServicesLoading extends CategoryServicesState {
  const CategoryServicesLoading();
}

class CategoryServicesSuccess extends CategoryServicesState {
  final CategoryServicesModel servicesModel;
  final int currentPage;
  final int lastPage;

  const CategoryServicesSuccess({
    required this.servicesModel,
    required this.currentPage,
    required this.lastPage,
  });

  @override
  List<Object?> get props => [servicesModel, currentPage, lastPage];
}

class CategoryServicesLoadingMore extends CategoryServicesState {
  final CategoryServicesModel servicesModel;
  final int currentPage;
  final int lastPage;

  const CategoryServicesLoadingMore({
    required this.servicesModel,
    required this.currentPage,
    required this.lastPage,
  });

  @override
  List<Object?> get props => [servicesModel, currentPage, lastPage];
}

class CategoryServicesFailure extends CategoryServicesState {
  final Failure failure;

  const CategoryServicesFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
