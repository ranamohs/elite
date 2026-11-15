import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';

class CatalogQuantityControl extends StatelessWidget {
  final CatalogItem item;
  final int count;
  final ValueChanged<int> onChanged;
  const CatalogQuantityControl({
    super.key,
    required this.item,
    required this.count,
    required this.onChanged,
  });
  Widget roundButton(IconData icon, VoidCallback? action, bool filled) =>
      SizedBox(
        width: 28.w,
        height: 28.w,
        child: IconButton(
          onPressed: action,
          padding: EdgeInsets.zero,
          iconSize: 16.sp,
          style: IconButton.styleFrom(
            backgroundColor: filled
                ? AppColors.primaryColor
                : AppColors.badgeBg,
            foregroundColor: filled ? Colors.white : AppColors.badgeTextGreen,
          ),
          icon: Icon(icon),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;

    final available = !item.isProduct || item.stock == null || item.stock! > 0;
    if (count == 0)
      return OutlinedButton(
        onPressed: available ? () => onChanged(1) : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.badgeTextGreen,
          side: const BorderSide(color: AppColors.primaryColor),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          minimumSize: Size(0, 32.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
         text('إضافة', 'Add'),
          style: TextStyle(fontSize: 11.sp),
        ),
      );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        roundButton(
          Icons.add,
          item.isProduct && item.stock != null && count >= item.stock!
              ? null
              : () => onChanged(1),
          true,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text('$count'),
        ),
        roundButton(Icons.remove, () => onChanged(-1), false),
      ],
    );
  }
}
