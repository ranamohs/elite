import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/navigation.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/custom_auth_field.dart';
import '../../data/models/register_data_model.dart';
import '../manager/register_cubit.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name
          CustomAuthField(
            label: 'الاسم بالكامل',
            hintText: 'أحمد علي',
            controller: _nameController,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الاسم';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          CustomAuthField(
            label: 'رقم الموبايل',
            hintText: '01012345678',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الموبايل';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Email (Optional)
          CustomAuthField(
            label: 'البريد الإلكتروني (اختياري)',
            hintText: 'name@email.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 16.h),

          // Password
          CustomAuthField(
            label: 'كلمة السر',
            hintText: '••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            prefixWidget: GestureDetector(
              onTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Text(
                  _obscurePassword ? 'إظهار' : 'إخفاء',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة السر';
              }
              if (value.length < 6) {
                return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
              }
              return null;
            },
          ),

          SizedBox(height: 14.h),

          // Terms Checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                _agreeToTerms = !_agreeToTerms;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'موافق على الشروط والأحكام وسياسة الخصوصية',
                    style: AppStyles.styleRegular12(context).copyWith(
                      color: AppColors.subtitleGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: _agreeToTerms ? AppColors.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: _agreeToTerms ? AppColors.primaryColor : AppColors.unselectedRadioBorder,
                      width: 1.6,
                    ),
                  ),
                  child: _agreeToTerms
                      ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                      : null,
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          // Bottom card container with "إنشاء الحساب" button and "عندك حساب؟ سجّل دخول"
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Submit Button
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (!_agreeToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى الموافقة على الشروط والأحكام'),
                            ),
                          );
                          return;
                        }
                        FocusScope.of(context).unfocus();

                        final registerData = RegisterDataModel(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phoneNumber: _phoneController.text.trim(),
                          password: _passwordController.text.trim(),
                          confirmPassword: _passwordController.text.trim(),
                        );

                        context.read<RegisterCubit>().register(registerData);
                      }
                    },
                    child: Text(
                      'إنشاء الحساب',
                      style: AppStyles.styleRegular16(context).copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () {
                    customPushReplacement(context, AppRouter.loginView);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      'عندك حساب؟ سجّل دخول',
                      style: AppStyles.styleRegular16(context).copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.badgeTextGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
