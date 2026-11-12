import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_draft.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/order_rating_card.dart';

class OrderCompletedView extends StatefulWidget {
  final OrderDraft order;
  const OrderCompletedView({super.key, required this.order});
  @override
  State<OrderCompletedView> createState() => _OrderCompletedViewState();
}

class _OrderCompletedViewState extends State<OrderCompletedView> {
  late final TextEditingController review;
  bool saved = false;
  @override
  void initState() {
    super.initState();
    review = TextEditingController(text: widget.order.review);
  }

  @override
  void dispose() {
    review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CheckoutScaffold(
    title: checkoutText(context, 'تم الإنجاز', 'Completed'),
    action: saved
        ? checkoutText(context, 'تم حفظ التقييم محليًا', 'Rating saved locally')
        : checkoutText(context, 'إرسال التقييم', 'Submit rating'),
    onAction: saved || widget.order.rating == 0
        ? null
        : () {
      widget.order.review = review.text.trim();
      setState(() => saved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            checkoutText(
              context,
              'اتحفظ التقييم في المعاينة فقط، ولم يتم إرساله للسيرفر',
              'Rating saved in this preview only; it was not sent to the server',
            ),
          ),
        ),
      );
    },
    footer: TextButton(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            checkoutText(
              context,
              'تحميل PDF هيتاح بعد تجهيز خدمة الفواتير',
              'PDF download will be available when the invoice service is ready',
            ),
          ),
        ),
      ),
      child: Text(
        checkoutText(context, 'تحميل الفاتورة PDF', 'Download invoice PDF'),
        style: const TextStyle(color: AppColors.badgeTextGreen),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 18.h),
        CircleAvatar(
          radius: 30.r,
          backgroundColor: AppColors.badgeBg,
          child: Icon(Icons.check, color: AppColors.primaryColor, size: 38.sp),
        ),
        SizedBox(height: 16.h),
        Text(
          checkoutText(
            context,
            'تم الدفع وإغلاق الطلب',
            'Payment complete and order closed',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        SizedBox(height: 10.h),
        Text(
          checkoutText(
            context,
            'معاينة فقط • لم يتم دفع أو إغلاق طلب فعلي',
            'Preview only • No actual payment or order closure',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.subtitleGrey, fontSize: 11.sp),
        ),
        SizedBox(height: 16.h),
        OrderRatingCard(
          rating: widget.order.rating,
          onChanged: (value) => setState(() {
            widget.order.rating = value;
            saved = false;
          }),
        ),
        SizedBox(height: 10.h),
        TextField(
          controller: review,
          maxLines: 3,
          onChanged: (_) {
            if (saved) setState(() => saved = false);
          },
          decoration: InputDecoration(
            hintText: checkoutText(
              context,
              'اكتب رأيك في الخدمة…',
              'Write your feedback…',
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: AppColors.unselectedBorder),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.badgeBg,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            checkoutText(
              context,
              'تفاصيل ضمان الخدمة هتظهر هنا بعد ربط بيانات الطلب.',
              'Service warranty details will appear here when order data is connected.',
            ),
            style: TextStyle(color: AppColors.badgeTextGreen, fontSize: 11.sp),
          ),
        ),
      ],
    ),
  );
}
