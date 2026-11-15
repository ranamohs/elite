import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';

class CatalogBottomBar extends StatelessWidget {
  final String totalLabel;
  final VoidCallback? onContinue;
  const CatalogBottomBar({
    super.key,
    required this.totalLabel,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.unselectedBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text('الإجمالي', 'Total'),
                    style: TextStyle(
                      color: AppColors.subtitleGrey,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(140.w, 54.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(text('متابعة', 'Continue')),
            ),
          ],
        ),
      ),
    );
  }
}
