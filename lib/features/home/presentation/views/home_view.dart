import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/internet_connection_status_snack_bar.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_cubit.dart';
import '../../../../core/state_management/network_connection_cubit/network_connection_state.dart';
import '../manager/banners_cubit/banners_cubit.dart';
import '../manager/categories_cubit/categories_cubit.dart';
import '../manager/recent_shops_cubit/recent_shops_cubit.dart';

import '../widgets/home_banners_section.dart';
import '../widgets/home_contract_section.dart';
import '../widgets/home_header_section.dart';
import '../widgets/home_services_section.dart';

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
            context.read<RcenetShopsCubit>().refreshRcenetShops();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Curved Green Top Header (Avatar, Greeting, Location, Notifications, Search Bar)
                const HomeHeaderSection(),

                SizedBox(height: 16.h),

                // 2. Promotional Banners Carousel with Indicator Dots
                const HomeBannersSection(),

                SizedBox(height: 20.h),

                // 3. Services Section with Title, Link, and 3x2 Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: const HomeServicesSection(),
                ),

                SizedBox(height: 20.h),

                // 4. Monthly Maintenance Contract Card
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
