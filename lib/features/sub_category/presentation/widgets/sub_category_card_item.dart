import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/end_points.dart';
import '../../data/models/sub_category_model.dart';

const List<Color> kSubCategoryIconBgColors = [
  Color(0xFFEAF5E4), // Soft light green
  Color(0xFFE5F1FC), // Soft blue
  Color(0xFFFEF0DE), // Soft peach / warm yellow
  Color(0xFFFDEEEC), // Soft coral
  Color(0xFFF1EEFB), // Soft purple
  Color(0xFFE8F6F6), // Soft teal
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
    final description = item.description ??
        (isArabic ? 'تركيب سخان جديد أو فك القديم' : 'Installation or removal');

    String? fullImageUrl = item.image;
    if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (!fullImageUrl.startsWith('http')) {
        fullImageUrl = '${EndPoints.IMAGE_BASE_URL}$fullImageUrl';
      }
    }

    final iconBgColor = getSubCategoryIconBgColor(index);

    // Badges/chips text (e.g. '3 خدمات • 4 منتجات' or count fallback)
    String badgeText;
    if (item.servicesCount != null && item.productsCount != null) {
      badgeText = isArabic
          ? '${item.servicesCount} خدمات • ${item.productsCount} منتجات'
          : '${item.servicesCount} services • ${item.productsCount} products';
    } else if (item.servicesCount != null) {
      badgeText = isArabic
          ? '${item.servicesCount} خدمة'
          : '${item.servicesCount} services';
    } else {
      // Default placeholder matching design visually
      final defaultCounts = [
        isArabic ? '3 خدمات • 4 منتجات' : '3 services • 4 products',
        isArabic ? '2 خدمة • 2 منتج' : '2 services • 2 products',
        isArabic ? '2 خدمة' : '2 services',
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
                // 1) Icon Container (on the right in RTL, left in LTR)
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

                // 2) Content Column (Title, Description, Chip)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Light green rounded badge
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
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF558B2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // 3) Chevron Arrow
                Icon(
                  isArabic
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_forward_ios_rounded,
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
