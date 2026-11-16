import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/order_draft.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/payment_method_selector.dart';
import 'order_completed_view.dart';

class OrderInvoiceView extends StatefulWidget {
  final OrderDraft order;
  const OrderInvoiceView({super.key, required this.order});
  @override
  State<OrderInvoiceView> createState() => _OrderInvoiceViewState();
}

class _OrderInvoiceViewState extends State<OrderInvoiceView> {
  void objection() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          checkoutText(context, 'اعتراض على الفاتورة', 'Invoice objection'),
        ),
        content: Text(
          checkoutText(
            context,
            'إرسال الاعتراض هيتاح لما خدمة الطلبات تجهز. مفيش فاتورة فعلية اتصدرت في المعاينة دي.',
            'Objections will be available when order services are connected. This preview has not issued a real invoice.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(checkoutText(context, 'تمام', 'OK')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CheckoutScaffold(
    title: checkoutText(context, 'معاينة الفاتورة', 'Invoice preview'),
    action: checkoutText(
      context,
      'تأكيد الدفع · ${widget.order.money(widget.order.subtotal)}',
      'Confirm payment · ${widget.order.money(widget.order.subtotal)}',
    ),
    onAction: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderCompletedView(order: widget.order),
      ),
    ),
    footer: TextButton(
      onPressed: objection,
      child: Text(
        checkoutText(
          context,
          'عندك اعتراض على الفاتورة؟',
          'Have an invoice objection?',
        ),
        style: const TextStyle(color: Colors.deepOrange),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              checkoutText(
                context,
                widget.order.orderId == null
                    ? 'طلب تجريبي • الفني لم يُحدد'
                    : 'طلب #${widget.order.orderId} • الفني لم يُحدد',
                widget.order.orderId == null
                    ? 'Preview order • No technician assigned'
                    : 'Order #${widget.order.orderId} • No technician assigned',
              ),
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
            const Icon(Icons.receipt_long_outlined, color: Colors.amber),
          ],
        ),
        SizedBox(height: 12.h),
        OrderPriceCard(
          order: widget.order,
          title: checkoutText(context, 'اللي اتنفذ', 'Work performed'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Text(
            checkoutText(
              context,
              'البنود المعروضة من اختياراتك؛ بيانات التنفيذ الفعلية هتظهر بعد ربط الخدمة.',
              'Items are based on your selections. Actual completed work will appear once connected.',
            ),
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
          ),
        ),
        CheckoutSectionTitle(
          checkoutText(context, 'طريقة الدفع', 'Payment method'),
        ),
        PaymentMethodSelector(
          selected: widget.order.paymentMethod,
          onChanged: (value) =>
              setState(() => widget.order.paymentMethod = value),
        ),
        SizedBox(height: 16.h),
        CheckoutNotice(
          title: checkoutText(context, 'دفع تجريبي', 'Payment preview'),
          message: checkoutText(
            context,
            'الزر بيفتح شاشة الإنجاز فقط، ومش بيخصم أي مبلغ أو يسجل دفع.',
            'This button opens the completion screen only. No money is charged and no payment is recorded.',
          ),
        ),
      ],
    ),
  );
}
