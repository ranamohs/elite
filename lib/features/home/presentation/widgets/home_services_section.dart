import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';

class ServiceModelItem {
  final String title;
  final String iconAsset;
  final String? iconNetworkUrl;
  final Color topBgColor;
  final dynamic categoryId;

  const ServiceModelItem({
    required this.title,
    required this.iconAsset,
    this.iconNetworkUrl,
    required this.topBgColor,
    this.categoryId,
  });
}

class HomeServicesSection extends StatelessWidget {
  final List<ServiceModelItem>? customServices;
  final void Function(ServiceModelItem service)? onServiceTap;
  final VoidCallback? onViewAllTap;

  const HomeServicesSection({
    super.key,
    this.customServices,
    this.onServiceTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final services = customServices ??
        const [
          ServiceModelItem(
            title: 'سباكة',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.servicePlumbingBg,
          ),
          ServiceModelItem(
            title: 'كهرباء',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.serviceElectricityBg,
          ),
          ServiceModelItem(
            title: 'تكييف',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.serviceAcBg,
          ),
          ServiceModelItem(
            title: 'نجارة',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.serviceCarpentryBg,
          ),
          ServiceModelItem(
            title: 'ألوميتال',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.serviceAluminumBg,
          ),
          ServiceModelItem(
            title: 'شاتر',
            iconAsset: AppAssets.logo,
            topBgColor: AppColors.serviceShutterBg,
          ),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Services Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'الخدمات',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.titleDark,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAllTap ??
                          () {
                        GoRouter.of(context).push(AppRouter.allCategoriesView);
                      },
                  child: Text(
                    'كل الخدمات (${services.length > 6 ? services.length : 15})',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.homeContractBadgeGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 14.h),

        // Services Grid (3 x 2)
        Directionality(
          textDirection: TextDirection.rtl,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: services.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final item = services[index];
              return GestureDetector(
                onTap: () {
                  if (onServiceTap != null) {
                    onServiceTap!(item);
                  } else {
                    GoRouter.of(context).push(AppRouter.allCategoriesView);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.04),
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
                      // Top colored container with icon
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: item.topBgColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18.r),
                              topRight: Radius.circular(18.r),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: Image.asset(
                                item.iconAsset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom white container with name
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(18.r),
                              bottomRight: Radius.circular(18.r),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            item.title,
                            style: TextStyle(
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
            },
          ),
        ),
      ],
    );
  }
}
