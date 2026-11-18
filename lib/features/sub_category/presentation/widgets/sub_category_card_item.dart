import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/end_points.dart';
import '../../data/models/sub_category_model.dart';

const List<Color> kSubCategoryIconBgColors = [
  Color(0xFFEAF5E4),
  Color(0xFFE5F1FC),
  Color(0xFFFEF0DE),
  Color(0xFFFDEEEC),
  Color(0xFFF1EEFB),
  Color(0xFFE8F6F6),
];

Color getSubCategoryIconBgColor(int index) {
  return kSubCategoryIconBgColors[index % kSubCategoryIconBgColors.length];
}

class SubCategoryCardItem extends StatelessWidget {
  final SubCategoryItem item;
  final int index;
  final bool isArabic;
  final VoidCallback? onTap;

  const SubCategoryCardItem({
    super.key,
    required this.item,
    required this.index,
    required this.isArabic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? item.name.ar : item.name.en;

    String? fullImageUrl = item.image;
    if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (!fullImageUrl.startsWith('http')) {
        fullImageUrl = '${EndPoints.IMAGE_BASE_URL}$fullImageUrl';
      }
    }

    final iconBgColor = getSubCategoryIconBgColor(index);

    String badgeText;
    if (item.servicesCount != null && item.productsCount != null) {
      badgeText = AppStrings.servicesWithProducts.tr(
        namedArgs: {
          'services': '${item.servicesCount}',
          'products': '${item.productsCount}',
        },
      );
    } else if (item.servicesCount != null) {
      badgeText = AppStrings.servicesCount.tr(
        namedArgs: {'count': '${item.servicesCount}'},
      );
    } else {
      final defaultCounts = [
        AppStrings.zeroServicesWithProducts.tr(),
        AppStrings.zeroServiceWithProduct.tr(),
        AppStrings.zeroServices.tr(),
      ];
      badgeText = defaultCounts[index % defaultCounts.length];
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: (fullImageUrl != null && fullImageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: fullImageUrl,
                      width: 36.w,
                      height: 36.w,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.loadingEffectColor,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.water_damage_outlined,
                        size: 28.sp,
                        color: AppColors.homeHeaderGreen,
                      ),
                    )
                        : Icon(
                      Icons.water_damage_outlined,
                      size: 28.sp,
                      color: AppColors.homeHeaderGreen,
                    ),
                  ),
                ),

                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:AppStyles.styleMedium16(context).copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleDark,
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8E9),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          badgeText,
                          style:AppStyles.styleMedium16(context).copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.homeContractBadgeGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 15.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
