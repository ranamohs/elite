import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/order_draft.dart';
import '../../data/repos/product_order_repo.dart';
import '../manager/product/product_order_cubit.dart';
import '../widgets/checkout_widgets.dart';

class ProductOrderReviewView extends StatefulWidget {
  final OrderDraft order;
  const ProductOrderReviewView({super.key, required this.order});
  @override
  State<ProductOrderReviewView> createState() => _ProductOrderReviewViewState();
}

class _ProductOrderReviewViewState extends State<ProductOrderReviewView> {
  late final ProductOrderCubit cubit;
  Uint8List? receiptBytes;
  bool picking = false;
  @override
  void initState() {
    super.initState();
    cubit = ProductOrderCubit(getIt<ProductOrderRepo>());
    restoreReceipt();
  }

  Future<void> restoreReceipt() async {
    final path = widget.order.depositReceiptPath;
    if (path != null) {
      try {
        final bytes = await XFile(path).readAsBytes();
        if (mounted) setState(() => receiptBytes = bytes);
      } catch (_) {
        if (mounted) setState(() => widget.order.depositReceiptPath = null);
      }
    }
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  Future<void> pickReceipt() async {
    if (picking || cubit.state.loading) return;
    setState(() => picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            widget.order.depositReceiptPath = file.path;
            receiptBytes = bytes;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkoutText(
                context,
                'تعذر اختيار الإيصال',
                'Could not select receipt',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) => BlocConsumer<ProductOrderCubit, ProductOrderState>(
    bloc: cubit,
    listener: (context, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
      }
    },
    builder: (context, state) {
      final result = state.result, order = widget.order;
      final completed = order.orderId != null;
      return PopScope(
        canPop: !state.loading,
        child: CheckoutScaffold(
          title: checkoutText(
            context,
            completed ? 'تم إنشاء الطلب' : 'مراجعة طلب المنتجات',
            completed ? 'Order created' : 'Review product order',
          ),
          action: checkoutText(
            context,
            state.loading
                ? 'جاري إنشاء الطلب…'
                : completed
                ? 'الرجوع للمنتجات'
                : 'تأكيد طلب المنتجات',
            state.loading
                ? 'Creating order…'
                : completed
                ? 'Back to products'
                : 'Confirm product order',
          ),
          onAction: state.loading || picking
              ? null
              : completed
              ? () => Navigator.pop(context, true)
              : () => cubit.submit(order),
          footer: state.loading
              ? const Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (completed) ...[
                Icon(
                  Icons.check_circle_outline,
                  size: 64.sp,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  result?.text(isArabic(context)).isNotEmpty == true
                      ? result!.text(isArabic(context))
                      : checkoutText(
                    context,
                    'تم إنشاء الطلب بنجاح',
                    'Order created successfully',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text('#${order.orderId}', textAlign: TextAlign.center),
                if (order.confirmedTotal != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      '${checkoutText(context, 'الإجمالي', 'Total')}: ${order.confirmedTotal!.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: AppColors.badgeTextGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ] else ...[
                OrderPriceCard(
                  order: order,
                  title: checkoutText(
                    context,
                    'المنتج والكمية',
                    'Product and quantity',
                  ),
                ),
                SizedBox(height: 14.h),
                CheckoutCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        checkoutText(context, 'عنوان الطلب', 'Order address'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10.h),
                      Text(order.address?.details ?? ''),
                    ],
                  ),
                ),
                CheckoutSectionTitle(
                  checkoutText(
                    context,
                    'إيصال الإيداع (اختياري)',
                    'Deposit receipt (optional)',
                  ),
                ),
                CheckoutCard(
                  child: Column(
                    children: [
                      if (receiptBytes != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.memory(
                            receiptBytes!,
                            height: 180.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      TextButton.icon(
                        onPressed: picking ? null : pickReceipt,
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text(
                          checkoutText(
                            context,
                            receiptBytes == null
                                ? 'إضافة إيصال'
                                : 'تغيير الإيصال',
                            receiptBytes == null
                                ? 'Add receipt'
                                : 'Change receipt',
                          ),
                        ),
                      ),
                      if (receiptBytes != null)
                        TextButton(
                          onPressed: () => setState(() {
                            receiptBytes = null;
                            order.depositReceiptPath = null;
                          }),
                          child: Text(
                            checkoutText(
                              context,
                              'حذف الإيصال',
                              'Remove receipt',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
