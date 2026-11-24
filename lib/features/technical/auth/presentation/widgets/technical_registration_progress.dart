import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../account/presentation/widgets/account_ui.dart';


class TechnicalRegistrationProgress extends StatelessWidget {
  final int step;
  const TechnicalRegistrationProgress({super.key, required this.step});
  @override
  Widget build(BuildContext context) {
    final labels = [
      accountText(context, 'البيانات الشخصية', 'Personal information'),
      accountText(context, 'التخصص ومناطق الشغل', 'Specialties and work areas'),
      accountText(context, 'المستندات', 'Documents'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          accountText(
            context,
            'الخطوة ${step + 1} من 3: ${labels[step]}',
            'Step ${step + 1} of 3: ${labels[step]}',
          ),
          style: TextStyle(fontSize: 12.sp, color: AppColors.badgeTextGreen),
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(
            3,
                (i) => Expanded(
              child: Container(
                height: 4.h,
                margin: EdgeInsetsDirectional.only(end: i < 2 ? 6.w : 0),
                decoration: BoxDecoration(
                  color: i <= step
                      ? AppColors.primaryColor
                      : AppColors.unselectedBorder,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
