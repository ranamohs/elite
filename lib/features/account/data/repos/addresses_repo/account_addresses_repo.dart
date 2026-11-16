import '../../models/saved_address.dart';
import '../../../../checkout/data/models/order_draft.dart';

abstract class AccountAddressesRepo {
  Future<List<SavedAddress>> load();
  Future<List<SavedAddress>> save(OrderAddress address, {String? id});
  Future<List<SavedAddress>> delete(String id);
  Future<List<SavedAddress>> setDefault(String id);
}
