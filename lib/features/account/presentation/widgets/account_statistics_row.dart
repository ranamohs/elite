import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import 'account_ui.dart';

class AccountStatisticsRow extends StatelessWidget {
  final int? orders, addresses;
  final VoidCallback onOrders, onAddresses;
  const AccountStatisticsRow({
    super.key,
    this.orders,
    this.addresses,
    required this.onOrders,
    required this.onAddresses,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: tile(
          orders?.toString() ?? '—',
          accountText(context, 'طلب', 'Orders'),
          onOrders,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: tile(
          addresses?.toString() ?? '—',
          accountText(context, 'عنوان', 'Addresses'),
          onAddresses,
        ),
      ),
      SizedBox(width: 8.w),
      Expanded(child: tile('—', accountText(context, 'رصيد', 'Balance'), null)),
    ],
  );
  Widget tile(String value, String title, VoidCallback? action) => InkWell(
    onTap: action,
    child: AccountCard(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: TextStyle(color: AppColors.subtitleGrey, fontSize: 10.sp),
          ),
        ],
      ),
    ),
  );
}
