import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../account/presentation/widgets/account_ui.dart';

class SubscriptionStepIndicator extends StatelessWidget {
  final int step;
  const SubscriptionStepIndicator({super.key, required this.step});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        accountText(context, 'الخطوة $step من 2', 'Step $step of 2'),
        style: TextStyle(color: AppColors.badgeTextGreen, fontSize: 11.sp),
      ),
      SizedBox(height: 8.h),
      Row(
        children: List.generate(
          2,
              (index) => Expanded(
            child: Container(
              height: 4.h,
              margin: EdgeInsetsDirectional.only(end: index == 0 ? 6.w : 0),
              decoration: BoxDecoration(
                color: index < step
                    ? AppColors.primaryColor
                    : AppColors.unselectedBorder,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}