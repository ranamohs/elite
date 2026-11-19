import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';

class OffersLoadingWidget extends StatelessWidget {
  const OffersLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: AppColors.loadingEffectColor,
    highlightColor: Colors.white,
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 4.h),
      children: List.generate(
        3,
            (_) => Container(
          height: 250.h,
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    ),
  );
}
