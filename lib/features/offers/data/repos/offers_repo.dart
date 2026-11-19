import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../models/offers_model.dart';

abstract class OffersRepo {
  Future<Either<Failure, OffersModel>> getOffers();
}
