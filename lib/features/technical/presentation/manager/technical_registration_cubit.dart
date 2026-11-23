import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/technical_registration_repo.dart';
import '../../data/models/technical_registration_request.dart';
import 'technical_registration_state.dart';

class TechnicalRegistrationCubit extends Cubit<TechnicalRegistrationState> {
  final TechnicalRegistrationRepo repo;
  TechnicalRegistrationCubit({required this.repo})
      : super(TechnicalRegistrationInitial());
  Future<void> register(TechnicalRegistrationRequest request) async {
    if (state is TechnicalRegistrationLoading ||
        state is TechnicalRegistrationSuccess)
      return;
    emit(TechnicalRegistrationLoading());
    final result = await repo.register(request);
    if (isClosed) return;
    result.fold(
          (failure) => emit(TechnicalRegistrationFailed(failure)),
          (value) => emit(TechnicalRegistrationSuccess(value)),
    );
  }
}
