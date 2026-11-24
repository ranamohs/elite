import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/databases/cache/user_data_manager.dart';
import '../../../../account/presentation/widgets/account_avatar.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../../requests/data/models/assigned_requests_model.dart';

class TechnicalHomeHeader extends StatelessWidget {
  final UserDataManager user;
  final AssignedRequestStats? stats;
  final VoidCallback onProfile;
  const TechnicalHomeHeader({
    super.key,
    required this.user,
    required this.stats,
    required this.onProfile,
  });
  @override
  Widget build(BuildContext context) {
    final name = user.getUserName()?.trim() ?? '';
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(26.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: onProfile,
                child: AccountAvatar(
                  url: user.getUserAvatarUrl(),
                  radius: 25.r,
                ),
              ),
              SizedBox(width: 12.w),
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
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      accountText(context, 'حساب فني', 'Technician account'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.engineering_outlined, color: Colors.white),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              stat(
                accountText(context, 'إجمالي الطلبات', 'Total requests'),
                stats?.total,
              ),
              SizedBox(width: 6.w),
              stat(
                accountText(context, 'قيد الانتظار', 'Pending'),
                stats?.pending,
              ),
              SizedBox(width: 6.w),
              stat(
                accountText(context, 'مكتملة', 'Completed'),
                stats?.completed,
              ),
              SizedBox(width: 6.w),
              stat(accountText(context, 'ملغية', 'Canceled'), stats?.canceled),
            ],
          ),
        ],
      ),
    );
  }

  Widget stat(String label, int? value) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            value?.toString() ?? '—',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 9.sp),
          ),
        ],
      ),
    ),
  );
}