import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/contract_subscription_model.dart';
import '../widgets/subscription_contract_card.dart';
import '../widgets/subscription_dates_card.dart';

class SubscriptionDetailsView extends StatelessWidget {
  final ContractSubscriptionModel subscription;
  const SubscriptionDetailsView({super.key, required this.subscription});
  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    final features = subscription.contract.features
        .map((e) => (ar ? e.ar : e.en).trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return AccountScaffold(
      title: accountText(context, 'عقدي', 'My subscription'),
      body: ListView(
        padding: EdgeInsets.all(18.w),
        children: [
          SubscriptionContractCard(contract: subscription.contract),
          SizedBox(height: 14.h),
          SubscriptionDatesCard(subscription: subscription),
          if (features.isNotEmpty) ...[
            SizedBox(height: 14.h),
            AccountCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    accountText(context, 'مميزات العقد', 'Contract features'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  ...features.map(
                        (value) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: AppColors.badgeTextGreen,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 12.sp, height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
