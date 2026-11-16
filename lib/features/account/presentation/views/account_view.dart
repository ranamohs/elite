import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/databases/cache/secure_storage_helper.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../orders/presentation/manager/orders_history_cubit.dart';
import '../../../orders/presentation/manager/orders_history_state.dart';
import '../../../settings/views/settings_view.dart';
import '../../data/repos/addresses_repo/account_addresses_repo.dart';
import '../widgets/account_actions.dart';
import '../widgets/account_ui.dart';
import '../widgets/account_header_card.dart';
import '../widgets/account_statistics_row.dart';
import 'account_addresses_view.dart';
import 'account_payment_methods_view.dart';

class AccountView extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onOrders;
  const AccountView({super.key, this.isActive = true, this.onOrders});
  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView>
    with AutomaticKeepAliveClientMixin {
  final user = getIt<UserDataManager>();
  late final OrdersHistoryCubit orders;
  int? addressCount;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    orders = getIt<OrdersHistoryCubit>();
    if (widget.isActive) refresh();
  }

  @override
  void didUpdateWidget(covariant AccountView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) refresh();
  }

  Future<void> refresh() async {
    try {
      final values = await getIt<AccountAddressesRepo>().load();
      if (mounted) setState(() => addressCount = values.length);
    } catch (_) {
      if (mounted) setState(() => addressCount = null);
    }
    try {
      final token = await getIt<SecureStorageHelper>().getToken();
      if (mounted && token?.isNotEmpty == true) await orders.load();
    } catch (_) {
      // Account information remains usable when the order count is unavailable.
    }
  }

  @override
  void dispose() {
    orders.close();
    super.dispose();
  }

  Future<void> edit() async {
    await context.push(AppRouter.updateProfileView);
    if (mounted) setState(() {});
  }

  Future<void> addresses() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AccountAddressesView()));
    if (mounted) refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final entries = <Widget>[
      AccountMenuTile(
        icon: Icons.person_outline,
        title: accountText(context, 'البيانات الشخصية', 'Personal information'),
        onTap: edit,
      ),
      AccountMenuTile(
        icon: Icons.location_on_outlined,
        title: accountText(context, 'عناويني', 'My addresses'),
        onTap: addresses,
      ),
      // AccountMenuTile(
      //   icon: Icons.credit_card_outlined,
      //   title: accountText(context, 'طرق الدفع', 'Payment methods'),
      //   onTap: () => Navigator.of(context).push(
      //     MaterialPageRoute(builder: (_) => const AccountPaymentMethodsView()),
      //   ),
      // ),
      AccountMenuTile(
        icon: Icons.settings_outlined,
        title: accountText(
          context,
          'الإعدادات واللغة',
          'Settings and language',
        ),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const SettingsView())),
      ),
      // AccountMenuTile(
      //   icon: Icons.help_outline,
      //   title: accountText(context, 'الدعم والمساعدة', 'Help and support'),
      //   onTap: () => context.push(AppRouter.helpAndSupportView),
      // ),
      AccountMenuTile(
        icon: Icons.description_outlined,
        title: accountText(context, 'الشروط والأحكام', 'Terms and conditions'),
        onTap: () => context.push(AppRouter.termsAndConditionsView),
      ),
    ];
    return AccountScaffold(
      title: accountText(context, 'حسابي', 'My account'),
      embedded: true,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h),
          children: [
            AccountHeaderCard(user: user, onEdit: edit),
            SizedBox(height: 10.h),
            BlocBuilder<OrdersHistoryCubit, OrdersHistoryState>(
              bloc: orders,
              builder: (context, state) {
                final model = switch (state) {
                  OrdersHistorySuccess() => state.model,
                  OrdersHistoryLoadingMore() => state.model,
                  OrdersHistoryFailure() => state.model,
                  _ => null,
                };
                return AccountStatisticsRow(
                  orders:
                  model?.total ??
                      (model?.lastPage == 1 ? model?.orders.length : null),
                  addresses: addressCount,
                  onOrders:
                  widget.onOrders ?? () => context.push(AppRouter.homePage),
                  onAddresses: addresses,
                );
              },
            ),
            SizedBox(height: 10.h),
            AccountCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    entries[i],
                    if (i < entries.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 10.h),
            AccountCard(
              padding: EdgeInsets.zero,
              child: AccountMenuTile(
                icon: Icons.logout_rounded,
                title: accountText(context, 'تسجيل الخروج', 'Sign out'),
                destructive: true,
                onTap: () => showAccountLogout(context),
                trailing: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
