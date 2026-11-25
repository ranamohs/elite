import '../../data/models/cart_change_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/cart_cubit.dart';
import '../manager/cart_state.dart';
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
  late final CartCubit cart;
  final Map<String, int> quantities = {};
  final Map<String, int> cartItemIds = {};
  final Map<String, CatalogItem> selected = {};
  bool showProducts = false;
  OrderDraft? checkoutDraft;
  bool get ar => isArabic(context);
  @override
  void initState() {
    super.initState();
    cart = getIt<CartCubit>();
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
    cart.close();
    services.close();
    products.close();
    super.dispose();
  }

  double get total => selected.values
      .where((item) => item.isProduct == showProducts)
      .fold(0, (sum, item) => sum + item.price * (quantities[item.key] ?? 0));
  String get totalLabel {
    final currencies = selected.values
        .where((item) => item.isProduct == showProducts)
        .map((e) => e.currency)
        .where((e) => e.isNotEmpty)
        .toSet();
    return '${total.toStringAsFixed(3)} ${currencies.length == 1 ? currencies.first : ''}'
        .trim();
  }

  void change(CatalogItem item, int delta) {
    if (cart.state is CartLoading) return;
    if (item.isProduct) {
      if (delta < 0) {
        if ((quantities[item.key] ?? 0) > 0) cart.decreaseProduct(item.id);
        return;
      }
      if (delta == 0 ||
          (item.stock != null && (quantities[item.key] ?? 0) >= item.stock!))
        return;
      cart.addProduct(item.id);
      return;
    }
    setState(() {
      checkoutDraft = null;
      final oldServices = selected.values
          .where((value) => !value.isProduct)
          .map((value) => value.key)
          .toList();
      for (final key in oldServices) {
        selected.remove(key);
        quantities.remove(key);
      }
      if (delta > 0) {
        selected[item.key] = item;
        quantities[item.key] = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      bloc: cart,
      listener: (context, state) {
        if (state is CartSuccess) {
          final model = state.model;
          setState(() {
            checkoutDraft = null;
            cartItemIds[model.product.key] = model.id;
            selected[model.product.key] = model.product;
            quantities[model.product.key] = model.quantity;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(model.localizedMessage(ar))));
        } else if (state is CartChanged) {
          final model = state.model;
          final key = 'product:${model.productId}';
          setState(() {
            checkoutDraft = null;
            if (model.quantity == 0) {
              selected.remove(key);
              quantities.remove(key);
              cartItemIds.remove(key);
            } else {
              quantities[key] = model.quantity;
              if (model.product != null) selected[key] = model.product!;
              if (model.cartItemId != null)
                cartItemIds[key] = model.cartItemId!;
            }
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(model.localizedMessage(ar))));
        } else if (state is CartFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.errMessage)));
        }
      },
      builder: (context, state) => Directionality(
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
                        onRemove: (item) {
                          final id = cartItemIds[item.key];
                          if (id != null) {
                            cart.removeProduct(
                              productId: item.id,
                              cartItemId: id,
                            );
                          }
                        },
                        loadingOperation: state is CartLoading
                            ? state.operation
                            : CartOperation.add,
                        enabled: state is! CartLoading,
                        loadingProductId: state is CartLoading
                            ? state.productId
                            : null,
                      ),
                      CatalogItemsList(
                        cubit: products,
                        product: true,
                        quantities: quantities,
                        onQuantityChanged: change,
                        onRemove: (item) {
                          final id = cartItemIds[item.key];
                          if (id != null) {
                            cart.removeProduct(
                              productId: item.id,
                              cartItemId: id,
                            );
                          }
                        },
                        loadingOperation: state is CartLoading
                            ? state.operation
                            : CartOperation.add,
                        enabled: state is! CartLoading,
                        loadingProductId: state is CartLoading
                            ? state.productId
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CatalogBottomBar(
              totalLabel: totalLabel,
              onContinue:
              !selected.values.any(
                    (item) => item.isProduct == showProducts,
              ) ||
                  state is CartLoading
                  ? null
                  : openOrderDetails,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openOrderDetails() async {
    var items = selected.values
        .where((item) => item.isProduct == showProducts)
        .toList();
    if (items.isEmpty) return;
    if (showProducts && items.length > 1) {
      final chosen = await showModalBottomSheet<CatalogItem>(
        context: context,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.all(18.w),
                child: Text(
                  ar
                      ? 'اختاري المنتج اللي عايزة تكمّلي طلبه'
                      : 'Choose the product to order',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...items.map(
                    (item) => ListTile(
                  title: Text(item.title(ar)),
                  subtitle: Text(
                    '${quantities[item.key] ?? 0} × ${item.price.toStringAsFixed(2)} ${item.currency}',
                  ),
                  onTap: () => Navigator.pop(context, item),
                ),
              ),
            ],
          ),
        ),
      );
      if (chosen == null || !mounted) return;
      items = [chosen];
    }
    final cartId = showProducts ? cartItemIds[items.single.key] : null;
    final keys = items.map((e) => e.key).toSet();
    final draft = checkoutDraft;
    final reuse =
        draft != null &&
            draft.orderId == null &&
            draft.items.map((e) => e.key).toSet().containsAll(keys) &&
            draft.items.length == keys.length;
    checkoutDraft = reuse
        ? draft
        : OrderDraft(
      items: items,
      quantities: {
        for (final item in items) item.key: quantities[item.key] ?? 0,
      },
      cartId: cartId,
    );
    final order = checkoutDraft!;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => OrderDetailsView(order: order)));
    if (mounted && order.orderId != null && items.every((e) => e.isProduct))
      setState(() {
        for (final item in items) {
          selected.remove(item.key);
          quantities.remove(item.key);
          cartItemIds.remove(item.key);
        }
        checkoutDraft = null;
      });
  }
}
