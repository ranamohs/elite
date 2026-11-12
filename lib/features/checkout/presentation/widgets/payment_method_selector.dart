import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_widgets.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final methods = {
      'cash': checkoutText(context, 'كاش للفني', 'Cash to technician'),
      'card': checkoutText(context, 'بطاقة بنكية', 'Bank card'),
      'wallet': checkoutText(context, 'محفظة إلكترونية', 'Electronic wallet'),
    };
    return CheckoutCard(
      child: Column(
        children: methods.entries
            .map(
              (entry) => InkWell(
            onTap: () => onChanged(entry.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    selected == entry.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected == entry.key
                        ? AppColors.primaryColor
                        : AppColors.unselectedRadioBorder,
                  ),
                  const SizedBox(width: 10),
                  Text(entry.value),
                ],
              ),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}
