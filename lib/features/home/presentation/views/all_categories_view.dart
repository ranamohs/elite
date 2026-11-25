import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/routes/app_router.dart';
import 'package:elite/core/widgets/app_bars.dart';
import 'package:elite/features/home/data/models/categories_models/categories_model.dart';
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_cubit.dart';
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/category_card_item.dart';

class AllCategoriesView extends StatefulWidget {
  const AllCategoriesView({super.key});

  @override
  State<AllCategoriesView> createState() => _AllCategoriesViewState();
}

class _AllCategoriesViewState extends State<AllCategoriesView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CategoriesCubit>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCategoryDetails(CategoryData category) {
    GoRouter.of(context).push(
      AppRouter.categoryDetailsView,
      extra: {
        'categoryId': category.id,
        'arName': category.name.ar,
        'enName': category.name.en,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAr = isArabic(context);

    return Scaffold(
      backgroundColor:AppColors.homeBackground,
      appBar: PrimaryAppBar(
        title: AppStrings.allCategories.tr(),
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            List<CategoryData> allCategories = [];
            bool isLoading = false;
            bool isLoadingMore = false;
            int totalCategories = 0;

            if (state is CategoriesLoading) {
              isLoading = true;
            } else if (state is CategoriesSuccess) {
              allCategories = state.categoriesModel.data;
              totalCategories = state.categoriesModel.meta.total;
            } else if (state is CategoriesLoadingMore) {
              allCategories = state.categoriesModel.data;
              totalCategories = state.categoriesModel.meta.total;
              isLoadingMore = true;
            }

            final query = _searchQuery.trim().toLowerCase();
            final filteredCategories = allCategories.where((category) {
              if (query.isEmpty) return true;
              final nameAr = category.name.ar.toLowerCase();
              final nameEn = category.name.en.toLowerCase();
              return nameAr.contains(query) || nameEn.contains(query);
            }).toList();

            final displayTotal = totalCategories > 0
                ? totalCategories
                : (allCategories.isNotEmpty ? allCategories.length : 15);

            return RefreshIndicator(
              color: AppColors.homeHeaderGreen,
              onRefresh: () async {
                context.read<CategoriesCubit>().refreshCategories();
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Search Bar Header matching design
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.08),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: AppStrings.searchInCategories.tr(
                              namedArgs: {'count': '$displayTotal'},
                            ),
                            hintStyle: TextStyle(
                              fontSize: 13.sp,
                              color: const Color(0xFF9E9E9E),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF9E9E9E),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Categories Grid / Loading / Empty
                  if (isLoading)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.88,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return Shimmer.fromColors(
                              baseColor: AppColors.loadingEffectColor,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            );
                          },
                          childCount: 15,
                        ),
                      ),
                    )
                  else if (filteredCategories.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 56.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                AppStrings.noCategoriesMatchingSearch.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 0.88,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final category = filteredCategories[index];
                            final name = isAr
                                ? category.name.ar
                                : category.name.en;
                            return CategoryCardItem(
                              title: name,
                              imageUrl: category.image,
                              topBgColor: getCategoryCardColor(index),
                              onTap: () => _navigateToCategoryDetails(category),
                            );
                          },
                          childCount: filteredCategories.length,
                        ),
                      ),
                    ),

                  if (isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.homeHeaderGreen,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
