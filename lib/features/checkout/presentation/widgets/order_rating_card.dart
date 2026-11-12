import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'checkout_widgets.dart';

class OrderRatingCard extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  const OrderRatingCard({
    super.key,
    required this.rating,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => CheckoutCard(
    child: Column(
      children: [
        Text(
          checkoutText(context, 'قيّم الخدمة', 'Rate the service'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
                  (i) => Flexible(
                child: IconButton(
                  onPressed: () => onChanged(i + 1),
                  tooltip: '${i + 1}',
                  icon: Icon(
                    Icons.star,
                    color: i < rating ? Colors.orange : const Color(0xFFD2D6DD),
                    size: 30.sp,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
