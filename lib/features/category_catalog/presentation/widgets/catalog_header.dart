import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../manager/catalog_cubit.dart';
import 'catalog_tab.dart';

class CatalogHeader extends StatelessWidget {
  final String arName, enName;
  final String? mainArName, mainEnName, parentArName, parentEnName;
  final CatalogCubit services, products;
  final bool showProducts;
  final ValueChanged<bool> onTabChanged;
  const CatalogHeader({
    super.key,
    required this.arName,
    required this.enName,
    this.mainArName,
    this.mainEnName,
    this.parentArName,
    this.parentEnName,
    required this.services,
    required this.products,
    required this.showProducts,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              [
                ar ? mainArName : mainEnName,
                ar ? parentArName : parentEnName,
                ar ? arName : enName,
              ].whereType<String>().where((e) => e.isNotEmpty).join(' ‹ '),
              style: TextStyle(color: AppColors.subtitleGrey, fontSize: 11.sp),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  text(
                    'اختار الخدمات أو المنتجات',
                    'Choose services or products',
                  ),
                  style: TextStyle(
                    color: AppColors.subtitleGrey,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBDD),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                CatalogTab(
                  product: false,
                  showProducts: showProducts,
                  cubit: services,
                  onTap: () => onTabChanged(false),
                ),
                CatalogTab(
                  product: true,
                  showProducts: showProducts,
                  cubit: products,
                  onTap: () => onTabChanged(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
