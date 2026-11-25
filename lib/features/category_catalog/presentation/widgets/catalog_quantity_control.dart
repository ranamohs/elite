import '../../data/models/cart_change_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';

class CatalogQuantityControl extends StatelessWidget {
  final CartOperation loadingOperation;
  final VoidCallback? onRemove;
  final bool enabled, loading;
  final CatalogItem item;
  final int count;
  final ValueChanged<int> onChanged;
  const CatalogQuantityControl({
    super.key,
    this.onRemove,
    this.loadingOperation = CartOperation.add,
    this.enabled = true,
    this.loading = false,
    required this.item,
    required this.count,
    required this.onChanged,
  });
  Widget roundButton(
      IconData icon,
      VoidCallback? action,
      bool filled, {
        bool busy = false,
      }) => SizedBox(
    width: 28.w,
    height: 28.w,
    child: IconButton(
      onPressed: action,
      padding: EdgeInsets.zero,
      iconSize: 16.sp,
      style: IconButton.styleFrom(
        backgroundColor: filled ? AppColors.primaryColor : AppColors.badgeBg,
        foregroundColor: filled ? Colors.white : AppColors.badgeTextGreen,
      ),
      icon: busy
          ? SizedBox(
        width: 14.w,
        height: 14.w,
        child: CircularProgressIndicator(
          strokeWidth: 1.7,
          color: filled ? Colors.white : AppColors.primaryColor,
        ),
      )
          : Icon(icon),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;

    if (!item.isProduct) {
      return OutlinedButton(
        onPressed: enabled ? () => onChanged(count > 0 ? -1 : 1) : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.badgeTextGreen,
          side: const BorderSide(color: AppColors.primaryColor),
        ),
        child: Text(
          count > 0 ? text('تم الاختيار', 'Selected') : text('إضافة', 'Add'),
          style: TextStyle(fontSize: 11.sp),
        ),
      );
    }
    final available = !item.isProduct || item.stock == null || item.stock! > 0;
    if (count == 0) {
      return OutlinedButton(
        onPressed: enabled && !loading && available ? () => onChanged(1) : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.badgeTextGreen,
          side: const BorderSide(color: AppColors.primaryColor),
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          minimumSize: Size(0, 32.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: SizedBox(
          height: 18.h,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: loading
                  ? SizedBox(
                key: const ValueKey('loading'),
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.primaryColor,
                ),
              )
                  : Text(
                text('إضافة', 'Add'),
                key: const ValueKey('label'),
                style: TextStyle(fontSize: 11.sp),
              ),
            ),
          ),
        ),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        roundButton(
          Icons.add,
          !enabled || loading || (item.stock != null && count >= item.stock!)
              ? null
              : () => onChanged(1),
          true,
          busy: loading && loadingOperation == CartOperation.add,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text('$count'),
        ),
        roundButton(
          Icons.remove,
          !enabled || loading ? null : () => onChanged(-1),
          false,
          busy: loading && loadingOperation == CartOperation.decrease,
        ),
        if (onRemove != null)
          SizedBox(
            width: 28.w,
            height: 28.w,
            child: IconButton(
              onPressed: enabled && !loading ? onRemove : null,
              padding: EdgeInsets.zero,
              tooltip: text('حذف المنتج', 'Remove product'),
              icon: loading && loadingOperation == CartOperation.remove
                  ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.7,
                  color: AppColors.primaryColor,
                ),
              )
                  : Icon(
                Icons.delete_outline,
                size: 18.sp,
                color: AppColors.subtitleGrey,
              ),
            ),
          ),
      ],
    );
  }
}
