import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/databases/cache/secure_storage_helper.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/core/widgets/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/routes/app_router.dart';
import '../../data/models/category_services_model.dart';
import '../../data/repos/category_services_repo_impl.dart';
import '../manager/category_services_cubit.dart';
import '../manager/category_services_state.dart';
import '../widgets/category_empty_services_widget.dart';
import '../widgets/category_service_card_item.dart';

class CategoryServicesView extends StatelessWidget {
  final int categoryId;
  final String categoryArName;
  final String categoryEnName;

  const CategoryServicesView({
    super.key,
    required this.categoryId,
    required this.categoryArName,
    required this.categoryEnName,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final existingCubit = context.read<CategoryServicesCubit?>();
      if (existingCubit != null) {
        return _CategoryServicesContent(
          categoryId: categoryId,
          categoryArName: categoryArName,
          categoryEnName: categoryEnName,
        );
      }
    } catch (_) {}

    CategoryServicesCubit cubit;
    try {
      cubit = getIt<CategoryServicesCubit>();
    } catch (_) {
      cubit = CategoryServicesCubit(
        categoryServicesRepo: CategoryServicesRepoImpl(
          dioConsumer: getIt<DioConsumer>(),
          networkCubit: getIt<NetworkConnectionCubit>(),
          secureStorageHelper: getIt.isRegistered<SecureStorageHelper>()
              ? getIt<SecureStorageHelper>()
              : null,
        ),
      );
    }

    return BlocProvider<CategoryServicesCubit>(
      create: (context) => cubit..getCategoryServices(categoryId: categoryId),
      child: _CategoryServicesContent(
        categoryId: categoryId,
        categoryArName: categoryArName,
        categoryEnName: categoryEnName,
      ),
    );
  }
}

class _CategoryServicesContent extends StatefulWidget {
  final int categoryId;
  final String categoryArName;
  final String categoryEnName;

  const _CategoryServicesContent({
    required this.categoryId,
    required this.categoryArName,
    required this.categoryEnName,
  });

  @override
  State<_CategoryServicesContent> createState() =>
      _CategoryServicesContentState();
}

class _CategoryServicesContentState extends State<_CategoryServicesContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<CategoryServicesCubit>()
          .loadNextPage(widget.categoryId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic(context);
    final title = isAr ? widget.categoryArName : widget.categoryEnName;

    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 18.w,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () => Navigator.of(context).maybePop(),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
              Icons.arrow_back_ios_rounded,
                  size: 19.sp,
                  color: AppColors.homeContractBadgeGreen,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style:AppStyles.styleMedium16(context).copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.homeContractBadgeGreen,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
              builder: (context, state) {
                if (state is CategoryServicesLoading) {
                  return _buildLoadingShimmer();
                }

                if (state is CategoryServicesFailure) {
                  return Center(
                    child: RetryWidget(
                      message: state.failure.errMessage,
                      onPressed: () {
                        context
                            .read<CategoryServicesCubit>()
                            .refreshServices(widget.categoryId);
                      },
                    ),
                  );
                }

                List<CategoryServiceItem> services = [];
                bool isLoadingMore = false;

                if (state is CategoryServicesSuccess) {
                  services = state.servicesModel.data;
                } else if (state is CategoryServicesLoadingMore) {
                  services = state.servicesModel.data;
                  isLoadingMore = true;
                }

                if (services.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.homeHeaderGreen,
                    onRefresh: () async {
                      context
                          .read<CategoryServicesCubit>()
                          .refreshServices(widget.categoryId);
                    },
                    child: CategoryEmptyServicesWidget(
                      isArabic: isAr,
                      categoryName: title,
                      onRefresh: () {
                        context
                            .read<CategoryServicesCubit>()
                            .refreshServices(widget.categoryId);
                      },
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.homeHeaderGreen,
                  onRefresh: () async {
                    context
                        .read<CategoryServicesCubit>()
                        .refreshServices(widget.categoryId);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
                    itemCount: services.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == services.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.homeHeaderGreen,
                            ),
                          ),
                        );
                      }

                      final item = services[index];
                      String? imageUrl = item.image ?? item.thumbnail;
                      if (imageUrl == null || imageUrl.isEmpty) {
                        if (item.gallery.isNotEmpty &&
                            item.gallery.first.url != null) {
                          imageUrl = item.gallery.first.url;
                        }
                      }

                      return CategoryServiceCardItem(
                        service: item,
                        index: index,
                        isArabic: isAr,
                        imageUrl: imageUrl,
                        onTap: () {
                          GoRouter.of(context).push(
                            AppRouter.subCategoryServicesView,
                            extra: {
                              'subCategoryId': item.id,
                              'subCategoryArName': item.name.ar,
                              'subCategoryEnName': item.name.en,
                              'mainCategoryArName': widget.categoryArName,
                              'mainCategoryEnName': widget.categoryEnName,
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 80.h,
          child: Shimmer.fromColors(
            baseColor: AppColors.loadingEffectColor,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
