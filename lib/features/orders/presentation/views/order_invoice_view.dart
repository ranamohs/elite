import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/end_points.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../data/repos/order_invoice_repo.dart';
import '../manager/order_invoice_cubit.dart';

class OrderInvoiceView extends StatefulWidget {
  final int orderId;
  const OrderInvoiceView({super.key, required this.orderId});
  @override
  State<OrderInvoiceView> createState() => _OrderInvoiceViewState();
}

class _OrderInvoiceViewState extends State<OrderInvoiceView> {
  late final OrderInvoiceCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = OrderInvoiceCubit(getIt<OrderInvoiceRepo>())..load(widget.orderId);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(context, 'تفاصيل الفاتورة', 'Invoice details'),
    body: BlocBuilder<OrderInvoiceCubit, OrderInvoiceState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        final invoice = state.invoice;
        if (invoice == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.error ??
                        accountText(
                          context,
                          'تعذر تحميل الفاتورة',
                          'Could not load invoice',
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  FilledButton(
                    onPressed: () => cubit.load(widget.orderId),
                    child: Text(
                      accountText(context, 'إعادة المحاولة', 'Retry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final status = switch (invoice.status.toLowerCase()) {
          'unpaid' => accountText(context, 'غير مدفوعة', 'Unpaid'),
          'paid' => accountText(context, 'مدفوعة', 'Paid'),
          'partial' || 'partially_paid' => accountText(
            context,
            'مدفوعة جزئيًا',
            'Partially paid',
          ),
          _ => invoice.status,
        };
        final raw = invoice.receiptUrl;
        final uri = raw == null
            ? null
            : Uri.tryParse(EndPoints.imageBaseUrl)?.resolve(raw);
        final receiptUrl =
        uri != null && const {'http', 'https'}.contains(uri.scheme)
            ? uri.toString()
            : null;
        return RefreshIndicator(
          onRefresh: () => cubit.load(widget.orderId),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(18.w),
            children: [
              AccountCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            accountText(
                              context,
                              'فاتورة #${invoice.id}',
                              'Invoice #${invoice.id}',
                            ),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.badgeBg,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: AppColors.badgeTextGreen,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      accountText(
                        context,
                        'طلب #${invoice.orderId}',
                        'Order #${invoice.orderId}',
                      ),
                      style: TextStyle(
                        color: AppColors.subtitleGrey,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (invoice.createdAt != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        DateFormat(
                          'd MMMM yyyy · HH:mm',
                          isArabic(context) ? 'ar' : 'en',
                        ).format(invoice.createdAt!.toLocal()),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.subtitleGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              AccountCard(
                child: Column(
                  children: [
                    amount(
                      accountText(context, 'إجمالي الفاتورة', 'Invoice total'),
                      invoice.total,
                    ),
                    const Divider(height: 24),
                    amount(
                      accountText(context, 'المدفوع', 'Paid'),
                      invoice.paid,
                    ),
                    const Divider(height: 24),
                    amount(
                      accountText(context, 'المتبقي', 'Remaining'),
                      invoice.remaining,
                      highlight: true,
                    ),
                  ],
                ),
              ),
              if (receiptUrl != null) ...[
                SizedBox(height: 12.h),
                AccountCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        accountText(
                          context,
                          'إيصال الإيداع',
                          'Deposit receipt',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: receiptUrl,
                          height: 300.h,
                          fit: BoxFit.contain,
                          placeholder: (_, _) =>
                          const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, _, _) => Center(
                            child: Text(
                              accountText(
                                context,
                                'تعذر تحميل صورة الإيصال',
                                'Could not load receipt image',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
  Widget amount(String label, double? value, {bool highlight = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: highlight
                ? AppColors.badgeTextGreen
                : AppColors.subtitleGrey,
          ),
        ),
      ),
      Text(
        value?.toStringAsFixed(2) ?? '—',
        style: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.bold,
          color: highlight ? AppColors.badgeTextGreen : null,
        ),
      ),
    ],
  );
}
