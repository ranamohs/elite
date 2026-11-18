import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/widgets/fixit_app_bars.dart';
import 'package:elite/core/widgets/retry_widget.dart';
import 'package:elite/features/home/data/models/contracts_models/maintenance_contracts_model.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contracts_cubit.dart';
import 'package:elite/features/home/presentation/manager/contracts_cubit/maintenance_contracts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/maintenance_contract_card_item.dart';

class AllContractsView extends StatelessWidget {
  const AllContractsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic(context);

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: PrimaryAppBar(
        title: AppStrings.allContracts.tr(),
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: BlocBuilder<MaintenanceContractsCubit, MaintenanceContractsState>(
          builder: (context, state) {
            if (state is MaintenanceContractsLoading) {
              return _buildLoadingShimmer();
            }

            if (state is MaintenanceContractsFailure) {
              return Center(
                child: RetryWidget(
                  message: state.failure.errMessage,
                  onPressed: () {
                    context
                        .read<MaintenanceContractsCubit>()
                        .refreshMaintenanceContracts();
                  },
                ),
              );
            }

            List<MaintenanceContract> contracts = [];
            if (state is MaintenanceContractsSuccess) {
              contracts = state.contractsModel.data;
            }

            if (contracts.isEmpty) {
              return RefreshIndicator(
                color: AppColors.homeHeaderGreen,
                onRefresh: () async {
                  await context
                      .read<MaintenanceContractsCubit>()
                      .refreshMaintenanceContracts();
                },
                child: _buildEmptyState(context, isAr),
              );
            }

            return RefreshIndicator(
              color: AppColors.homeHeaderGreen,
              onRefresh: () async {
                await context
                    .read<MaintenanceContractsCubit>()
                    .refreshMaintenanceContracts();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                itemCount: contracts.length,
                itemBuilder: (context, index) {
                  return MaintenanceContractCardItem(
                    contract: contracts[index],
                    isArabic: isAr,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          height: 250.h,
          child: Shimmer.fromColors(
            baseColor: AppColors.loadingEffectColor,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isAr) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 80.h),
      children: [
        Center(
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.homeHeaderGreen.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: 30.sp,
                color: AppColors.homeHeaderGreen,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          AppStrings.noContractsAvailable.tr(),
          textAlign: TextAlign.center,
          style: AppStyles.styleRegular14(context).copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.titleDark,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          AppStrings.contractsComingSoon.tr(),
          textAlign: TextAlign.center,
          style: AppStyles.styleRegular14(context).copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.subtitleGrey,
          ),
        ),
      ],
    );
  }
}
