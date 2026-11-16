import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/retry_widget.dart';
import '../../data/models/orders_history_model.dart';
import '../views/order_history_details_view.dart';
import 'order_history_card.dart';
import 'orders_history_helpers.dart';
import 'orders_history_tabs.dart';
import 'orders_history_empty.dart';

class OrdersHistoryContent extends StatelessWidget {
  final OrdersHistoryModel model;
  final bool previous, loadingMore;
  final String? error;
  final ValueChanged<bool> onTabChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry, onLoadMore, onRequestService;
  const OrdersHistoryContent({
    super.key,
    required this.model,
    required this.previous,
    required this.loadingMore,
    required this.onTabChanged,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    required this.onRequestService,
    this.error,
  });

  Widget card(BuildContext context, OrderHistoryItem order) => OrderHistoryCard(
    order: order,
    onDetails: () => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderHistoryDetailsView(orderId: order.id),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final current = model.orders.where((e) => !e.isPrevious).toList();
    final old = model.orders.where((e) => e.isPrevious).toList();
    final hasMore = model.currentPage < model.lastPage;
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: model.orders.isEmpty ? 170.w : double.infinity,
            child: OrdersHistoryTabs(
              previous: previous,
              currentCount: current.length,
              hasMore: hasMore,
              compact: model.orders.isEmpty,
              onChanged: onTabChanged,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColors.primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 16.h),
              children: [
                if (!previous) ...current.map((order) => card(context, order)),
                if (!previous && old.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, bottom: 14.h),
                    child: Text(
                      ordersText(context, 'طلبات سابقة', 'Previous orders'),
                      style: TextStyle(
                        color: AppColors.subtitleGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ...old.map((order) => card(context, order)),
                if ((previous && old.isEmpty) ||
                    (!previous && model.orders.isEmpty))
                  OrdersHistoryEmpty(
                    previous: previous,
                    onRequestService: onRequestService,
                  ),
                if (error != null)
                  RetryWidget(message: error!, onPressed: onRetry),
                if (hasMore && error == null)
                  Center(
                    child: loadingMore
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    )
                        : TextButton(
                      onPressed: onLoadMore,
                      child: Text(
                        ordersText(context, 'تحميل المزيد', 'Load more'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
