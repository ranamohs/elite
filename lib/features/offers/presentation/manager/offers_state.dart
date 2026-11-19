import 'package:equatable/equatable.dart';

import '../../../../../core/errors/failure.dart';
import '../../data/models/offers_model.dart';

abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object?> get props => [];
}

class OffersInitial extends OffersState {
  const OffersInitial();
}

class OffersLoading extends OffersState {
  const OffersLoading();
}

class OffersSuccess extends OffersState {
  final OffersModel offersModel;

  const OffersSuccess({required this.offersModel});

  @override
  List<Object?> get props => [offersModel];
}

class OffersFailure extends OffersState {
  final Failure failure;

  const OffersFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
