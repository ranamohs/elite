import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../manager/logout_cubit/logout_cubit.dart';
import '../manager/delete_account_cubit/delete_account_cubit.dart';
import 'logout_dialog.dart';
import 'delete_account_dialog.dart';

Future<void> showAccountLogout(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => BlocProvider(
    create: (_) => getIt<LogoutCubit>(),
    child: const LogoutDialog(),
  ),
);
Future<void> showAccountDeletion(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => BlocProvider(
    create: (_) => getIt<DeleteAccountCubit>(),
    child: DeleteAccountDialog(),
  ),
);
