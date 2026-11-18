import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/functions/is_arabic.dart';
import '../../../../../core/routes/app_router.dart';
import '../../data/models/contracts_models/maintenance_contracts_model.dart';
import '../manager/contracts_cubit/maintenance_contracts_cubit.dart';
import '../manager/contracts_cubit/maintenance_contracts_state.dart';
import 'contract_formatters.dart';
import 'home_empty_contracts_widget.dart';

class HomeContractSection extends StatelessWidget {
  final VoidCallback? onOrderTap;
  final String? title;
  final String? badgeText;
  final String? description;
  final String? priceText;

  const HomeContractSection({
    super.key,
    this.onOrderTap,
    this.title,
    this.badgeText,
    this.description,
    this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic(context);

    return BlocBuilder<MaintenanceContractsCubit, MaintenanceContractsState>(
      builder: (context, state) {
        if (state is MaintenanceContractsLoading) {
          return _buildShimmer();
        }

        if (state is MaintenanceContractsSuccess &&
            state.contractsModel.data.isNotEmpty) {
          final contract = state.contractsModel.data.first;
          final localizedName = _localized(contract.name, isAr);
          final localizedDescription = _localized(contract.description, isAr);
          return _buildContract(
            context,
            isAr: isAr,
            title: title ?? (localizedName.isEmpty ? null : localizedName),
            description: description ??
                (localizedDescription.isEmpty ? null : localizedDescription),
            priceText: priceText ?? contractPriceText(contract),
            durationText: contractDurationText(contract.duration, isAr),
            imageUrl: contract.image,
          );
        }

        return HomeEmptyContractsWidget(
          onRefresh: () {
            context.read<MaintenanceContractsCubit>().refreshMaintenanceContracts();
          },
        );
      },
    );
  }

  String _localized(ContractLocalizedText text, bool isAr) {
    return (isAr ? text.ar : text.en).trim();
  }

  Widget _buildContract(
      BuildContext context, {
        required bool isAr,
        String? title,
        String? description,
        String? priceText,
        String? durationText,
        String? imageUrl,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeContractDarkGreen,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title ?? AppStrings.monthlyContract.tr(),
                        style: AppStyles.styleRegular14(context).copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.homeContractBadgeGreen,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        badgeText ?? AppStrings.newBadge.tr(),
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  description ?? AppStrings.contractDescription.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.styleRegular14(context).copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onOrderTap ??
                              () {
                            GoRouter.of(context).push(
                              AppRouter.allContractsView,
                            );
                          },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.homeHeaderGreen,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          AppStrings.orderContract.tr(),
                          style: AppStyles.styleRegular14(context).copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        _priceWithDuration(priceText, durationText),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.homeHeaderGreen,
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEBC2),
              borderRadius: BorderRadius.circular(18.r),
            ),
            padding: EdgeInsets.all(6.w),
            child: Center(
              child: _buildContractImage(imageUrl),
            ),
          ),
        ],
      ),
    );
  }

  String _priceWithDuration(String? priceText, String? durationText) {
    final price = priceText?.trim() ?? '';
    final duration = durationText?.trim() ?? '';
    if (price.isEmpty && duration.isEmpty) {
      return '';
    }
    if (duration.isEmpty) return price;
    if (price.isEmpty) return duration;
    return '$price / $duration';
  }

  Widget _buildContractImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        AppAssets.logo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.home_work_rounded,
            color: AppColors.homeContractDarkGreen,
            size: 34,
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.loadingEffectColor,
          highlightColor: Colors.grey.shade100,
          child: Container(color: Colors.white),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.home_work_rounded,
          color: AppColors.homeContractDarkGreen,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.loadingEffectColor,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 116.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
      ),
    );
  }
}
