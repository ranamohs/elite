import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_services_model.dart';
import '../../data/repos/category_services_repo.dart';
import 'category_services_state.dart';

class CategoryServicesCubit extends Cubit<CategoryServicesState> {
  final CategoryServicesRepo categoryServicesRepo;

  CategoryServicesCubit({required this.categoryServicesRepo})
      : super(const CategoryServicesInitial());

  bool get isLoadingMore => state is CategoryServicesLoadingMore;

  Future<void> getCategoryServices({
    required int categoryId,
    int page = 1,
  }) async {
    CategoryServicesModel? oldModel;
    int currentPage = 1;
    int lastPage = 1;

    if (state is CategoryServicesSuccess) {
      final success = state as CategoryServicesSuccess;
      oldModel = success.servicesModel;
      currentPage = success.currentPage;
      lastPage = success.lastPage;
    } else if (state is CategoryServicesLoadingMore) {
      final loadingMore = state as CategoryServicesLoadingMore;
      oldModel = loadingMore.servicesModel;
      currentPage = loadingMore.currentPage;
      lastPage = loadingMore.lastPage;
    }

    if (page == 1) {
      emit(const CategoryServicesLoading());
    } else if (oldModel != null) {
      emit(CategoryServicesLoadingMore(
        servicesModel: oldModel,
        currentPage: currentPage,
        lastPage: lastPage,
      ));
    }

    final result = await categoryServicesRepo.getCategoryServices(
      categoryId: categoryId,
      page: page,
    );

    result.fold(
          (failure) => emit(CategoryServicesFailure(failure)),
          (newModel) {
        final mergedModel = (page == 1 || oldModel == null)
            ? newModel
            : _mergeServices(oldModel, newModel);

        final metaCurrentPage = newModel.meta?.currentPage ?? page;
        final metaLastPage = newModel.meta?.lastPage ?? page;

        emit(CategoryServicesSuccess(
          servicesModel: mergedModel,
          currentPage: metaCurrentPage,
          lastPage: metaLastPage,
        ));
      },
    );
  }

  void loadNextPage(int categoryId) {
    if (state is CategoryServicesSuccess) {
      final success = state as CategoryServicesSuccess;
      if (success.currentPage < success.lastPage) {
        getCategoryServices(
          categoryId: categoryId,
          page: success.currentPage + 1,
        );
      }
    }
  }

  void refreshServices(int categoryId) {
    getCategoryServices(categoryId: categoryId, page: 1);
  }

  CategoryServicesModel _mergeServices(
      CategoryServicesModel oldModel,
      CategoryServicesModel newModel,
      ) {
    final mergedData = List<CategoryServiceItem>.from(oldModel.data)
      ..addAll(newModel.data);

    return CategoryServicesModel(
      status: newModel.status,
      message: newModel.message,
      data: mergedData,
      links: newModel.links,
      meta: newModel.meta,
    );
  }
}
