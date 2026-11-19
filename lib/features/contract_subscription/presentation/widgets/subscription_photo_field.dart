import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../account/presentation/widgets/account_ui.dart';

class SubscriptionPhotoField extends StatelessWidget {
  final String? path;
  final VoidCallback onSelect;
  const SubscriptionPhotoField({super.key, this.path, required this.onSelect});
  @override
  Widget build(BuildContext context) => AccountCard(
    child: Column(
      children: [
        if (path != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.file(
              File(path!),
              height: 130.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image_outlined),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 42.sp,
              color: AppColors.badgeTextGreen,
            ),
          ),
        TextButton(
          onPressed: onSelect,
          child: Text(
            path == null
                ? accountText(
              context,
              'إضافة الصورة المطلوبة',
              'Add required photo',
            )
                : accountText(context, 'تغيير الصورة', 'Change photo'),
          ),
        ),
        Text(
          accountText(
            context,
            'JPG / JPEG / PNG / WEBP — بحد أقصى 5 ميجابايت',
            'JPG / JPEG / PNG / WEBP — up to 5 MB',
          ),
          style: TextStyle(color: AppColors.subtitleGrey, fontSize: 10.sp),
        ),
      ],
    ),
  );
}
