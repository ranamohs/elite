import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';

class SettingsLanguageTile extends StatelessWidget {
  final String title, subtitle, symbol;
  final bool selected, loading;
  final VoidCallback? onTap;
  const SettingsLanguageTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.symbol,
    required this.selected,
    required this.onTap,
    this.loading = false,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.unselectedBorder,
        width: selected ? 1.5 : 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.badgeBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                symbol,
                style: TextStyle(
                  color: AppColors.badgeTextGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.subtitleGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (loading)
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              )
            else
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                color: selected
                    ? AppColors.primaryColor
                    : AppColors.unselectedRadioBorder,
                size: 23.sp,
              ),
          ],
        ),
      ),
    ),
  );
}
