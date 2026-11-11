import 'package:cached_network_image/cached_network_image.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/end_points.dart';

const List<Color> kCategoryCardTopColors = [
  Color(0xFFE3F0FB), // Blue / Plumbing
  Color(0xFFFEF6D8), // Yellow / Electricity
  Color(0xFFE6F4FA), // Soft blue / AC
  Color(0xFFF7EBDD), // Peach / Carpentry
  Color(0xFFEEF1F4), // Muted grey-blue / Aluminum
  Color(0xFFECEFF1), // Light grey / Shutter
  Color(0xFFEAF5E4), // Mint green
  Color(0xFFF2EAF8), // Lavender
  Color(0xFFFDF0E6), // Light orange
];

Color getCategoryCardColor(int index) {
  return kCategoryCardTopColors[index % kCategoryCardTopColors.length];
}

class CategoryCardItem extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final Color topBgColor;
  final VoidCallback? onTap;

  const CategoryCardItem({
    super.key,
    required this.title,
    this.imageUrl,
    required this.topBgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? fullImageUrl = imageUrl;
    if (fullImageUrl != null && fullImageUrl.isNotEmpty) {
      if (!fullImageUrl.startsWith('http')) {
        fullImageUrl = '${EndPoints.IMAGE_BASE_URL}$fullImageUrl';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: topBgColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: (fullImageUrl != null && fullImageUrl.isNotEmpty)
                        ? CachedNetworkImage(
                      imageUrl: fullImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.loadingEffectColor,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.category_outlined,
                        size: 32.sp,
                        color: AppColors.homeHeaderGreen,
                      ),
                    )
                        : Icon(
                      Icons.category_outlined,
                      size: 32.sp,
                      color: AppColors.homeHeaderGreen,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:AppStyles.styleRegular14(context).copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.titleDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
