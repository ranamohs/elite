import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/retry_widget.dart';
import '../manager/order_details_cubit.dart';
import '../manager/order_details_state.dart';
import '../widgets/order_details_summary.dart';
import '../widgets/order_details_cost.dart';
import '../widgets/order_details_section.dart';
import '../widgets/orders_history_helpers.dart';
import '../widgets/orders_history_loading.dart';

class OrderHistoryDetailsView extends StatefulWidget {
  final int orderId;
  const OrderHistoryDetailsView({super.key, required this.orderId});
  @override
  State<OrderHistoryDetailsView> createState() =>
      _OrderHistoryDetailsViewState();
}

class _OrderHistoryDetailsViewState extends State<OrderHistoryDetailsView> {
  late final OrderDetailsCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = getIt<OrderDetailsCubit>()..load(widget.orderId);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
    child: Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: AppStyles.styleMedium16(context).fontFamily,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        appBar: AppBar(
          backgroundColor: AppColors.homeBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
            bloc: cubit,
            builder: (context, state) => Text(
              ordersText(
                context,
                'طلب #${state is OrderDetailsSuccess ? state.model.order.code : widget.orderId}',
                'Order #${state is OrderDetailsSuccess ? state.model.order.code : widget.orderId}',
              ),
              style: AppStyles.styleMedium16(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
              bloc: cubit,
              builder: (context, state) {
                if (state is OrderDetailsFailure)
                  return Center(
                    child: RetryWidget(
                      message: state.failure.errMessage,
                      onPressed: () => cubit.load(widget.orderId),
                    ),
                  );
                if (state is! OrderDetailsSuccess)
                  return const OrdersHistoryLoadingWidget();
                final model = state.model;
                return RefreshIndicator(
                  onRefresh: () => cubit.load(widget.orderId),
                  color: AppColors.primaryColor,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    children: [
                      OrderDetailsSummary(model: model),
                      if (model.lines.isNotEmpty || model.price != null)
                        OrderDetailsCost(model: model),
                      if ((model.proposedCount ?? 0) > 0 ||
                          (model.pendingCount ?? 0) > 0 ||
                          (model.approvedCount ?? 0) > 0 ||
                          (model.rejectedCount ?? 0) > 0)
                        OrderDetailsSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                ordersText(
                                  context,
                                  'مقترحات المنتجات',
                                  'Product proposals',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              if (model.proposedCount != null)
                                Text(
                                  '${ordersText(context, 'الإجمالي', 'Total')}: ${model.proposedCount}',
                                ),
                              if (model.pendingCount != null)
                                Text(
                                  '${ordersText(context, 'قيد الانتظار', 'Pending')}: ${model.pendingCount}',
                                ),
                              if (model.approvedCount != null)
                                Text(
                                  '${ordersText(context, 'مقبولة', 'Approved')}: ${model.approvedCount}',
                                ),
                              if (model.rejectedCount != null)
                                Text(
                                  '${ordersText(context, 'مرفوضة', 'Rejected')}: ${model.rejectedCount}',
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
