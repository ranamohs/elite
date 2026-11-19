import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/models/contracts_models/maintenance_contracts_model.dart';
import 'contract_formatters.dart';

class MaintenanceContractCardItem extends StatelessWidget {
  final MaintenanceContract contract;
  final bool isArabic;
  final VoidCallback? onOrderTap;

  const MaintenanceContractCardItem({
    super.key,
    required this.contract,
    required this.isArabic,
    this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = isArabic ? contract.name.ar : contract.name.en;
    final description =
    isArabic ? contract.description.ar : contract.description.en;
    final durationText = contractDurationText(contract.duration, isArabic);
    final priceText = contractPriceText(contract);

    final features = contract.features
        .map((feature) => contractFeatureText(feature, isArabic))
        .where((feature) => feature.trim().isNotEmpty)
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                child: _buildImage(),
              ),
              if (durationText.isNotEmpty)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.homeContractDarkGreen.withValues(
                        alpha: 0.92,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          durationText,
                          style: AppStyles.styleRegular14(context).copyWith(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.styleMedium16(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.titleDark,
                  ),
                ),
                if (description.trim().isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.styleRegular14(context).copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subtitleGrey,
                      height: 1.4,
                    ),
                  ),
                ],
                if (features.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: features
                        .map((feature) => _buildFeatureChip(feature))
                        .toList(),
                  ),
                ],
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (priceText.isNotEmpty)
                      Expanded(
                        child: Text(
                          priceText,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.styleMedium16(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.homeContractBadgeGreen,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    GestureDetector(
                      onTap: onOrderTap ?? () => _openDetails(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.homeHeaderGreen,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          AppStrings.viewDetails.tr(),
                          style: AppStyles.styleMedium16(context).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context) {
    GoRouter.of(context).push(
      AppRouter.contractDetailsView,
      extra: {'contractId': contract.id},
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 12.sp,
            color: AppColors.homeContractBadgeGreen,
          ),
          SizedBox(width: 4.w),
          Text(
            feature,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.homeContractBadgeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = contract.image;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _imagePlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 150.h,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.loadingEffectColor,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 150.h,
          color: Colors.white,
        ),
      ),
      errorWidget: (context, url, error) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 150.h,
      width: double.infinity,
      color: const Color(0xFFF1F8E9),
      child: Center(
        child: Icon(
          Icons.description_outlined,
          size: 42.sp,
          color: AppColors.homeHeaderGreen,
        ),
      ),
    );
  }
}
