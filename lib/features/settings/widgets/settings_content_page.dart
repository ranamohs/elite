import 'package:elite/features/settings/widgets/settings_content_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../account/presentation/widgets/account_ui.dart';

class SettingsContentPage extends StatelessWidget {
  final String title;
  final String? content, error;
  final IconData icon;
  final bool loading, refreshing;
  final Future<void> Function() onRefresh;
  const SettingsContentPage({
    super.key,
    required this.title,
    required this.icon,
    required this.onRefresh,
    this.content,
    this.error,
    this.loading = false,
    this.refreshing = false,
  });
  @override
  Widget build(BuildContext context) {
    final text = settingsContentText(content);
    return AccountScaffold(
      title: title,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
          children: [
            if (refreshing) ...[
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 12.h),
            ],
            AccountCard(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.badgeBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.badgeTextGreen,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titleDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  const Divider(color: AppColors.unselectedBorder),
                  SizedBox(height: 12.h),
                  if (loading)
                    Shimmer.fromColors(
                      baseColor: AppColors.loadingEffectColor,
                      highlightColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(
                          8,
                              (i) => FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: i == 7 ? .55 : 1,
                            child: Container(
                              height: 12.h,
                              margin: EdgeInsets.only(bottom: 14.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (error != null) ...[
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 36.sp,
                      color: AppColors.subtitleGrey,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.subtitleGrey,
                        height: 1.7,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    OutlinedButton(
                      onPressed: onRefresh,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.badgeTextGreen,
                        side: const BorderSide(color: AppColors.primaryColor),
                      ),
                      child: Text(
                        accountText(context, 'إعادة المحاولة', 'Try again'),
                      ),
                    ),
                  ] else if (text.isEmpty) ...[
                    Icon(
                      Icons.article_outlined,
                      size: 40.sp,
                      color: AppColors.subtitleGrey,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      accountText(
                        context,
                        'لا يوجد محتوى متاح حاليًا',
                        'No content available yet',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.subtitleGrey,
                      ),
                    ),
                  ] else
                    SelectableText(
                      text,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                        height: 1.9,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
