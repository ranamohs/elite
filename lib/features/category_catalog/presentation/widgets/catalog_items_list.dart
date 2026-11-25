import '../../data/models/cart_change_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';
import '../manager/catalog_state.dart';
import '../manager/catalog_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/retry_widget.dart';
import 'catalog_item_card.dart';

class CatalogItemsList extends StatelessWidget {
  final CartOperation loadingOperation;
  final ValueChanged<CatalogItem>? onRemove;
  final bool enabled;
  final int? loadingProductId;
  final CatalogCubit cubit;
  final bool product;
  final Map<String, int> quantities;
  final void Function(CatalogItem, int) onQuantityChanged;
  const CatalogItemsList({
    super.key,
    this.onRemove,
    this.loadingOperation = CartOperation.add,
    this.enabled = true,
    this.loadingProductId,
    required this.cubit,
    required this.product,
    required this.quantities,
    required this.onQuantityChanged,
  });
  CatalogPage? catalogPage(CatalogState state) {
    if (state is CatalogSuccess) return state.catalogPage;
    if (state is CatalogLoadingMore) return state.catalogPage;
    if (state is CatalogFailure) return state.catalogPage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;
    return BlocBuilder<CatalogCubit, CatalogState>(
      bloc: cubit,
      builder: (context, state) {
        final model = catalogPage(state);
        final items = model?.items ?? <CatalogItem>[];
        final error = state is CatalogFailure ? state.failure.errMessage : null;
        if (state is CatalogLoading || state is CatalogInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        if (error != null && items.isEmpty) {
          return Center(
            child: RetryWidget(message: error, onPressed: () => cubit.load()),
          );
        }
        return RefreshIndicator(
          onRefresh: () => cubit.load(),
          color: AppColors.primaryColor,
          child: CustomScrollView(
            key: PageStorageKey(product),
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      text(
                        'لا توجد عناصر في هذا القسم',
                        'No items in this category',
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                sliver: product
                    ? SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => CatalogItemCard(
                      item: items[index],
                      loadingOperation: loadingOperation,
                      onRemove: onRemove == null
                          ? null
                          : () => onRemove!(items[index]),
                      enabled: enabled,
                      loading:
                      items[index].isProduct &&
                          loadingProductId == items[index].id,
                      count: quantities[items[index].key] ?? 0,
                      onChanged: (delta) =>
                          onQuantityChanged(items[index], delta),
                    ),
                    childCount: items.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    mainAxisExtent: 290.h,
                  ),
                )
                    : SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: CatalogItemCard(
                        item: items[index],
                        loadingOperation: loadingOperation,
                        onRemove: onRemove == null
                            ? null
                            : () => onRemove!(items[index]),
                        enabled: enabled,
                        loading:
                        items[index].isProduct &&
                            loadingProductId == items[index].id,
                        count: quantities[items[index].key] ?? 0,
                        onChanged: (delta) =>
                            onQuantityChanged(items[index], delta),
                      ),
                    ),
                    childCount: items.length,
                  ),
                ),
              ),
              if (!product && items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(18.w),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F0FF),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        text(
                          'محتاج منتجات؟ اختار من تبويب المنتجات',
                          'Need products? Browse the products tab',
                        ),
                        style: TextStyle(color: Colors.blue, fontSize: 11.sp),
                      ),
                    ),
                  ),
                ),
              if (error != null)
                SliverToBoxAdapter(
                  child: RetryWidget(
                    message: error,
                    onPressed: () => cubit.load(more: model != null),
                  ),
                ),
              if (error == null &&
                  model != null &&
                  model.currentPage < model.lastPage)
                SliverToBoxAdapter(
                  child: Center(
                    child: state is CatalogLoadingMore
                        ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                        : TextButton(
                      onPressed: () => cubit.load(more: true),
                      child: Text(text('تحميل المزيد', 'Load more')),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),
            ],
          ),
        );
      },
    );
  }
}
