import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/core/widgets/back_icon_button.dart';
import 'package:elite/core/widgets/retry_widget.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contract_details_cubit.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contract_details_state.dart';
import 'package:elite/features/home/presentation/widgets/contract_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ContractDetailsView extends StatefulWidget {
  final int contractId;

  const ContractDetailsView({super.key, required this.contractId});

  @override
  State<ContractDetailsView> createState() => _ContractDetailsViewState();
}

class _ContractDetailsViewState extends State<ContractDetailsView> {
  late final MaintenanceContractDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<MaintenanceContractDetailsCubit>()
      ..getMaintenanceContractDetails(widget.contractId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic(context);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: BlocBuilder<MaintenanceContractDetailsCubit,
            MaintenanceContractDetailsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is MaintenanceContractDetailsLoading) {
              return _buildLoading();
            }

            if (state is MaintenanceContractDetailsFailure) {
              return SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(title: AppStrings.contractDetails.tr()),
                    Expanded(
                      child: RetryWidget(
                        message: state.failure.errMessage,
                        onPressed: () => _cubit.getMaintenanceContractDetails(
                          widget.contractId,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is MaintenanceContractDetailsSuccess) {
              return _buildContent(context, state.detailsModel.data, isAr);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      MaintenanceContract contract,
      bool isAr,
      ) {
    final title = _localized(contract.name, isAr);
    final description = _localized(contract.description, isAr);
    final priceText = contractPriceText(contract);
    final durationText = contractDurationText(contract.duration, isAr);
    final features = contract.features
        .map((feature) => _localized(feature, isAr))
        .where((feature) => feature.trim().isNotEmpty)
        .toList();

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 240.h,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.homeContractDarkGreen,
              leading: const BackIconButton(iconColor: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHero(contract.image, title),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitleCard(
                      context,
                      title: title,
                      priceText: priceText,
                      durationText: durationText,
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 14.h),
                      _buildSection(
                        context,
                        title: AppStrings.aboutThisContract.tr(),
                        icon: Icons.info_outline_rounded,
                        child: Text(
                          description,
                          style: AppStyles.styleRegular14(context).copyWith(
                            fontSize: 12.5.sp,
                            height: 1.7,
                            color: AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    _buildSection(
                      context,
                      title: AppStrings.contractFeatures.tr(),
                      icon: Icons.verified_outlined,
                      child: features.isEmpty
                          ? Text(
                        AppStrings.noFeaturesAvailable.tr(),
                        style:
                        AppStyles.styleRegular14(context).copyWith(
                          fontSize: 12.5.sp,
                          color: AppColors.subtitleGrey,
                        ),
                      )
                          : Column(
                        children: features
                            .map((feature) => _buildFeatureRow(
                          context,
                          feature,
                        ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildHero(String? imageUrl, String title) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildHeroImage(imageUrl),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.homeContractDarkGreen.withValues(alpha: 0.15),
                AppColors.homeContractDarkGreen.withValues(alpha: 0.55),
                AppColors.homeContractDarkGreen.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.homeContractBadgeGreen,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  AppStrings.newBadge.tr(),
                  style:AppStyles.styleRegular14(context).copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.styleMedium16(context).copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFDCEBC2),
        child: Center(
          child: Icon(
            Icons.home_work_rounded,
            size: 56.sp,
            color: AppColors.homeContractDarkGreen,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.loadingEffectColor,
        highlightColor: Colors.grey.shade100,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFDCEBC2),
        child: Center(
          child: Icon(
            Icons.home_work_rounded,
            size: 56.sp,
            color: AppColors.homeContractDarkGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleCard(
      BuildContext context, {
        required String title,
        required String priceText,
        required String durationText,
      }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoTile(
              context,
              icon: Icons.payments_outlined,
              label: AppStrings.contractPriceLabel.tr(),
              value: priceText.isEmpty ? '-' : priceText,
              valueColor: AppColors.homeContractBadgeGreen,
            ),
          ),
          Container(
            width: 1,
            height: 42.h,
            color: const Color(0xFFEDEFF2),
          ),
          Expanded(
            child: _buildInfoTile(
              context,
              icon: Icons.schedule_rounded,
              label: AppStrings.contractDurationLabel.tr(),
              value: durationText.isEmpty ? '-' : durationText,
              valueColor: AppColors.titleDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color valueColor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15.sp, color: AppColors.homeHeaderGreen),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.styleRegular14(context).copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtitleGrey,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppStyles.styleMedium16(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget child,
      }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.homeHeaderGreen.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16.sp,
                    color: AppColors.homeHeaderGreen,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: AppStyles.styleMedium16(context).copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.titleDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F8E9),
            ),
            child: Center(
              child: Icon(
                Icons.check_rounded,
                size: 13.sp,
                color: AppColors.homeContractBadgeGreen,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              feature,
              style: AppStyles.styleRegular14(context).copyWith(
                fontSize: 12.5.sp,
                height: 1.5,
                color: AppColors.titleDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16.w,
          12.h,
          16.w,
          12.h + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.orderContract.tr())),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.homeHeaderGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              AppStrings.orderNow.tr(),
              style: AppStyles.styleMedium16(context).copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      child: Row(
        children: [
          const BackIconButton(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Shimmer.fromColors(
        baseColor: AppColors.loadingEffectColor,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 240.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 160.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localized(ContractLocalizedText text, bool isAr) {
    return (isAr ? text.ar : text.en).trim();
  }
}