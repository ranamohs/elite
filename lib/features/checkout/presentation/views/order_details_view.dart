import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_draft.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/order_photos_picker.dart';
import 'order_address_view.dart';
import 'order_schedule_view.dart';

class OrderDetailsView extends StatefulWidget {
  final OrderDraft order;
  const OrderDetailsView({super.key, required this.order});
  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  late final TextEditingController description;
  @override
  void initState() {
    super.initState();
    description = TextEditingController(text: widget.order.description);
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> address() async {
    final value = await Navigator.of(context).push<OrderAddress>(
      MaterialPageRoute(
        builder: (_) => OrderAddressView(initial: widget.order.address),
      ),
    );
    if (mounted && value != null) setState(() => widget.order.address = value);
  }

  Future<void> photos() async {
    try {
      final files = await ImagePicker().pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (!mounted) return;
      setState(
            () => widget.order.photos = [
          ...widget.order.photos,
          ...files.map((e) => e.path),
        ].take(3).toList(),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkoutText(
                context,
                'تعذر اختيار الصور، حاولي مرة أخرى',
                'Could not select photos. Please try again.',
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return CheckoutScaffold(
      title: checkoutText(context, 'تفاصيل الطلب', 'Order details'),
      action: checkoutText(
        context,
        'التالي: الموعد والدفع',
        'Next: schedule and payment',
      ),
      onAction: () async {
        order.description = description.text.trim();
        if (order.address == null) {
          await address();
          if (!mounted || order.address == null) return;
        }
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OrderScheduleView(order: order)),
        );
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OrderPriceCard(
            order: order,
            title: checkoutText(
              context,
              'الخدمات والمنتجات المختارة',
              'Selected services and products',
            ),
          ),
          CheckoutSectionTitle(
            checkoutText(
              context,
              'اوصف المشكلة (اختياري)',
              'Describe the issue (optional)',
            ),
          ),
          TextField(
            controller: description,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: checkoutText(
                context,
                'مثال: السخان القديم محتاج يتفك، والجديد يتركب، وفيه تسريب من الوصلة…',
                'Describe the work or issue…',
              ),
              hintStyle: TextStyle(
                color: AppColors.subtitleGrey,
                fontSize: 12.sp,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: AppColors.unselectedBorder),
              ),
            ),
          ),
          CheckoutSectionTitle(
            checkoutText(
              context,
              'صور المشكلة (اختياري)',
              'Issue photos (optional)',
            ),
          ),
          OrderPhotosPicker(
            photos: order.photos,
            onAdd: photos,
            onRemove: (index) => setState(() => order.photos.removeAt(index)),
          ),
          CheckoutSectionTitle(checkoutText(context, 'العنوان', 'Address')),
          CheckoutCard(
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: AppColors.badgeTextGreen,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.address?.label ??
                            checkoutText(
                              context,
                              'أضيفي عنوانك',
                              'Add your address',
                            ),
                      ),
                      if (order.address != null)
                        Text(
                          order.address!.details,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.subtitleGrey,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: address,
                  child: Text(checkoutText(context, 'تغيير', 'Change')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
