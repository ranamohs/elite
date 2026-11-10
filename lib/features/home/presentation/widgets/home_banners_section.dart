import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';

class HomeBannersSection extends StatefulWidget {
  final List<dynamic>? banners;
  final void Function(int index)? onBannerTap;

  const HomeBannersSection({
    super.key,
    this.banners,
    this.onBannerTap,
  });

  @override
  State<HomeBannersSection> createState() => _HomeBannersSectionState();
}

class _HomeBannersSectionState extends State<HomeBannersSection> {
  int _bannerIndex = 0;
  final PageController _bannerController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = (widget.banners != null && widget.banners!.isNotEmpty)
        ? widget.banners!.length
        : 3;

    return Column(
      children: [
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _bannerIndex = index;
              });
            },
            itemCount: count,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE0EDF3),
                        Color(0xFF8AA38B),
                        Color(0xFF384A33),
                      ],
                      stops: [0.0, 0.45, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left AC graphic
                      Positioned(
                        left: 10.w,
                        top: 10.h,
                        bottom: 10.h,
                        width: 90.w,
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                        ),
                      ),

                      // Right Texts & Button (in RTL layout)
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(95.w, 10.h, 14.w, 10.h),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'صيانة التكييف قبل الصيف',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  'خصم 20% بكود SUMMER20',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                // "احجز دلوقتي" button
                                GestureDetector(
                                  onTap: () {
                                    if (widget.onBannerTap != null) {
                                      widget.onBannerTap!(index);
                                    } else {
                                      GoRouter.of(context)
                                          .push(AppRouter.allCategoriesView);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.homeHeaderGreen,
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Text(
                                      'احجز دلوقتي',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

        SizedBox(height: 10.h),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final isActive = _bannerIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              height: 6.h,
              width: isActive ? 18.w : 6.w,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.homeHeaderGreen
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}
