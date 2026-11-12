import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import 'checkout_widgets.dart';

class ScheduleSelector extends StatelessWidget {
  final List<DateTime> days;
  final DateTime? selectedDay;
  final int? selectedSlot;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<int> onSlot;
  const ScheduleSelector({
    super.key,
    required this.days,
    this.selectedDay,
    this.selectedSlot,
    required this.onDay,
    required this.onSlot,
  });
  @override
  Widget build(BuildContext context) {
    final slots = [
      checkoutText(context, '١٠ – ١٢ ص', '10 AM – 12 PM'),
      checkoutText(context, '١٢ – ٢ م', '12 PM – 2 PM'),
      checkoutText(context, '٢ – ٤ م', '2 PM – 4 PM'),
      checkoutText(context, '٤ – ٦ م', '4 PM – 6 PM'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutSectionTitle(
          checkoutText(context, 'اختار اليوم', 'Choose a day'),
        ),
        Row(
          children: days.map((day) {
            final selected = selectedDay == day;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: InkWell(
                  onTap: () => onDay(day),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(13.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryColor
                            : AppColors.unselectedBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat.EEEE(
                            isArabic(context) ? 'ar' : 'en',
                          ).format(day),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.subtitleGrey,
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.titleDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        CheckoutSectionTitle(
          checkoutText(context, 'اختار الفترة', 'Choose a time'),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 48.h,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
          ),
          itemBuilder: (_, i) => OutlinedButton(
            onPressed: () => onSlot(i),
            style: OutlinedButton.styleFrom(
              backgroundColor: selectedSlot == i
                  ? AppColors.primaryColor
                  : Colors.white,
              foregroundColor: selectedSlot == i
                  ? Colors.white
                  : AppColors.titleDark,
              side: BorderSide(
                color: selectedSlot == i
                    ? AppColors.primaryColor
                    : AppColors.unselectedBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(slots[i]),
          ),
        ),
      ],
    );
  }
}
