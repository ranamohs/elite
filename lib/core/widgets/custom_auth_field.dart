import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class CustomAuthField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final String? Function(String?)? validator;
  final int? maxLength;

  const CustomAuthField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixWidget,
    this.suffixWidget,
    this.validator,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:AppStyles.styleRegular12(context).copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.titleDark,
          ),
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLength: maxLength,
          textAlign: TextAlign.right,
          style:AppStyles.styleRegular12(context).copyWith(
              color: AppColors.titleDark
          ),
          decoration: InputDecoration(

            counterText: '',
            hintText: hintText,
            hintStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: AppColors.subtitleGrey.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            prefixIcon: prefixWidget != null
                ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              child: prefixWidget,
            )
                : null,
            suffixIcon: suffixWidget,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.unselectedBorder, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

