import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/catalog_model.dart';
import '../../data/repos/catalog_repo.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogRepo repo;
  final int categoryId;
  final bool isProduct;

  CatalogCubit({
    required this.repo,
    required this.categoryId,
    required this.isProduct,
  }) : super(CatalogInitial());

  Future<void> load({bool more = false}) async {
    final currentState = state;
    if (currentState is CatalogLoading || currentState is CatalogLoadingMore) {
      return;
    }
    CatalogPage? previous;
    if (currentState is CatalogSuccess) {
      previous = currentState.catalogPage;
    } else if (currentState is CatalogFailure) {
      previous = currentState.catalogPage;
    }
    if (more &&
        (previous == null || previous.currentPage >= previous.lastPage)) {
      return;
    }
    final page = more ? previous!.currentPage + 1 : 1;
    if (more) {
      emit(CatalogLoadingMore(catalogPage: previous!));
    } else {
      emit(CatalogLoading());
    }

    final result = await repo.getItems(
      categoryId: categoryId,
      isProduct: isProduct,
      page: page,
    );
    if (isClosed) return;
    result.fold(
          (failure) => emit(CatalogFailure(failure, catalogPage: previous)),
          (model) {
        final catalogPage = more
            ? CatalogPage(
          items: [...previous!.items, ...model.items],
          currentPage: model.currentPage,
          lastPage: model.lastPage,
          total: model.total,
        )
            : model;
        emit(CatalogSuccess(catalogPage: catalogPage));
      },
    );
  }
}
