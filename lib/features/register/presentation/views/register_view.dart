import 'package:elite/core/constants/app_strings.dart' show AppStrings;
import 'package:elite/core/constants/app_styles.dart';
import 'package:elite/core/constants/app_assets.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/functions/navigation.dart';
import 'package:elite/core/routes/app_router.dart';
import 'package:elite/core/state_management/user_cubit/user_cubit.dart';
import 'package:elite/core/widgets/spacing.dart' show VerticalSpace;
import 'package:elite/features/register/presentation/manager/register_cubit.dart';
import 'package:elite/features/register/presentation/manager/register_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../widgets/register_form.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccessState) {
          context.read<UserCubit>().setGuestStatus(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration Successful!'),
            ),
          );
          customPush(context, AppRouter.homePage);
        } else if (state is RegisterFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failedModel.message ?? 'Registration Failed!'),
            ),
          );
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is RegisterLoadingState,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: const Color(0xFFFAF4EF),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.white,
                    AppColors.splashBackgroundStart,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:  EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       SizedBox(height: 40.h),
                      // Logo
                      Center(
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: 109.w,
                          height: 109.h,
                        ),
                      ),
                       SizedBox(height: 10.h),
                      // Title
                      Text(
                        AppStrings.createAccount.tr(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       SizedBox(height: 8.h),
                      Text(
                        AppStrings.fillFormToProceed.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                       SizedBox(height: 32.h),
                      RegisterForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


