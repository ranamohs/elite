import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/account_access.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../account/presentation/widgets/account_actions.dart';
import '../../../account/presentation/widgets/account_ui.dart';

class TechnicalAccountView extends StatelessWidget {
  const TechnicalAccountView({super.key});
  @override
  Widget build(BuildContext context) {
    final user = getIt<UserDataManager>();
    final access = AccountAccess(
      accountType: user.getAccountType() ?? '',
      isActive: user.getIsActive(),
      registrationStatus: user.getRegistrationStatus(),
    );
    final rejected = user.getRegistrationStatus() == 'rejected';
    return AccountScaffold(
      title: accountText(context, 'حساب الفني', 'Technician account'),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          SizedBox(height: 30.h),
          CircleAvatar(
            radius: 38.r,
            backgroundColor: AppColors.badgeBg,
            child: Icon(
              access.canUseTechnicalPages
                  ? Icons.engineering_outlined
                  : Icons.hourglass_top_rounded,
              color: AppColors.primaryColor,
              size: 42.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            user.getUserName() ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          AccountCard(
            child: Column(
              children: [
                Text(
                  access.canUseTechnicalPages
                      ? accountText(
                    context,
                    'حسابك مفعّل',
                    'Your account is active',
                  )
                      : access.isPending
                      ? accountText(
                    context,
                    'طلبك قيد المراجعة',
                    'Your application is under review',
                  )
                      : rejected
                      ? accountText(
                    context,
                    'طلب التسجيل غير مقبول',
                    'Registration was not approved',
                  )
                      : accountText(
                    context,
                    'الحساب غير متاح لاستقبال الطلبات حاليًا',
                    'Your account is not available to receive orders yet',
                  ),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  access.isPending
                      ? accountText(
                    context,
                    'تم استلام بياناتك. حسابك في انتظار موافقة المسؤول.',
                    'Your details were submitted and are awaiting administrator approval.',
                  )
                      : access.canUseTechnicalPages
                      ? accountText(
                    context,
                    'ده مدخل صفحات الفني. صفحات الطلبات الفنية هتتضاف في الخطوات الجاية.',
                    'This is your technician area. Technician job pages will be added next.',
                  )
                      : accountText(
                    context,
                    'تواصلي مع الدعم لمعرفة حالة الحساب.',
                    'Contact support to check your account status.',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.8,
                    color: AppColors.subtitleGrey,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          OutlinedButton(
            onPressed: () => context.push(AppRouter.technicalLogin),
            child: Text(
              accountText(
                context,
                'تسجيل الدخول للتحقق من الحالة',
                'Sign in to check account status',
              ),
            ),
          ),

        ],
      ),
    );
  }
}
