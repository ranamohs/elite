import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';

String accountText(BuildContext context, String ar, String en) =>
    isArabic(context) ? ar : en;
void accountInfo(BuildContext context, String ar, String en) =>
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(accountText(context, ar, en))));

class AccountScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomBar;
  final bool embedded;
  const AccountScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomBar,
    this.embedded = false,
  });
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
    child: Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: AppStyles.styleMedium16(context).fontFamily,
        ),
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: AppColors.primaryColor),
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        appBar: AppBar(
          backgroundColor: AppColors.homeBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: !embedded,
          title: Text(
            title,
            style: AppStyles.styleMedium16(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: SafeArea(top: false, bottom: !embedded, child: body),
        bottomNavigationBar: bottomBar,
      ),
    ),
  );
}

class AccountCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const AccountCard({super.key, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.unselectedBorder),
    ),
    child: child,
  );
}

class AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;
  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12.r),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: destructive ? const Color(0xFFFFEDE7) : AppColors.badgeBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: destructive ? Colors.deepOrange : AppColors.badgeTextGreen,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: destructive ? Colors.deepOrange : AppColors.titleDark,
              ),
            ),
          ),
          trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.sp,
                color: AppColors.subtitleGrey,
              ),
        ],
      ),
    ),
  );
}

class AccountSaveBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const AccountSaveBar({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          minimumSize: Size(double.infinity, 46.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ),
  );
}
