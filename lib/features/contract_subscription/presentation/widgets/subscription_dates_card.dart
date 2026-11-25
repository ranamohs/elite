import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/contract_subscription_model.dart';

class SubscriptionDatesCard extends StatelessWidget {
  final ContractSubscriptionModel subscription;
  const SubscriptionDatesCard({super.key, required this.subscription});
  @override
  Widget build(BuildContext context) {
    String date(DateTime value) => DateFormat(
      'd MMMM yyyy',
      isArabic(context) ? 'ar' : 'en',
    ).format(value.toLocal());
    return AccountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            accountText(
              context,
              'اشتراك #${subscription.id}',
              'Subscription #${subscription.id}',
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          if (subscription.status.isNotEmpty)
            row(
              accountText(context, 'الحالة', 'Status'),
              subscription.status == 'active'
                  ? accountText(context, 'ساري', 'Active')
                  : subscription.status,
            ),
          if (subscription.startDate != null)
            row(
              accountText(context, 'تاريخ البداية', 'Start date'),
              date(subscription.startDate!),
            ),
          if (subscription.endDate != null)
            row(
              accountText(context, 'تاريخ الانتهاء', 'End date'),
              date(subscription.endDate!),
            ),
        ],
      ),
    );
  }

  Widget row(String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.subtitleGrey),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.badgeTextGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
