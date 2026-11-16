import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import 'account_avatar.dart';
import 'account_ui.dart';

class AccountHeaderCard extends StatelessWidget {
  final UserDataManager user;
  final VoidCallback onEdit;
  const AccountHeaderCard({
    super.key,
    required this.user,
    required this.onEdit,
  });
  @override
  Widget build(BuildContext context) => AccountCard(
    child: Row(
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
                    color: AppColors.subtitleGrey,
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
    ),
  );
}
