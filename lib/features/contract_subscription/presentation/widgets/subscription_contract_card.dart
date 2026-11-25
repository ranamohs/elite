import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../../home/data/models/contracts_models/maintenance_contracts_model.dart';
import '../../../home/presentation/widgets/contract_formatters.dart';

class SubscriptionContractCard extends StatelessWidget {
  final MaintenanceContract contract;
  const SubscriptionContractCard({super.key, required this.contract});
  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String local(ContractLocalizedText value) =>
        (ar ? value.ar : value.en).trim().isNotEmpty
            ? (ar ? value.ar : value.en).trim()
            : (ar ? value.en : value.ar).trim();
    return AccountCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppColors.badgeTextGreen,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local(contract.name),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                    if (contract.duration != null)
                      Text(
                        contractDurationText(contract.duration, ar),
                        style: TextStyle(
                          color: AppColors.subtitleGrey,
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (local(contract.description).isNotEmpty)
            Text(
              local(contract.description),
              style: TextStyle(
                color: AppColors.subtitleGrey,
                fontSize: 12.sp,
                height: 1.7,
              ),
            ),
          SizedBox(height: 12.h),
          Text(
            contractPriceText(contract),
            style: TextStyle(
              color: AppColors.badgeTextGreen,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
            ),
          ),
        ],
      ),
    );
  }
}
