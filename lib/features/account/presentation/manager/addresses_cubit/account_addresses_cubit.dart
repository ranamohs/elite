import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../checkout/data/models/order_draft.dart';
import '../../../data/models/saved_address.dart';
import '../../../data/repos/addresses_repo/account_addresses_repo.dart';
import 'account_addresses_state.dart';

class AccountAddressesCubit extends Cubit<AccountAddressesState> {
  final AccountAddressesRepo repo;
  AccountAddressesCubit({required this.repo})
      : super(AccountAddressesInitial());
  Future<void> _run(Future<List<SavedAddress>> Function() action) async {
    if (state is AccountAddressesLoading) return;
    emit(AccountAddressesLoading());
    try {
      final values = await action();
      if (!isClosed) emit(AccountAddressesSuccess(values));
    } catch (_) {
      if (!isClosed) emit(AccountAddressesFailure());
    }
  }

  Future<void> load() => _run(repo.load);
  Future<void> save(OrderAddress address, {String? id}) =>
      _run(() => repo.save(address, id: id));
  Future<void> delete(String id) => _run(() => repo.delete(id));
  Future<void> setDefault(String id) => _run(() => repo.setDefault(id));
}
