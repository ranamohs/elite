import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/navigation.dart';
import '../../../../core/routes/app_router.dart';

class OnboardingModel {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingModel> _pages = [
    OnboardingModel(
      image: AppAssets.onBoarding_1,
      title: 'كل خدمات بيتك في مكان واحد',
      subtitle: 'سباكة، كهرباء، تكييف، نجارة وأكثر من 15 خدمة ثانية بضغطة زرار',
    ),
    OnboardingModel(
      image: AppAssets.onBoarding_2,
      title: 'فنيين موثوقين ومدربين',
      subtitle: 'كل فنيينا متراجعين ومتقيمين، ونقدر تتابع الفني لحد باب بيتك',
    ),
    OnboardingModel(
      image: AppAssets.onBoarding_3,
      title: 'أسعار واضحة وضمان على الشغل',
      subtitle: 'اعرف السعر قبل ما تطلب، وكل شغلنا عليه ضمان 30 يوم',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() {
    customPushReplacement(context, AppRouter.loginView);
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.welcomeBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: isLastPage
                    ? SizedBox(height: 24.h)
                    : GestureDetector(
                  onTap: _onSkip,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    AppStrings.skip.tr(),
                    style:AppStyles.styleRegular12(context).copyWith(
                        color: AppColors.subtitleGrey
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(maxHeight: 250.h),
                            color: Colors.transparent,
                            child: Image.asset(
                              page.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),
                        Text(
                          page.title,
                          style: AppStyles.styleSemiBold24(context).copyWith(
                            color: AppColors.titleDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            page.subtitle,
                            style:AppStyles.styleRegular12(context).copyWith(
                                color: AppColors.subtitleGrey
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 100.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _pages.length,
                                (dotIndex) => _buildIndicatorDot(dotIndex == _currentIndex),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                20.w,
                18.h,
                20.w,
                24.h + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: isLastPage
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () {
                        customPushReplacement(context, AppRouter.registerView);
                      },
                      child: Text(
                        AppStrings.signUp.tr(),
                        style: AppStyles.styleRegular16(context).copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        side: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () {
                        customPushReplacement(context, AppRouter.loginView);
                      },
                      child: Text(
                        AppStrings.login.tr(),
                        style: AppStyles.styleRegular16(context).copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  onPressed: _onNext,
                  child: Text(
                    AppStrings.next.tr(),
                    style: AppStyles.styleRegular16(context).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: isActive ? 16.w : 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryColor : AppColors.unselectedRadioBorder,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
