import 'package:easy_localization/easy_localization.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/navigation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/state_management/user_cubit/user_cubit.dart';
import '../manager/register_cubit.dart';
import '../manager/register_state.dart';
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
            const SnackBar(
              content: Text('Registration Successful!'),
            ),
          );
          customPushReplacement(context, AppRouter.homePage);
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),

                          Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    size: 16,
                                    color: AppColors.titleDark,
                                  ),
                                  onPressed: () {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      customPushReplacement(context, AppRouter.loginView);
                                    }
                                  },
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  AppStrings.createAccount.tr(),
                                  style: AppStyles.styleRegular16(context).copyWith(
                                    color: AppColors.titleDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),


                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),
                          Text(
                            'أهلاً بيك في ELITE',
                            style: AppStyles.styleRegular16(context).copyWith(
                                color: AppColors.titleDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 22
                            ),
                            textAlign: TextAlign.right,
                          ),

                          SizedBox(height: 6.h),
                          Text(
                            'املى بياناتك وابدأ اطلب خدماتك',
                            style: AppStyles.styleRegular14(context).copyWith(
                              color: AppColors.subtitleGrey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 22.h),
                          const RegisterForm(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
