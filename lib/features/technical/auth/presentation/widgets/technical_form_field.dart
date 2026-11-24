import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../account/presentation/widgets/account_ui.dart';


class TechnicalFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboard;
  final bool password;
  final int maxLines;
  final String? Function(String?)? validator;
  const TechnicalFormField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard = TextInputType.text,
    this.password = false,
    this.maxLines = 1,
    this.validator,
  });
  @override
  State<TechnicalFormField> createState() => _TechnicalFormFieldState();
}

class _TechnicalFormFieldState extends State<TechnicalFormField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 14.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 12.sp)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboard,
          obscureText: widget.password && hidden,
          maxLines: widget.password ? 1 : widget.maxLines,
          autocorrect: !widget.password,
          enableSuggestions: !widget.password,
          validator:
          widget.validator ??
                  (value) => value == null || value.trim().isEmpty
                  ? accountText(
                context,
                'هذا الحقل مطلوب',
                'This field is required',
              )
                  : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            suffixIcon: widget.password
                ? IconButton(
              onPressed: () => setState(() => hidden = !hidden),
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.unselectedBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.unselectedBorder),
            ),
          ),
        ),
      ],
    ),
  );
}
