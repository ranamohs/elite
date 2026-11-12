import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/order_draft.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/schedule_selector.dart';
import 'order_invoice_view.dart';

class OrderScheduleView extends StatefulWidget {
  final OrderDraft order;
  const OrderScheduleView({super.key, required this.order});
  @override
  State<OrderScheduleView> createState() => _OrderScheduleViewState();
}

class _OrderScheduleViewState extends State<OrderScheduleView> {
  late final List<DateTime> days;
  @override
  void initState() {
    super.initState();
    // Start tomorrow so every displayed time slot is still in the future.
    final now = DateTime.now();
    days = List.generate(
      4,
          (i) => DateTime(now.year, now.month, now.day + i + 1),
    );
  }

  @override
  Widget build(BuildContext context) => CheckoutScaffold(
    title: checkoutText(context, 'الموعد وتأكيد الطلب', 'Schedule and confirm'),
    action: checkoutText(context, 'تأكيد الطلب', 'Confirm order'),
    onAction: widget.order.day == null || widget.order.timeSlot == null
        ? null
        : () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderInvoiceView(order: widget.order),
        ),
      );
    },
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleSelector(
          days: days,
          selectedDay: widget.order.day,
          selectedSlot: widget.order.timeSlot,
          onDay: (day) => setState(() => widget.order.day = day),
          onSlot: (slot) => setState(() => widget.order.timeSlot = slot),
        ),
        SizedBox(height: 14.h),
        OrderPriceCard(
          order: widget.order,
          title: checkoutText(context, 'السعر المبدئي', 'Estimated price'),
        ),
        SizedBox(height: 12.h),
        CheckoutNotice(
          title: checkoutText(
            context,
            'الدفع بيكون بعد التنفيذ',
            'Pay after the work is completed',
          ),
          message: checkoutText(
            context,
            'الفاتورة النهائية هتوضح الأعمال والخامات بعد التنفيذ. أي أعمال إضافية تحتاج موافقتك.',
            'The final invoice lists work and materials after completion. Additional work requires your approval.',
          ),
        ),
        SizedBox(height: 12.h),
        CheckoutNotice(
          title: checkoutText(context, 'معاينة مؤقتة', 'Temporary preview'),
          message: checkoutText(
            context,
            'تأكيد الطلب هنا بيفتح نموذج الفاتورة فقط. الطلب مش هيتبعت، والمواعيد تجريبية، ورسوم الزيارة لسه غير محددة.',
            'Confirmation opens an invoice preview only. No order is submitted. Time slots are samples and the visit fee is not configured yet.',
          ),
        ),
      ],
    ),
  );
}
