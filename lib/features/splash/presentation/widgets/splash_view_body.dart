import 'package:elite/core/constants/app_assets.dart';
import 'package:elite/core/constants/app_colors.dart' show AppColors;
import 'package:elite/core/databases/cache/app_data_manager.dart'
    show AppDataManager;
import 'package:elite/core/functions/navigation.dart';
import 'package:elite/core/routes/app_router.dart' show AppRouter;
import 'package:elite/core/services/service_locator.dart' show getIt;
import 'package:elite/core/state_management/user_cubit/user_cubit.dart'
    show UserCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();
    _checkUserStatusAndNavigate();
  }

  Future<void> _checkUserStatusAndNavigate() async {
    final userCubit = context.read<UserCubit>();
    final appDataManager = getIt<AppDataManager>();
    bool isSelectLanguageViewVisited =
        appDataManager.getIsSelectLanguageViewVisited() ?? false;
    await userCubit.checkGuestStatus();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      if (!isSelectLanguageViewVisited) {
        customGo(context, AppRouter.welcomeView);
      } else if (isSelectLanguageViewVisited) {
        customGo(context, AppRouter.loginView);
      } else {
        customGo(context, AppRouter.loginView);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.splashBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
               borderRadius: BorderRadiusGeometry.circular(50.r),
                child: Image.asset(
                  AppAssets.appLogo,
                  width: 300,
                  height: 300,
                ),

              ),
              SizedBox(height: 110.h,)
            ],
          ),
        ),
      ),
    );
  }
}