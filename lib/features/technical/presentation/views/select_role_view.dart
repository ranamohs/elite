import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../account/presentation/widgets/account_ui.dart';

class SelectRoleView extends StatelessWidget {
  const SelectRoleView({super.key});
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'إنشاء حساب', 'Create an account'),
    body: ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        SizedBox(height: 24.h),
        Text(
          accountText(
            context,
            'حابب تنضم لينا إزاي؟',
            'How would you like to join?',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Text(
          accountText(
            context,
            'اختار نوع حسابك عشان نكمّل معاك',
            'Choose your account type to continue',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.subtitleGrey),
        ),
        SizedBox(height: 28.h),
        role(
          context,
          Icons.home_outlined,
          accountText(context, 'عميل', 'Customer'),
          accountText(
            context,
            'اطلب خدمات الصيانة وتابع طلباتك',
            'Request maintenance services and track your orders',
          ),
          AppRouter.registerView,
        ),
        SizedBox(height: 16.h),
        role(
          context,
          Icons.engineering_outlined,
          accountText(context, 'فني', 'Technician'),
          accountText(
            context,
            'قدّم بياناتك وخبراتك وانضم لفريق الفنيين',
            'Submit your details and experience to join our technicians',
          ),
          AppRouter.technicalRegister,
        ),
      ],
    ),
  );
  Widget role(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      String route,
      ) => AccountCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.badgeBg,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.badgeTextGreen, size: 30.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.7,
                      color: AppColors.subtitleGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.badgeTextGreen,
            ),
          ],
        ),
      ),
    ),
  );
}
