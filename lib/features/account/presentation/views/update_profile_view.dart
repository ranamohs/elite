import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/databases/cache/cache_helper.dart';
import '../../../../core/databases/cache/user_data_manager.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../manager/update_profile_cubit/update_profile_cubit.dart';
import '../manager/update_profile_cubit/update_profile_state.dart';
import '../widgets/account_ui.dart';
import '../widgets/profile_photo_picker.dart';

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});
  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final form = GlobalKey<FormState>();
  final user = getIt<UserDataManager>();
  late final UpdateProfileCubit cubit;
  late final TextEditingController name, phone, email;
  File? avatar;
  DateTime? birthDate;
  String get birthKey =>
      'profile_birthdate:${user.getUserId() ?? user.getUserEmail() ?? user.getUserPhoneNumber() ?? 'guest'}';
  @override
  void initState() {
    super.initState();
    cubit = getIt<UpdateProfileCubit>();
    name = TextEditingController(text: user.getUserName() ?? '');
    phone = TextEditingController(text: user.getUserPhoneNumber() ?? '');
    email = TextEditingController(text: user.getUserEmail() ?? '');
    birthDate = DateTime.tryParse(
      getIt<CacheHelper>().getDataString(key: birthKey) ?? '',
    );
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    cubit.close();
    super.dispose();
  }

  Future<void> pickBirthDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial =
    birthDate != null &&
        !birthDate!.isAfter(today) &&
        birthDate!.year >= 1900
        ? birthDate!
        : today;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (mounted && result != null) setState(() => birthDate = result);
  }

  Widget field(
      String label,
      TextEditingController controller,
      TextInputType keyboard,
      ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: 8.h, top: 14.h),
        child: Text(label, style: TextStyle(fontSize: 12.sp)),
      ),
      TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return accountText(
              context,
              'هذا الحقل مطلوب',
              'This field is required',
            );
          }
          if (keyboard == TextInputType.emailAddress &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
            return accountText(
              context,
              'اكتبي بريد إلكتروني صحيح',
              'Enter a valid email address',
            );
          }
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.unselectedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.unselectedBorder),
          ),
        ),
      ),
    ],
  );
  @override
  Widget build(
      BuildContext context,
      ) => BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
    bloc: cubit,
    listener: (context, state) async {
      if (state is UpdateProfileSuccess) {
        if (birthDate != null) {
          try {
            final saved = await getIt<CacheHelper>().saveData(
              key: birthKey,
              value: birthDate!.toIso8601String(),
            );
            if (!saved) throw StateError('Birth date was not stored');
          } catch (_) {
            if (context.mounted) {
              accountInfo(
                context,
                'تم تحديث حسابك، لكن تعذر حفظ تاريخ الميلاد على الجهاز',
                'Profile updated, but the birth date could not be saved on this device',
              );
            }
          }
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic(context)
                  ? state.success.message.ar
                  : state.success.message.en,
            ),
          ),
        );
        if (Navigator.of(context).canPop()) Navigator.of(context).pop(true);
      } else if (state is UpdateProfileFailure) {
        final errors = state.failure.errors?.fieldErrors;
        final messages = errors?.values.expand((e) => e).toList() ?? [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              messages.isNotEmpty
                  ? messages.first
                  : isArabic(context)
                  ? state.failure.message.ar
                  : state.failure.message.en,
            ),
          ),
        );
      }
    },
    builder: (context, state) => PopScope(
      canPop: state is! UpdateProfileLoading,
      child: AccountScaffold(
        title: accountText(context, 'البيانات الشخصية', 'Personal information'),
        bottomBar: AccountSaveBar(
          label: accountText(context, 'حفظ التعديلات', 'Save changes'),
          loading: state is UpdateProfileLoading,
          onPressed: () {
            if (form.currentState!.validate()) {
              cubit.updateProfile(
                name: name.text.trim(),
                phoneNumber: phone.text.trim(),
                email: email.text.trim(),
                avatar: avatar,
              );
            }
          },
        ),
        body: AbsorbPointer(
          absorbing: state is UpdateProfileLoading,
          child: Form(
            key: form,
            child: ListView(
              padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 24.h),
              children: [
                ProfilePhotoPicker(
                  avatarUrl: user.getUserAvatarUrl(),
                  onChanged: (value) => avatar = value,
                ),
                field(
                  accountText(context, 'الاسم بالكامل', 'Full name'),
                  name,
                  TextInputType.name,
                ),
                field(
                  accountText(context, 'رقم الموبايل', 'Phone number'),
                  phone,
                  TextInputType.phone,
                ),
                field(
                  accountText(context, 'البريد الإلكتروني', 'Email'),
                  email,
                  TextInputType.emailAddress,
                ),

              ],
            ),
          ),
        ),
      ),
    ),
  );
}
