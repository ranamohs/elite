import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/functions/is_arabic.dart';
import '../manager/service/service_request_cubit.dart';
import '../manager/service/service_request_state.dart';
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
  late final ServiceRequestCubit requestCubit;
  @override
  void initState() {
    super.initState();
    requestCubit = getIt<ServiceRequestCubit>();
  }

  @override
  void dispose() {
    requestCubit.close();
    super.dispose();
  }

  void openInvoicePreview() => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => OrderInvoiceView(order: widget.order)),
  );

  @override
  Widget build(
      BuildContext context,
      ) => BlocConsumer<ServiceRequestCubit, ServiceRequestState>(
    bloc: requestCubit,
    listener: (context, state) {
      if (state is ServiceRequestSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${state.model.localizedMessage(isArabic(context))} #${state.model.orderId}',
            ),
          ),
        );
        openInvoicePreview();
      } else if (state is ServiceRequestFailure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.failure.errMessage)));
      }
    },
    builder: (context, state) => PopScope(
      canPop: state is! ServiceRequestLoading,
      child: CheckoutScaffold(
        title: checkoutText(
          context,
          'الموعد وتأكيد الطلب',
          'Schedule and confirm',
        ),
        action: state is ServiceRequestLoading
            ? checkoutText(context, 'جاري إرسال الطلب…', 'Submitting…')
            : widget.order.orderId != null
            ? checkoutText(
          context,
          'عرض الطلب #${widget.order.orderId}',
          'View order #${widget.order.orderId}',
        )
            : checkoutText(context, 'تأكيد الطلب', 'Confirm order'),
        onAction:
        state is ServiceRequestLoading || widget.order.appointment == null
            ? null
            : () {
          if (widget.order.orderId != null ||
              !widget.order.items.any((item) => !item.isProduct)) {
            openInvoicePreview();
          } else {
            requestCubit.submit(widget.order);
          }
        },
        body: AbsorbPointer(
          absorbing:
          state is ServiceRequestLoading || widget.order.orderId != null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScheduleSelector(
                selectedDay: widget.order.day,
                selectedTime: widget.order.timeMinutes == null
                    ? null
                    : TimeOfDay(
                  hour: widget.order.timeMinutes! ~/ 60,
                  minute: widget.order.timeMinutes! % 60,
                ),
                onDay: (day) => setState(() {
                  widget.order.day = day;
                  final appointment = widget.order.appointment;
                  if (appointment != null &&
                      !appointment.isAfter(DateTime.now())) {
                    widget.order.timeMinutes = null;
                  }
                }),
                onTime: (time) => setState(
                      () => widget.order.timeMinutes = time.hour * 60 + time.minute,
                ),
              ),
              SizedBox(height: 14.h),
              OrderPriceCard(
                order: widget.order,
                title: checkoutText(
                  context,
                  'السعر المبدئي',
                  'Estimated price',
                ),
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

            ],
          ),
        ),
      ),
    ),
  );
}
