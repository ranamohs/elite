import 'package:flutter/material.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import 'technical_form_field.dart';

class TechnicalPersonalStep extends StatelessWidget {
  final Map<String, TextEditingController> fields;
  const TechnicalPersonalStep({super.key, required this.fields});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      TechnicalFormField(
        label: accountText(context, 'الاسم بالكامل', 'Full name'),
        controller: fields['name']!,
        keyboard: TextInputType.name,
        validator: (v) => v == null || v.trim().isEmpty || v.trim().length > 255
            ? accountText(
          context,
          'اكتبي اسم صحيح بحد أقصى 255 حرف',
          'Enter your name, up to 255 characters',
        )
            : null,
      ),
      TechnicalFormField(
        label: accountText(context, 'رقم الموبايل', 'Phone number'),
        controller: fields['phone']!,
        keyboard: TextInputType.phone,
      ),
      TechnicalFormField(
        label: accountText(context, 'البريد الإلكتروني', 'Email'),
        controller: fields['email']!,
        keyboard: TextInputType.emailAddress,
        validator: (v) =>
        v == null ||
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
            ? accountText(
          context,
          'اكتبي بريد إلكتروني صحيح',
          'Enter a valid email address',
        )
            : null,
      ),
      TechnicalFormField(
        label: accountText(context, 'كلمة السر', 'Password'),
        controller: fields['password']!,
        password: true,
        validator: (v) => v == null || v.isEmpty
            ? accountText(context, 'كلمة السر مطلوبة', 'Password is required')
            : null,
      ),
      TechnicalFormField(
        label: accountText(context, 'تأكيد كلمة السر', 'Confirm password'),
        controller: fields['password_confirmation']!,
        password: true,
        validator: (v) =>
        v == null || v.isEmpty || v != fields['password']!.text
            ? accountText(
          context,
          'كلمة السر غير متطابقة',
          'Passwords do not match',
        )
            : null,
      ),
      TechnicalFormField(
        label: accountText(context, 'الرقم القومي', 'National ID'),
        controller: fields['national_id']!,
        keyboard: TextInputType.number,
      ),
      TechnicalFormField(
        label: accountText(context, 'المحافظة / المدينة', 'Governorate / city'),
        controller: fields['city']!,
      ),
      TechnicalFormField(
        label: accountText(
          context,
          'الخبرة وسنين الشغل',
          'Experience and years of work',
        ),
        controller: fields['experience']!,
        maxLines: 3,
      ),
    ],
  );
}
