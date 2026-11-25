import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../checkout/data/models/order_draft.dart';
import '../../../checkout/presentation/widgets/order_address_view.dart';
import '../../data/models/saved_address.dart';
import '../manager/addresses_cubit/account_addresses_cubit.dart';
import '../manager/addresses_cubit/account_addresses_state.dart';
import '../widgets/account_ui.dart';

class AccountAddressesView extends StatefulWidget {
  const AccountAddressesView({super.key});
  @override
  State<AccountAddressesView> createState() => _AccountAddressesViewState();
}

class _AccountAddressesViewState extends State<AccountAddressesView> {
  late final AccountAddressesCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = getIt<AccountAddressesCubit>()..load();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> edit([SavedAddress? value]) async {
    final result = await Navigator.of(context).push<OrderAddress>(
      MaterialPageRoute(
        builder: (_) => OrderAddressView(initial: value?.address),
      ),
    );
    if (mounted && result != null) cubit.save(result, id: value?.id);
  }

  Future<void> remove(SavedAddress value) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accountText(context, 'حذف العنوان؟', 'Delete address?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(accountText(context, 'إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(accountText(context, 'حذف', 'Delete')),
          ),
        ],
      ),
    );
    if (mounted && confirmed == true) cubit.delete(value.id);
  }

  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'عناويني', 'My addresses'),
    body: BlocBuilder<AccountAddressesCubit, AccountAddressesState>(
      bloc: cubit,
      builder: (context, state) {
        if (state is AccountAddressesInitial ||
            state is AccountAddressesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AccountAddressesFailure) {
          return Center(
            child: TextButton(
              onPressed: cubit.load,
              child: Text(
                accountText(
                  context,
                  'تعذر تحميل العناوين، إعادة المحاولة',
                  'Could not load addresses. Retry',
                ),
              ),
            ),
          );
        }
        final values = (state as AccountAddressesSuccess).addresses;
        return ListView(
          padding: EdgeInsets.all(18.w),
          children: [
            Text(
              accountText(
                context,
                'العناوين المحفوظة على هذا الجهاز',
                'Addresses saved on this device',
              ),
              style: TextStyle(fontSize: 11.sp, color: AppColors.subtitleGrey),
            ),
            SizedBox(height: 12.h),
            if (values.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30.h),
                child: Text(
                  accountText(
                    context,
                    'لسه مفيش عناوين محفوظة',
                    'No saved addresses yet',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ...values.map(
                  (value) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: AccountCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: AppColors.badgeTextGreen,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              value.address.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (value.isDefault)
                            Text(
                              accountText(
                                context,
                                'العنوان الافتراضي',
                                'Default address',
                              ),
                              style: TextStyle(
                                color: AppColors.badgeTextGreen,
                                fontSize: 10.sp,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        value.address.details,
                        style: TextStyle(
                          color: AppColors.subtitleGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => edit(value),
                            child: Text(accountText(context, 'تعديل', 'Edit')),
                          ),
                          if (!value.isDefault)
                            TextButton(
                              onPressed: () => cubit.setDefault(value.id),
                              child: Text(
                                accountText(
                                  context,
                                  'اجعله افتراضي',
                                  'Set default',
                                ),
                              ),
                            ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => remove(value),
                            child: Text(
                              accountText(context, 'حذف', 'Delete'),
                              style: const TextStyle(color: Colors.deepOrange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: edit,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.badgeTextGreen,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                accountText(context, '+ إضافة عنوان جديد', '+ Add new address'),
              ),
            ),
          ],
        );
      },
    ),
  );
}
