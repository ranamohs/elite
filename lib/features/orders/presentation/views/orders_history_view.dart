import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/retry_widget.dart';
import '../manager/orders_history_cubit.dart';
import '../manager/orders_history_state.dart';
import '../widgets/orders_history_content.dart';
import '../widgets/orders_history_helpers.dart';
import '../widgets/orders_history_loading.dart';

class OrdersHistoryView extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onRequestService;
  const OrdersHistoryView({
    super.key,
    this.isActive = true,
    this.onRequestService,
  });
  @override
  State<OrdersHistoryView> createState() => _OrdersHistoryViewState();
}

class _OrdersHistoryViewState extends State<OrdersHistoryView>
    with AutomaticKeepAliveClientMixin {
  late final OrdersHistoryCubit cubit;
  bool previous = false;
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    cubit = getIt<OrdersHistoryCubit>();
    if (widget.isActive) cubit.load();
  }

  @override
  void didUpdateWidget(covariant OrdersHistoryView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) cubit.load();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Directionality(
      textDirection: isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
      child: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: AppStyles.styleMedium16(context).fontFamily,
          ),
        ),
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.h, bottom: 18.h),
                    child: Text(
                      ordersText(context, 'طلباتي', 'My orders'),
                      style: AppStyles.styleMedium16(
                        context,
                      ).copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<OrdersHistoryCubit, OrdersHistoryState>(
                      bloc: cubit,
                      builder: (context, state) {
                        if (state is OrdersHistoryLoading ||
                            state is OrdersHistoryInitial)
                          return const OrdersHistoryLoadingWidget();
                        // Render from this builder's state snapshot. cubit.state may
                        // already be Loading while BlocBuilder still holds Success.
                        final model = switch (state) {
                          OrdersHistorySuccess() => state.model,
                          OrdersHistoryLoadingMore() => state.model,
                          OrdersHistoryFailure() => state.model,
                          _ => null,
                        };
                        if (model == null) {
                          if (state is OrdersHistoryFailure) {
                            return Center(
                              child: RetryWidget(
                                message: state.failure.errMessage,
                                onPressed: () => cubit.load(),
                              ),
                            );
                          }
                          return const OrdersHistoryLoadingWidget();
                        }
                        return OrdersHistoryContent(
                          model: model,
                          onRequestService:
                          widget.onRequestService ??
                                  () => context.go(AppRouter.homePage),
                          previous: previous,
                          loadingMore: state is OrdersHistoryLoadingMore,
                          error: state is OrdersHistoryFailure
                              ? state.failure.errMessage
                              : null,
                          onTabChanged: (value) =>
                              setState(() => previous = value),
                          onRefresh: () => cubit.load(),
                          onLoadMore: () => cubit.load(more: true),
                          onRetry: () => cubit.load(
                            more:
                            state is OrdersHistoryFailure && state.loadMore,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
