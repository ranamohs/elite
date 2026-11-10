import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/databases/cache/app_data_manager.dart';
import '../../../../core/databases/cache/cache_helper.dart';
import '../../../../core/functions/navigation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/service_locator.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  String selectedLanguage = 'ar';
  final CacheHelper _cacheHelper = getIt<CacheHelper>();

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _cacheHelper.getData(key: 'language');
    if (savedLanguage != null) {
      setState(() {
        selectedLanguage = savedLanguage;
        context.setLocale(Locale(savedLanguage));
      });
    }
  }

  Future<void> saveLanguage(String languageCode) async {
    await _cacheHelper.saveData(key: 'language', value: languageCode);
  }

  void _onLanguageSelected(String langCode) {
    setState(() {
      selectedLanguage = langCode;
      context.setLocale(Locale(langCode));
      saveLanguage(langCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.welcomeBgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 36.h),
                    Container(
                      width: 96.w,
                      height: 96.w,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAssets.appLogo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),
                    Text(
                      AppStrings.selectYourLanguage.tr(),
                      style: AppStyles.styleSemiBold24(context).copyWith(
                        color: AppColors.titleDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 22.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.chooseYourLanguageSubtitle.tr(),
                      style:AppStyles.styleRegular12(context).copyWith(
                          color: AppColors.subtitleGrey
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 28.h),
                    _buildLanguageCard(
                      langCode: 'ar',
                      primaryTitle: 'العربية',
                      subTitle: 'Arabic',
                      badgeText: 'ع',
                    ),
                    SizedBox(height: 14.h),
                    _buildLanguageCard(
                      langCode: 'en',
                      primaryTitle: 'English',
                      subTitle: 'الإنجليزية',
                      badgeText: 'En',
                    ),
                    SizedBox(height: 22.h),
                    Text(
                      'تقدر تغير اللغة بعدين من الإعدادات',
                      style:AppStyles.styleRegular12(context).copyWith(
                          color: AppColors.subtitleGrey
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
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
              child: SizedBox(
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
                    final appDataManager = getIt<AppDataManager>();
                    appDataManager.saveIsSelectLanguageViewVisited(
                      isSelectLanguageViewVisited: true,
                    );
                    customPushReplacement(context, AppRouter.introView);
                  },
                  child: Text(
                    AppStrings.next.tr(),
                    style: AppStyles.styleRegular16(context).copyWith(
                      color: AppColors.white,
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

  Widget _buildLanguageCard({
    required String langCode,
    required String primaryTitle,
    required String subTitle,
    required String badgeText,
  }) {
    final bool isSelected = selectedLanguage == langCode;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () => _onLanguageSelected(langCode),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 72.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.unselectedBorder,
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildRadioIndicator(isSelected),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    primaryTitle,
                    style:AppStyles.styleRegular16(context).copyWith(
                        color: AppColors.titleDark,
                      fontWeight: FontWeight.w600
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subTitle,
                    style:AppStyles.styleRegular12(context).copyWith(
                        color: AppColors.subtitleGrey
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),

              SizedBox(width: 14.w),

              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.badgeTextGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioIndicator(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryColor, width: 2.2),
        ),
        child: Center(
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.unselectedRadioBorder, width: 1.8),
        ),
      );
    }
  }
}
