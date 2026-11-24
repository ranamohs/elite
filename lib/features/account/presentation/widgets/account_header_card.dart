import '../../../../core/auth/account_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../technical/requests/data/models/assigned_requests_model.dart';
import 'account_avatar.dart';
import 'account_ui.dart';

class AccountHeaderCard extends StatelessWidget {
  final UserDataManager user;
  final VoidCallback onEdit;
  final AssignedRequestStats? technicalStats;
  final VoidCallback? onOrders;
  const AccountHeaderCard({
    super.key,
    required this.user,
    required this.onEdit,
    this.technicalStats,
    this.onOrders,
  });
  @override
  Widget build(BuildContext context) {
    final technical = AccountAccess(
      accountType: user.getAccountType() ?? 'customer',
    ).isTechnical;
    final profile = Row(
      children: [
        AccountAvatar(url: user.getUserAvatarUrl(), radius: 25.r),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.getUserName() ??
                    accountText(context, 'حسابي', 'My account'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
              if (user.getUserPhoneNumber()?.isNotEmpty == true)
                Text(
                  user.getUserPhoneNumber()!,
                  style: TextStyle(
                    color: technical
                        ? Colors.white.withValues(alpha: .85)
                        : AppColors.subtitleGrey,
                    fontSize: 11.sp,
                  ),
                ),
            ],
          ),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            backgroundColor: AppColors.badgeBg,
            foregroundColor: AppColors.badgeTextGreen,
          ),
          child: Text(accountText(context, 'تعديل', 'Edit')),
        ),
      ],
    );
    if (!technical) return AccountCard(child: profile);
    final stats = technicalStats;
    final total = stats?.total;
    String percent(int? value) => value == null || total == null || total == 0
        ? '—'
        : '${(value / total * 100).toStringAsFixed(0)}%';
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: profile,
          ),
          if (user.getIsActive() != null)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  accountText(
                    context,
                    user.getIsActive() == true
                        ? 'حساب مفعّل'
                        : 'حساب غير مفعّل',
                    user.getIsActive() == true
                        ? 'Active account'
                        : 'Inactive account',
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          SizedBox(height: 14.h),
          Row(
            children: [
              metric(
                context,
                stats?.total?.toString() ?? '—',
                accountText(context, 'طلب', 'Requests'),
                onOrders,
              ),
              SizedBox(width: 8.w),
              metric(
                context,
                percent(stats?.completed),
                accountText(context, 'مكتملة', 'Completed'),
                null,
              ),
              SizedBox(width: 8.w),
              metric(
                context,
                percent(stats?.canceled),
                accountText(context, 'إلغاء', 'Canceled'),
                null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget metric(
      BuildContext context,
      String value,
      String label,
      VoidCallback? tap,
      ) => Expanded(
    child: InkWell(
      onTap: tap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
            ),
          ],
        ),
      ),
    ),
  );
}