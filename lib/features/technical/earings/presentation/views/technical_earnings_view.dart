import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../account/presentation/widgets/account_ui.dart';

class TechnicalEarningsView extends StatelessWidget {
  const TechnicalEarningsView({super.key});
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'الأرباح', 'Earnings'),
    embedded: true,
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 54.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16.h),
            Text(
              accountText(
                context,
                'بيانات الأرباح غير متاحة حاليًا',
                'Earnings data is currently unavailable',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
