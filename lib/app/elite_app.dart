import 'package:elite/core/constants/app_colors.dart' show AppColors;
import 'package:elite/core/routes/app_router.dart' show AppRouter;
import 'package:elite/core/services/service_locator.dart' show getIt;
import 'package:elite/core/state_management/bottom_navigation_bar_cubit/bottom_navigation_bar_cubit.dart' show BottomNavigationBarCubit;
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart' show NetworkConnectionCubit;
import 'package:elite/core/state_management/user_cubit/user_cubit.dart' show UserCubit;
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, MultiBlocProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../features/home/presentation/manager/banners_cubit/banners_cubit.dart';

class EliteApp extends StatelessWidget {
  const EliteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<UserCubit>(
              create: (_) => UserCubit()..checkGuestStatus(),
            ),

            BlocProvider<NetworkConnectionCubit>(
              create: (_) => getIt<NetworkConnectionCubit>(),
            ),
            BlocProvider<BottomNavigationBarCubit>(
              create: (_) => BottomNavigationBarCubit(),
            ),
            BlocProvider<BannersCubit>(
              create: (_) => getIt<BannersCubit>()..getBanners(),
            ),
            BlocProvider<CategoriesCubit>(
              create: (_) => getIt<CategoriesCubit>()..getCategories(),
            ),


          ],
          child: MaterialApp.router(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: AppColors.primaryColor.withAlpha(40),
                selectionHandleColor: AppColors.primaryColor,
                cursorColor: AppColors.primaryColor,
              ),
              progressIndicatorTheme: ProgressIndicatorThemeData(
                color: AppColors.primaryColor,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.pureWhiteColor,
              ),
              scaffoldBackgroundColor: AppColors.pureWhiteColor,
            ),
          ),
        );
      },
    );
  }
}