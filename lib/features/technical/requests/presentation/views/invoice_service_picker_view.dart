import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/databases/cache/secure_storage_helper.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/features/account/presentation/widgets/account_ui.dart';
import 'package:elite/features/category_catalog/data/models/catalog_model.dart';
import 'package:elite/features/category_catalog/data/repos/catalog_repo.dart';
import 'package:elite/features/home/data/repos/categories_repo/categories_repo.dart';
import 'package:elite/features/services/data/repos/category_services_repo_impl.dart';
import 'package:elite/features/sub_category/data/repos/sub_category_repo_impl.dart';

class InvoiceServicePickerView extends StatefulWidget {
  final int level;
  final int? parentId;
  final String? title;
  const InvoiceServicePickerView({
    super.key,
    this.level = 0,
    this.parentId,
    this.title,
  });
  @override
  State<InvoiceServicePickerView> createState() =>
      _InvoiceServicePickerViewState();
}

class _InvoiceServicePickerViewState extends State<InvoiceServicePickerView> {
  final items = <(int, String, String, CatalogItem?)>[];
  bool loading = false;
  String? error;
  int page = 0, lastPage = 1;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
    });
    final next = page + 1;
    final entries = <(int, String, String, CatalogItem?)>[];
    int last = 1;
    String? failure;
    try {
      if (widget.level == 0) {
        final result = await getIt<CategoriesRepo>().getCategories(page: next);
        result.fold((f) => failure = f.errMessage, (m) {
          last = m.meta.lastPage;
          entries.addAll(m.data.map((e) => (e.id, e.name.ar, e.name.en, null)));
        });
      } else if (widget.level == 1) {
        final result = await CategoryServicesRepoImpl(
          dioConsumer: getIt<DioConsumer>(),
          networkCubit: getIt<NetworkConnectionCubit>(),
          secureStorageHelper: getIt<SecureStorageHelper>(),
        ).getCategoryServices(categoryId: widget.parentId!, page: next);
        result.fold((f) => failure = f.errMessage, (m) {
          last = m.meta?.lastPage ?? 1;
          entries.addAll(m.data.map((e) => (e.id, e.name.ar, e.name.en, null)));
        });
      } else if (widget.level == 2) {
        final result = await SubCategoryRepoImpl(
          dioConsumer: getIt<DioConsumer>(),
          networkCubit: getIt<NetworkConnectionCubit>(),
          secureStorageHelper: getIt<SecureStorageHelper>(),
        ).getSubCategories(subCategoryId: widget.parentId!, page: next);
        result.fold((f) => failure = f.errMessage, (m) {
          last = m.meta?.lastPage ?? 1;
          entries.addAll(m.data.map((e) => (e.id, e.name.ar, e.name.en, null)));
        });
      } else {
        final result = await getIt<CatalogRepo>().getItems(
          categoryId: widget.parentId!,
          isProduct: false,
          page: next,
        );
        result.fold((f) => failure = f.errMessage, (m) {
          last = m.lastPage;
          entries.addAll(
            m.items
                .where((e) => e.price.isFinite && e.price >= 0)
                .map((e) => (e.id, e.title(true), e.title(false), e)),
          );
        });
      }
    } catch (_) {
      failure = mounted
          ? accountText(
        context,
        'تعذر تحميل الكتالوج',
        'Could not load catalog',
      )
          : '';
    }
    if (!mounted) return;
    setState(() {
      loading = false;
      error = failure;
      if (failure == null) {
        items.addAll(entries.where((e) => !items.any((old) => old.$1 == e.$1)));
        page = next;
        lastPage = last;
      }
    });
  }

  @override
  Widget build(BuildContext context) => AccountScaffold(
    title:
    widget.title ??
        accountText(
          context,
          'اختيار خدمة من الكتالوج',
          'Select catalog service',
        ),
    body: ListView(
      padding: EdgeInsets.all(18.w),
      children: [
        ...items.map(
              (entry) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: AccountCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(accountText(context, entry.$2, entry.$3)),
                subtitle: entry.$4 == null ? null : Text(entry.$4!.priceLabel),
                trailing: const Icon(Icons.chevron_left),
                onTap: () async {
                  if (entry.$4 != null) {
                    Navigator.pop(context, entry.$4);
                    return;
                  }
                  final result = await Navigator.of(context).push<CatalogItem>(
                    MaterialPageRoute(
                      builder: (_) => InvoiceServicePickerView(
                        level: widget.level + 1,
                        parentId: entry.$1,
                        title: accountText(context, entry.$2, entry.$3),
                      ),
                    ),
                  );
                  if (result != null && context.mounted)
                    Navigator.pop(context, result);
                },
              ),
            ),
          ),
        ),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        if (error != null) ...[
          Text(error!, textAlign: TextAlign.center),
          TextButton(
            onPressed: load,
            child: Text(accountText(context, 'إعادة المحاولة', 'Retry')),
          ),
        ],
        if (!loading && error == null && items.isEmpty)
          Text(
            accountText(context, 'لا توجد عناصر متاحة', 'No items available'),
            textAlign: TextAlign.center,
          ),
        if (!loading && error == null && page < lastPage)
          TextButton(
            onPressed: load,
            child: Text(accountText(context, 'تحميل المزيد', 'Load more')),
          ),
      ],
    ),
  );
}
