import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../account/presentation/widgets/account_actions.dart';
import '../../../account/presentation/widgets/account_avatar.dart';
import '../../../account/presentation/widgets/account_ui.dart';

class TechnicalHomeView extends StatelessWidget {
  const TechnicalHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final user = getIt<UserDataManager>();
    final name = user.getUserName()?.trim() ?? '';
    final phone = user.getUserPhoneNumber()?.trim() ?? '';
    return AccountScaffold(
      title: accountText(context, 'الرئيسية', 'Home'),
      embedded: true,
      body: ListView(
        padding: EdgeInsets.all(18.w),
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.homeContractDarkGreen,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                AccountAvatar(url: user.getUserAvatarUrl(), radius: 30.r),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty
                            ? accountText(context, 'أهلاً بيك', 'Welcome')
                            : accountText(
                          context,
                          'أهلاً، $name',
                          'Welcome, $name',
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        accountText(context, 'حساب فني', 'Technician account'),
                        style: TextStyle(
                          color: AppColors.badgeBg,
                          fontSize: 12.sp,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          phone,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            accountText(context, 'خدمات حسابك', 'Account services'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          AccountCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                AccountMenuTile(
                  icon: Icons.help_outline,
                  title: accountText(
                    context,
                    'الدعم والمساعدة',
                    'Help and support',
                  ),
                  onTap: () => context.push(AppRouter.helpAndSupportView),
                ),
                const Divider(height: 1),
                AccountMenuTile(
                  icon: Icons.language,
                  title: accountText(context, 'لغة التطبيق', 'App language'),
                  onTap: () => context.push(AppRouter.changeLanguageView),
                ),
                const Divider(height: 1),
                AccountMenuTile(
                  icon: Icons.description_outlined,
                  title: accountText(
                    context,
                    'الشروط والأحكام',
                    'Terms and conditions',
                  ),
                  onTap: () => context.push(AppRouter.termsAndConditionsView),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          AccountCard(
            padding: EdgeInsets.zero,
            child: AccountMenuTile(
              icon: Icons.logout_rounded,
              title: accountText(context, 'تسجيل الخروج', 'Sign out'),
              destructive: true,
              onTap: () => showAccountLogout(context),
              trailing: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}