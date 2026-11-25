import 'package:elite/core/functions/run_if_connected.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.text,
    required this.onPressed,
    this.child,
    this.isLoading = false,
  }) : assert(text != null || child != null, 'Provide either text or child');

  final String? text;
  final Widget? child;
  final bool isLoading;

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.offWhiteColor,
          shape: RoundedRectangleBorder(
            // side: BorderSide(
            //   color: AppColors.pureWhiteColor,
            // ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: ()=> runIfConnected(
            context: context,
            onConnected: onPressed
        ),
        child: FittedBox(
          child:
          child ??
              Text(
                text!,
                style: AppStyles.styleBold18(context).copyWith(color: AppColors.pureWhiteColor),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
        ),
      ),
    );
  }
}

class RetryButton extends StatelessWidget {
  const RetryButton({super.key, this.text, required this.onPressed, this.child})
      : assert(text != null || child != null, 'Provide either text or child');

  final String? text;
  final Widget? child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.offWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child:
        child ??
            Text(
              text!,
              style: AppStyles.styleSemiBold18(
                context,
              ).copyWith(color: AppColors.pureWhiteColor),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
      ),
    );
  }
}

