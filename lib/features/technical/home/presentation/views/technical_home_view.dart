import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_styles.dart';
import '../../../../../core/functions/is_arabic.dart';
import '../../../../../core/databases/cache/user_data_manager.dart';
import '../../../../../core/services/service_locator.dart';
import '../../../../account/presentation/views/account_view.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../../earings/presentation/views/technical_earnings_view.dart';
import '../../../requests/presentation/manager/assigned_requests/assigned_requests_cubit.dart';
import '../../../requests/presentation/manager/assigned_requests/assigned_requests_state.dart';
import '../../../requests/presentation/widgets/assigned_requests_content.dart';
import '../../../requests/presentation/views/technical_requests_view.dart';
import '../widgets/technical_home_header.dart';

class TechnicalHomeView extends StatefulWidget {
  const TechnicalHomeView({super.key});
  @override
  State<TechnicalHomeView> createState() => _TechnicalHomeViewState();
}

class _TechnicalHomeViewState extends State<TechnicalHomeView> {
  late final AssignedRequestsCubit cubit;
  int selected = 0;
  @override
  void initState() {
    super.initState();
    cubit = getIt<AssignedRequestsCubit>()..load();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
    child: Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: AppStyles.styleMedium16(context).fontFamily,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(
          child: IndexedStack(
            index: selected,
            children: [
              Column(
                children: [
                  BlocBuilder<AssignedRequestsCubit, AssignedRequestsState>(
                    bloc: cubit,
                    builder: (context, state) => TechnicalHomeHeader(
                      user: getIt<UserDataManager>(),
                      stats: assignedRequestsData(state)?.stats,
                      onProfile: () => setState(() => selected = 3),
                    ),
                  ),
                  Expanded(
                    child: AssignedRequestsContent(cubit: cubit, home: true),
                  ),
                ],
              ),
              TechnicalRequestsView(cubit: cubit, isActive: selected == 1),
              const TechnicalEarningsView(),
              AccountView(
                isActive: selected == 3,
                assignedRequests: cubit,
                onOrders: () => setState(() => selected = 1),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selected,
          onTap: (value) => setState(() => selected = value),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.subtitleGrey,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: accountText(context, 'الرئيسية', 'Home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment_rounded),
              label: accountText(context, 'طلباتي', 'My requests'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: accountText(context, 'الأرباح', 'Earnings'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              label: accountText(context, 'حسابي', 'My account'),
            ),
          ],
        ),
      ),
    ),
  );
}
