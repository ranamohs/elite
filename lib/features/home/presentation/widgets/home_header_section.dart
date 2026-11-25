import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/databases/cache/user_data_manager.dart';
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
        : AppStrings.guestUser.tr();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.badgeTextGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(18.w, topPadding + 10.h, 18.w, 22.h),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
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
                          AppAssets.appLogo,
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
                            style: AppStyles.styleMedium16(context).copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )
                        ),

                      ],
                    ),
                  ],
                ),

              ],
            ),
          ),

          // SizedBox(height: 18.h),
          //
          // Directionality(
          //   textDirection: TextDirection.rtl,
          //   child: GestureDetector(
          //     onTap: onSearchTap,
          //     child: Container(
          //       width: double.infinity,
          //       height: 48.h,
          //       padding: EdgeInsets.symmetric(horizontal: 14.w),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(16.r),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withValues(alpha: 0.05),
          //             blurRadius: 8,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         children: [
          //           const Icon(
          //             Icons.search,
          //             color: AppColors.subtitleGrey,
          //             size: 20,
          //           ),
          //           SizedBox(width: 8.w),
          //           Expanded(
          //             child: Text(
          //               AppStrings.searchHint.tr(),
          //               style: AppStyles.styleRegular14(context).copyWith(
          //                 fontSize: 12.sp,
          //                 color: AppColors.subtitleGrey,
          //                 fontWeight: FontWeight.w400,
          //               ),
          //               overflow: TextOverflow.ellipsis,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
