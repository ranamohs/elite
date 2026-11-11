import 'package:cached_network_image/cached_network_image.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/end_points.dart';
import '../../data/models/category_services_model.dart';

const List<Color> kServiceTileIconBgColors = [
  Color(0xFFFDEEEC), // Soft peach / coral
  Color(0xFFE5F1FC), // Soft blue
  Color(0xFFEEF2F6), // Soft light grey-blue
  Color(0xFFEAF5E4), // Soft green
  Color(0xFFE2F0FB), // Soft cyan
  Color(0xFFF1EEFB), // Soft purple
  Color(0xFFFEF6E8), // Soft warm cream
  Color(0xFFE8F1FC), // Light blue
];

Color getServiceIconBgColor(int index) {
  return kServiceTileIconBgColors[index % kServiceTileIconBgColors.length];
}

class CategoryServiceCardItem extends StatelessWidget {
  final CategoryServiceItem service;
  final int index;
  final bool isArabic;
  final VoidCallback? onTap;

  const CategoryServiceCardItem({
    super.key,
    required this.service,
    required this.index,
    required this.isArabic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? service.name.ar : service.name.en;
    final description =
    isArabic ? service.description.ar : service.description.en;

    String? fullImageUrl = service.thumbnail;
    if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (!fullImageUrl.startsWith('http')) {
        fullImageUrl = '${EndPoints.IMAGE_BASE_URL}$fullImageUrl';
      }
    }

    final iconBgColor = getServiceIconBgColor(index);

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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
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
                        Icons.handyman_outlined,
                        size: 26.sp,
                        color: AppColors.homeHeaderGreen,
                      ),
                    )
                        : Icon(
                      Icons.handyman_outlined,
                      size: 26.sp,
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
                        style: AppStyles.styleMedium16(context).copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleDark,
                          height: 1.25,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 5.h),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:AppStyles.styleRegular14(context).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(width: 8.w),
                Icon(
                 Icons.arrow_forward_ios_rounded,
                  color: AppColors.subtitleGrey,
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
