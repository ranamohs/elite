import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/retry_widget.dart';
import '../../data/models/orders_history_model.dart';
import 'order_history_card.dart';
import 'order_history_details.dart';
import 'orders_history_helpers.dart';
import 'orders_history_tabs.dart';

class OrdersHistoryContent extends StatelessWidget {
  final OrdersHistoryModel model;
  final bool previous, loadingMore;
  final String? error;
  final ValueChanged<bool> onTabChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry, onLoadMore;
  const OrdersHistoryContent({
    super.key,
    required this.model,
    required this.previous,
    required this.loadingMore,
    required this.onTabChanged,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    this.error,
  });

  Widget card(BuildContext context, OrderHistoryItem order) => OrderHistoryCard(
    order: order,
    onDetails: () => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .8,
      ),
      builder: (_) => OrderHistoryDetails(order: order),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final current = model.orders.where((e) => !e.isPrevious).toList();
    final old = model.orders.where((e) => e.isPrevious).toList();
    final hasMore = model.currentPage < model.lastPage;
    return Column(
      children: [
        OrdersHistoryTabs(
          previous: previous,
          currentCount: current.length,
          hasMore: hasMore,
          onChanged: onTabChanged,
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
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 70.h),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: AppColors.navInactiveGrey,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          previous
                              ? ordersText(
                            context,
                            'لا توجد طلبات سابقة',
                            'No previous orders',
                          )
                              : ordersText(
                            context,
                            'لا توجد طلبات حتى الآن',
                            'No orders yet',
                          ),
                        ),
                      ],
                    ),
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
