import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/sub_category_model.dart';
import '../../data/repos/sub_category_repo.dart';
import 'sub_category_state.dart';

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final SubCategoryRepo subCategoryRepo;

  SubCategoryCubit({required this.subCategoryRepo})
      : super(SubCategoryInitial());

  Future<void> getSubCategories({
    required int subCategoryId,
    int page = 1,
  }) async {
    if (page == 1) {
      emit(SubCategoryLoading());
    } else {
      final currentState = state;
      SubCategoryModel? oldModel;
      if (currentState is SubCategorySuccess) {
        oldModel = currentState.subCategoryModel;
      } else if (currentState is SubCategoryLoadingMore) {
        oldModel = currentState.subCategoryModel;
      }

      if (oldModel != null) {
        emit(
          SubCategoryLoadingMore(
            subCategoryModel: oldModel,
            currentPage: page,
            lastPage: oldModel.meta?.lastPage ?? page,
          ),
        );
      }
    }

    final result = await subCategoryRepo.getSubCategories(
      subCategoryId: subCategoryId,
      page: page,
    );

    result.fold(
          (failure) => emit(SubCategoryFailure(failure)),
          (model) {
        if (page > 1) {
          final currentState = state;
          SubCategoryModel mergedModel = model;
          if (currentState is SubCategoryLoadingMore) {
            final oldList = currentState.subCategoryModel.data;
            mergedModel = SubCategoryModel(
              status: model.status,
              message: model.message,
              data: [...oldList, ...model.data],
              links: model.links,
              meta: model.meta,
            );
          }
          emit(
            SubCategorySuccess(
              subCategoryModel: mergedModel,
              currentPage: model.meta?.currentPage ?? page,
              lastPage: model.meta?.lastPage ?? page,
            ),
          );
        } else {
          emit(
            SubCategorySuccess(
              subCategoryModel: model,
              currentPage: model.meta?.currentPage ?? 1,
              lastPage: model.meta?.lastPage ?? 1,
            ),
          );
        }
      },
    );
  }

  void loadNextPage(int subCategoryId) {
    final currentState = state;
    if (currentState is SubCategorySuccess) {
      if (currentState.currentPage < currentState.lastPage) {
        getSubCategories(
          subCategoryId: subCategoryId,
          page: currentState.currentPage + 1,
        );
      }
    }
  }

  Future<void> refreshSubCategories(int subCategoryId) async {
    await getSubCategories(subCategoryId: subCategoryId, page: 1);
  }
}
