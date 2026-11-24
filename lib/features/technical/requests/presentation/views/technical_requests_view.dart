import 'package:flutter/material.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../manager/assigned_requests_cubit.dart';
import '../widgets/assigned_requests_content.dart';

class TechnicalRequestsView extends StatelessWidget {
  final AssignedRequestsCubit cubit;
  const TechnicalRequestsView({super.key, required this.cubit});
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'طلباتي', 'My requests'),
    embedded: true,
    body: AssignedRequestsContent(cubit: cubit),
  );
}
