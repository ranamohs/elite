import 'package:easy_localization/easy_localization.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/internet_connection_status_snack_bar.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_state.dart';
import '../manager/banners_cubit/banners_cubit.dart';
import '../manager/categories_cubit/categories_cubit.dart';
import '../manager/contracts_cubit/maintenance_contracts_cubit.dart';

import '../widgets/home_banners_section.dart';
import '../widgets/home_contract_section.dart';
import '../widgets/home_header_section.dart';
import '../widgets/home_categories_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: BlocListener<NetworkConnectionCubit, NetworkConnectionState>(
        listener: (context, state) {
          try {
            if (state is NetworkConnected) {
              internetConnectionStatusSnackBar(context, isConnected: true);
            } else if (state is NetworkDisconnected) {
              internetConnectionStatusSnackBar(context, isConnected: false);
            }
          } catch (_) {}
        },
        child: RefreshIndicator(
          color: AppColors.homeHeaderGreen,
          onRefresh: () async {
            context.read<BannersCubit>().getBanners();
            context.read<CategoriesCubit>().refreshCategories();
            context.read<MaintenanceContractsCubit>()
                .refreshMaintenanceContracts();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeHeaderSection(),
                SizedBox(height: 16.h),
                const HomeBannersSection(),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: const HomeCategoriesSection(),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "عقود الصيانة",
                        style: AppStyles.styleMedium18(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.titleDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          GoRouter.of(context).push(AppRouter.allContractsView);
                        },
                        child: Text(
                          'كل العقود ',
                          style: AppStyles.styleMedium18(context).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.homeContractBadgeGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: const HomeContractSection(),
                ),
                SizedBox(height: 28.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
