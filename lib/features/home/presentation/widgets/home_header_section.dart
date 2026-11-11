import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/databases/cache/user_data_manager.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/services/service_locator.dart';

class HomeHeaderSection extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;

  const HomeHeaderSection({
    super.key,
    this.onNotificationTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    String? userName;
    try {
      if (getIt.isRegistered<UserDataManager>()) {
        userName = getIt<UserDataManager>().getUserName();
      }
    } catch (_) {
      userName = null;
    }
    final displayName = (userName != null && userName.isNotEmpty)
        ? userName.split(' ').first
        : 'أحمد';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeHeaderGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(18.w, topPadding + 10.h, 18.w, 22.h),
      child: Column(
        children: [
          // Top Row: Notification Bell (Left) & User Info with Avatar (Right in RTL)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Right side in RTL: Avatar + Greeting + Location
                Row(
                  children: [
                    // Circular Avatar
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: AppColors.homeHeaderGreen,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),

                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أهلاً، $displayName',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'المعادي، القاهرة',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                GestureDetector(
                  onTap: onNotificationTap,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // Search Field in Header
          Directionality(
            textDirection: TextDirection.rtl,
            child: GestureDetector(
              onTap: onSearchTap ??
                      () {
                    GoRouter.of(context).push(AppRouter.searchView);
                  },
              child: Container(
                width: double.infinity,
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: Color(0xFF8E939C),
                      size: 20,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'ابحث عن خدمة... مثلاً: سخان، تكييف',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF8E939C),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
