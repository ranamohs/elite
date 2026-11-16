import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/account_ui.dart';

class AccountPaymentMethodsView extends StatelessWidget {
  const AccountPaymentMethodsView({super.key});
  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'طرق الدفع', 'Payment methods'),
    body: ListView(
      padding: EdgeInsets.all(18.w),
      children: [
        AccountCard(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text(accountText(context, 'الدفع النقدي', 'Cash')),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.credit_card_outlined),
                title: Text(accountText(context, 'بطاقة بنكية', 'Bank card')),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(
                  accountText(context, 'محفظة إلكترونية', 'Electronic wallet'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          accountText(
            context,
            'اختيار وسيلة الدفع بيتم عند تأكيد الطلب. إضافة وحفظ بطاقات الدفع مش متاحين حاليًا.',
            'Choose your payment method during checkout. Adding and storing payment cards is not available yet.',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
