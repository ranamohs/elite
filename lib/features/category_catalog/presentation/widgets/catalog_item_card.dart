import '../../data/models/cart_change_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';
import 'catalog_item_image.dart';
import 'catalog_quantity_control.dart';

class CatalogItemCard extends StatelessWidget {
  final CartOperation loadingOperation;
  final VoidCallback? onRemove;
  final bool enabled, loading;
  final CatalogItem item;
  final int count;
  final ValueChanged<int> onChanged;
  const CatalogItemCard({
    super.key,
    this.onRemove,
    this.loadingOperation = CartOperation.add,
    this.enabled = true,
    this.loading = false,
    required this.item,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);

    final product = item.isProduct;
    final available = !product || item.stock == null || item.stock! > 0;
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.title(ar),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5.h),
        Text(
          item.details(ar),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.sp, color: AppColors.subtitleGrey),
        ),
        SizedBox(height: 6.h),
        Text(
          item.priceLabel,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.badgeTextGreen,
          ),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: count > 0
              ? AppColors.primaryColor
              : AppColors.unselectedBorder,
        ),
      ),
      child: product
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CatalogItemImage(item: item, size: double.infinity),
                if (!available)
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      AppStrings.outOfStock.tr(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          info,
          SizedBox(height: 6.h),
          CatalogQuantityControl(
            item: item,
            loadingOperation: loadingOperation,
            onRemove: onRemove,
            enabled: enabled,
            loading: loading,
            count: count,
            onChanged: onChanged,
          ),
        ],
      )
          : Row(
        children: [
          CatalogItemImage(item: item, size: 52.w),
          SizedBox(width: 10.w),
          Expanded(child: info),
          SizedBox(width: 6.w),
          CatalogQuantityControl(
            item: item,
            loadingOperation: loadingOperation,
            onRemove: onRemove,
            enabled: enabled,
            loading: loading,
            count: count,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
