import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class SchedulePickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const SchedulePickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.badgeBg : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.r),
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.unselectedBorder,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 18.h),
        child: Row(
          children: [
            Icon(icon, size: 21.sp, color: AppColors.primaryColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected
                      ? AppColors.titleDark
                      : AppColors.subtitleGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
