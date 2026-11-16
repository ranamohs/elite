import 'dart:convert';
import '../../../../../core/databases/cache/cache_helper.dart';
import '../../../../../core/databases/cache/user_data_manager.dart';
import '../../../../checkout/data/models/order_draft.dart';
import '../../models/saved_address.dart';
import 'account_addresses_repo.dart';

class LocalAccountAddressesRepo implements AccountAddressesRepo {
  final CacheHelper cache;
  final UserDataManager user;
  LocalAccountAddressesRepo({required this.cache, required this.user});
  String get key =>
      'saved_addresses:${user.getUserId() ?? user.getUserEmail() ?? user.getUserPhoneNumber() ?? 'guest'}';
  @override
  Future<List<SavedAddress>> load() async {
    final data = cache.getDataString(key: key);
    if (data == null) return [];
    return (jsonDecode(data) as List)
        .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<SavedAddress>> _write(
      String ownerKey,
      List<SavedAddress> values,
      ) async {
    if (values.isNotEmpty && !values.any((e) => e.isDefault))
      values[0] = values.first.asDefault(true);
    if (!await cache.saveData(
      key: ownerKey,
      value: jsonEncode(values.map((e) => e.toJson()).toList()),
    ))
      throw StateError('Address storage failed');
    return values;
  }

  @override
  Future<List<SavedAddress>> save(OrderAddress address, {String? id}) async {
    final ownerKey = key;
    final values = await load();
    final index = values.indexWhere((e) => e.id == id);
    final value = SavedAddress(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      address: address,
      isDefault: index >= 0 ? values[index].isDefault : values.isEmpty,
    );
    if (index < 0) {
      values.add(value);
    } else {
      values[index] = value;
    }
    return _write(ownerKey, values);
  }

  @override
  Future<List<SavedAddress>> delete(String id) async {
    final ownerKey = key;
    final values = await load();
    values.removeWhere((e) => e.id == id);
    return _write(ownerKey, values);
  }

  @override
  Future<List<SavedAddress>> setDefault(String id) async {
    final ownerKey = key;
    final values = await load();
    return _write(
      ownerKey,
      values.map((e) => e.asDefault(e.id == id)).toList(),
    );
  }
}
