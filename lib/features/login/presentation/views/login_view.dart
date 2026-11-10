import 'package:easy_localization/easy_localization.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/floating_snack_bar.dart';
import '../../../../core/functions/navigation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/state_management/user_cubit/user_cubit.dart';
import '../../../../core/widgets/custom_auth_field.dart';
import '../manager/login_cubit.dart';
import '../manager/login_state.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LoginCubit>(),
      child: const _LoginViewBody(),
    );
  }
}

class _LoginViewBody extends StatefulWidget {
  const _LoginViewBody();

  @override
  State<_LoginViewBody> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginViewBody> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          context.read<UserCubit>().setGuestStatus(false);
          customGo(context, AppRouter.homePage);
        } else if (state is LoginFailureState) {
          floatingSnackBar(
            context,
            state.failedModel.errors?.values.first.first ??
                state.failedModel.message ??
                'Login failed',
            icon: Icons.error_outline,
            boxColor: Colors.red,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.welcomeBgColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 8.h),
                        Align(
                          alignment: AlignmentDirectional.topStart,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: AppColors.titleDark,
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                customPushReplacement(context, AppRouter.introView);
                              }
                            },
                          ),
                        ),

                        SizedBox(height: 12.h),
                        Center(
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAssets.appLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),
                        Text(
                          AppStrings.login.tr(),
                          style:AppStyles.styleRegular12(context).copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.titleDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'أهلاً بيك تاني! سجّل دخولك عشان تكمل',
                          style:AppStyles.styleRegular12(context).copyWith(
                              color: AppColors.subtitleGrey
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 24.h),

                        CustomAuthField(
                          label: 'رقم الموبايل',
                          hintText: '01012345678',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 11,
                          prefixWidget: Icon(Icons.phone),
                        ),

                        SizedBox(height: 16.h),
                        CustomAuthField(
                          label: 'كلمة السر',
                          hintText: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          prefixWidget: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(Icons.lock) ,

                          ),
                        ),

                        SizedBox(height: 10.h),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'نسيت كلمة السر؟',
                              style:AppStyles.styleRegular12(context).copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.subtitleGrey,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Primary Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            onPressed: state is LoginLoadingState
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              context.read<LoginCubit>().login(
                                phoneNumber: _phoneController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            },
                            child: state is LoginLoadingState
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                                : Text(
                              'تسجيل الدخول',
                              style: AppStyles.styleRegular16(context).copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),


                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    16.h,
                    20.w,
                    20.h + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        customPushReplacement(context, AppRouter.registerView);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'معندكش حساب ؟ أنشئ حساب جديد',
                        style:AppStyles.styleRegular12(context).copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.badgeTextGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
