import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';

class HomeContractSection extends StatelessWidget {
  final VoidCallback? onOrderTap;
  final String? title;
  final String? badgeText;
  final String? description;
  final String? priceText;

  const HomeContractSection({
    super.key,
    this.onOrderTap,
    this.title,
    this.badgeText,
    this.description,
    this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeContractDarkGreen,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            // Right info (in RTL)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + "جديد" badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title ?? 'عقد الصيانة الشهري',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.homeContractBadgeGreen,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          badgeText ?? 'جديد',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Subtitle
                  Text(
                    description ?? 'زيارة صيانة كل شهر وأولوية في أي عطل',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Bottom row: "اطلب العقد" button & "200 ج.م / شهر"
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onOrderTap ??
                                () {
                              GoRouter.of(context)
                                  .push(AppRouter.allCategoriesView);
                            },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.homeHeaderGreen,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            'اطلب العقد',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          priceText ?? '200 ج.م / شهر',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.homeHeaderGreen,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            // Left house illustration container (in RTL, left is end)
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFDCEBC2),
                borderRadius: BorderRadius.circular(18.r),
              ),
              padding: EdgeInsets.all(6.w),
              child: Center(
                child: Image.asset(
                  AppAssets.logo,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.home_work_rounded,
                      color: AppColors.homeContractDarkGreen,
                      size: 34,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
