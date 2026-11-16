import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import 'checkout_widgets.dart';
import 'schedule_picker_tile.dart';

class ScheduleSelector extends StatelessWidget {
  final DateTime? selectedDay;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<TimeOfDay> onTime;
  const ScheduleSelector({
    super.key,
    this.selectedDay,
    this.selectedTime,
    required this.onDay,
    required this.onTime,
  });

  Widget pickerTheme(BuildContext context, Widget? child) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
      ),
    ),
    child: child!,
  );

  Future<DateTime?> pickDate(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastDay = DateTime(today.year + 1, today.month, today.day);
    var initial = selectedDay == null
        ? today
        : DateUtils.dateOnly(selectedDay!);
    if (initial.isBefore(today)) initial = today;
    if (initial.isAfter(lastDay)) initial = lastDay;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: lastDay,
      builder: pickerTheme,
      helpText: checkoutText(
        context,
        'اختاري تاريخ الزيارة',
        'Select visit date',
      ),
    );
    if (!context.mounted) return null;
    if (picked != null) onDay(picked);
    return picked;
  }

  Future<void> pickTime(BuildContext context) async {
    final day = selectedDay ?? await pickDate(context);
    if (!context.mounted || day == null) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: pickerTheme,
      helpText: checkoutText(
        context,
        'اختاري وقت الزيارة',
        'Select visit time',
      ),
    );
    if (!context.mounted || picked == null) return;
    final appointment = DateTime(
      day.year,
      day.month,
      day.day,
      picked.hour,
      picked.minute,
    );
    if (!appointment.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            checkoutText(
              context,
              'اختاري وقت لسه مجاش',
              'Please choose a time in the future',
            ),
          ),
        ),
      );
      return;
    }
    onTime(picked);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CheckoutSectionTitle(
        checkoutText(context, 'تاريخ ووقت الزيارة', 'Visit date and time'),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SchedulePickerTile(
              icon: Icons.calendar_month_outlined,
              label: selectedDay == null
                  ? checkoutText(context, 'اختاري التاريخ', 'Select date')
                  : DateFormat(
                'yyyy/MM/dd',
                isArabic(context) ? 'ar' : 'en',
              ).format(selectedDay!),
              selected: selectedDay != null,
              onTap: () => pickDate(context),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SchedulePickerTile(
              icon: Icons.access_time_rounded,
              label:
              selectedTime?.format(context) ??
                  checkoutText(context, 'اختاري الوقت', 'Select time'),
              selected: selectedTime != null,
              onTap: () => pickTime(context),
            ),
          ),
        ],
      ),
    ],
  );
}
