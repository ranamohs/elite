import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/catalog_model.dart';
import '../../data/repos/catalog_repo.dart';
import '../manager/catalog_cubit.dart';
import '../widgets/catalog_bottom_bar.dart';
import '../widgets/catalog_header.dart';
import '../widgets/catalog_items_list.dart';
import '../../../checkout/data/models/order_draft.dart';
import '../../../checkout/presentation/views/order_details_view.dart';

class CategoryCatalogView extends StatefulWidget {
  final int categoryId;
  final String arName, enName;
  final String? parentArName, parentEnName, mainArName, mainEnName;
  const CategoryCatalogView({
    super.key,
    required this.categoryId,
    required this.arName,
    required this.enName,
    this.parentArName,
    this.parentEnName,
    this.mainArName,
    this.mainEnName,
  });
  @override
  State<CategoryCatalogView> createState() => _CategoryCatalogViewState();
}

class _CategoryCatalogViewState extends State<CategoryCatalogView> {
  late final CatalogCubit services, products;
  final Map<String, int> quantities = {};
  final Map<String, CatalogItem> selected = {};
  bool showProducts = false;
  bool get ar => isArabic(context);
  @override
  void initState() {
    super.initState();
    services = CatalogCubit(
      repo: getIt<CatalogRepo>(),
      categoryId: widget.categoryId,
      isProduct: false,
    )..load();
    products = CatalogCubit(
      repo: getIt<CatalogRepo>(),
      categoryId: widget.categoryId,
      isProduct: true,
    )..load();
  }

  @override
  void dispose() {
    services.close();
    products.close();
    super.dispose();
  }

  double get total => selected.values.fold(
    0,
        (sum, item) => sum + item.price * (quantities[item.key] ?? 0),
  );
  String get totalLabel {
    final currencies = selected.values
        .map((e) => e.currency)
        .where((e) => e.isNotEmpty)
        .toSet();
    return '${total.toStringAsFixed(3)} ${currencies.length == 1 ? currencies.first : ''}'
        .trim();
  }

  void change(CatalogItem item, int delta) {
    final next = (quantities[item.key] ?? 0) + delta;
    if (next < 0 ||
        (item.isProduct && item.stock != null && next > item.stock!))
      return;
    setState(() {
      quantities[item.key] = next;
      if (next == 0) {
        selected.remove(item.key);
      } else {
        selected[item.key] = item;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
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
            title: Text(
              ar ? widget.arName : widget.enName,
              style: AppStyles.styleMedium16(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          body: Column(
            children: [
              CatalogHeader(
                arName: widget.arName,
                enName: widget.enName,
                mainArName: widget.mainArName,
                mainEnName: widget.mainEnName,
                parentArName: widget.parentArName,
                parentEnName: widget.parentEnName,
                services: services,
                products: products,
                showProducts: showProducts,
                onTabChanged: (value) => setState(() => showProducts = value),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: IndexedStack(
                  index: showProducts ? 1 : 0,
                  children: [
                    CatalogItemsList(
                      cubit: services,
                      product: false,
                      quantities: quantities,
                      onQuantityChanged: change,
                    ),
                    CatalogItemsList(
                      cubit: products,
                      product: true,
                      quantities: quantities,
                      onQuantityChanged: change,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CatalogBottomBar(
            totalLabel: totalLabel,
            onContinue: selected.isEmpty ? null : openOrderDetails,
          ),
        ),
      ),
    );
  }

  void openOrderDetails() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => OrderDetailsView(
        order: OrderDraft(
          items: selected.values.toList(),
          quantities: quantities,
        ),
      ),
    ),
  );
}
