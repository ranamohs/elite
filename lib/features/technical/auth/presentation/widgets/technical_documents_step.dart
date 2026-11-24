import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../../auth/data/models/technical_registration_request.dart';

class TechnicalDocumentsStep extends StatelessWidget {
  final Map<String, String> documents;
  final String? picking;
  final bool accepted;
  final ValueChanged<String> onPick;
  final ValueChanged<bool> onAccept;
  const TechnicalDocumentsStep({
    super.key,
    required this.documents,
    required this.picking,
    required this.accepted,
    required this.onPick,
    required this.onAccept,
  });
  @override
  Widget build(BuildContext context) {
    final labels = [
      accountText(context, 'صورة البطاقة (وش)', 'National ID (front)'),
      accountText(context, 'صورة البطاقة (ظهر)', 'National ID (back)'),
      accountText(context, 'صورة شخصية واضحة', 'Personal photo'),
      accountText(context, 'فيش وتشبيه', 'Criminal record'),
      accountText(
        context,
        'شهادة خبرة (مطلوبة)',
        'Experience certificate (required)',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          accountText(
            context,
            'اختاري صور واضحة للمستندات عشان نراجع طلبك',
            'Select clear document photos for review',
          ),
          style: TextStyle(fontSize: 12.sp, color: AppColors.subtitleGrey),
        ),
        SizedBox(height: 16.h),
        ...List.generate(labels.length, (i) {
          final key = TechnicalRegistrationRequest.documentKeys[i];
          final selected = documents.containsKey(key);
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: AccountCard(
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.add_photo_alternate_outlined,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels[i], style: TextStyle(fontSize: 12.sp)),
                        SizedBox(height: 5.h),
                        Text(
                          selected
                              ? accountText(
                            context,
                            'تم اختيار الصورة',
                            'Photo selected',
                          )
                              : 'JPG / JPEG / PNG • 5 MB',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: selected
                                ? AppColors.badgeTextGreen
                                : AppColors.subtitleGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (picking == key)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: picking == null ? () => onPick(key) : null,
                      child: Text(
                        selected
                            ? accountText(context, 'تغيير', 'Change')
                            : accountText(context, 'رفع', 'Select'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        CheckboxListTile(
          value: accepted,
          onChanged: (value) => onAccept(value ?? false),
          activeColor: AppColors.primaryColor,
          contentPadding: EdgeInsets.zero,
          title: Text(
            accountText(
              context,
              'أقر أن بياناتي صحيحة وموافق على شروط العمل',
              'I confirm my information is correct and accept the terms',
            ),
            style: TextStyle(fontSize: 11.sp),
          ),
        ),
        TextButton(
          onPressed: () => context.push(AppRouter.termsAndConditionsView),
          child: Text(
            accountText(
              context,
              'قراءة الشروط والأحكام',
              'Read terms and conditions',
            ),
          ),
        ),
      ],
    );
  }
}
