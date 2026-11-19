import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class OffersTabs extends StatelessWidget {
  final bool showServices;
  final int productsCount;
  final int servicesCount;
  final ValueChanged<bool> onChanged;

  const OffersTabs({
    super.key,
    required this.showServices,
    required this.productsCount,
    required this.servicesCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _tab(
            context,
            '${AppStrings.products.tr()} ($productsCount)',
            !showServices,
                () => onChanged(false),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _tab(
            context,
            '${AppStrings.services.tr()} ($servicesCount)',
            showServices,
                () => onChanged(true),
          ),
        ),
      ],
    );
  }

  Widget _tab(
      BuildContext context,
      String title,
      bool selected,
      VoidCallback onTap,
      ) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.primaryColor : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.titleDark,
        minimumSize: Size(0, 42.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        side: BorderSide(
          color: selected ? AppColors.primaryColor : AppColors.unselectedBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(title, style: TextStyle(fontSize: 12.sp)),
    );
  }
}
