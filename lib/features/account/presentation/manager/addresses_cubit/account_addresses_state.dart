import 'package:equatable/equatable.dart';
import '../../../data/models/saved_address.dart';

abstract class AccountAddressesState extends Equatable {
  const AccountAddressesState();
  @override
  List<Object?> get props => [];
}

class AccountAddressesInitial extends AccountAddressesState {}

class AccountAddressesLoading extends AccountAddressesState {}

class AccountAddressesSuccess extends AccountAddressesState {
  final List<SavedAddress> addresses;
  const AccountAddressesSuccess(this.addresses);
  @override
  List<Object?> get props => [addresses];
}

class AccountAddressesFailure extends AccountAddressesState {}
