import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failure.dart';
import '../../data/models/offers_model.dart';
import '../../data/repos/offers_repo.dart';
import 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  final OffersRepo offersRepo;

  OffersCubit({required this.offersRepo}) : super(const OffersInitial());

  Future<void> getOffers() async {
    emit(const OffersLoading());

    final Either<Failure, OffersModel> result = await offersRepo.getOffers();

    result.fold(
          (failure) => emit(OffersFailure(failure)),
          (offersModel) => emit(OffersSuccess(offersModel: offersModel)),
    );
  }

  void refreshOffers() => getOffers();
}
