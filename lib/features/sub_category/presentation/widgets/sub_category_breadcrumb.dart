import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubCategoryBreadcrumb extends StatelessWidget {
  final bool isArabic;
  final String mainCategoryName;
  final String subCategoryName;
  final VoidCallback? onHomeTap;
  final VoidCallback? onMainCategoryTap;

  const SubCategoryBreadcrumb({
    super.key,
    required this.isArabic,
    required this.mainCategoryName,
    required this.subCategoryName,
    this.onHomeTap,
    this.onMainCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // In RTL: الرئيسية < سباكة < سخانات كهرباء
    final homeText = isArabic ? 'الرئيسية' : 'Home';
    final separator = Icon(
      isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      size: 16.sp,
      color: const Color(0xFF94A3B8),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onHomeTap,
            child: Text(
              homeText,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          separator,
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onMainCategoryTap,
            child: Text(
              mainCategoryName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          separator,
          SizedBox(width: 4.w),
          Text(
            subCategoryName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF558B2F),
            ),
          ),
        ],
      ),
    );
  }
}
