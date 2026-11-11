import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:elite/core/constants/app_strings.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/features/home/data/models/categories_models/categories_model.dart';
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_cubit.dart';
import 'package:elite/features/home/presentation/manager/categories_cubit/categories_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../core/constants/app_styles.dart';
import 'category_card_item.dart';

class ServiceModelItem {
  final String title;
  final String iconAsset;
  final String? iconNetworkUrl;
  final Color topBgColor;
  final dynamic categoryId;

  const ServiceModelItem({
    required this.title,
    required this.iconAsset,
    this.iconNetworkUrl,
    required this.topBgColor,
    this.categoryId,
  });
}

class HomeCategoriesSection extends StatelessWidget {
  final List<ServiceModelItem>? customServices;
  final void Function(ServiceModelItem service)? onServiceTap;
  final VoidCallback? onViewAllTap;

  const HomeCategoriesSection({
    super.key,
    this.customServices,
    this.onServiceTap,
    this.onViewAllTap,
  });

  void _onCategoryTapped(BuildContext context, CategoryData category) {
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

    if (customServices != null) {
      return _buildCustomServices(context, customServices!);
    }

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        List<CategoryData> categories = [];
        bool isLoading = false;
        int totalCount = 0;

        if (state is CategoriesLoading) {
          isLoading = true;
        } else if (state is CategoriesSuccess) {
          categories = state.categoriesModel.data;
          totalCount = state.categoriesModel.meta.total;
        } else if (state is CategoriesLoadingMore) {
          categories = state.categoriesModel.data;
          totalCount = state.categoriesModel.meta.total;
        }

        final displayCategories = categories.take(6).toList();
        final displayTotal = totalCount > 0
            ? totalCount
            : (categories.isNotEmpty ? categories.length : 15);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.categories.tr(),
                      style: AppStyles.styleMedium18(context).copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.titleDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: onViewAllTap ??
                              () {
                            GoRouter.of(context).push(AppRouter.allCategoriesView);
                          },
                      child: Text(
                        isAr
                            ? 'كل الاقسام ($displayTotal)'
                            : 'All Categories ($displayTotal)',
                        style: AppStyles.styleMedium18(context).copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.homeContractBadgeGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            if (isLoading)
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
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
              )
            else if (displayCategories.isEmpty)
              const SizedBox.shrink()
            else
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: displayCategories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final item = displayCategories[index];
                  final title = isAr ? item.name.ar : item.name.en;
                  return CategoryCardItem(
                    title: title,
                    imageUrl: item.image,
                    topBgColor: getCategoryCardColor(index),
                    onTap: () => _onCategoryTapped(context, item),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildCustomServices(
      BuildContext context, List<ServiceModelItem> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppStrings.categories.tr(),
                style: AppStyles.styleMedium18(context).copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.titleDark,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap ??
                        () {
                      GoRouter.of(context).push(AppRouter.allCategoriesView);
                    },
                child: Text(
                  'كل الاقسام (${services.length > 6 ? services.length : 15})',
                  style: AppStyles.styleMedium18(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.homeContractBadgeGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final item = services[index];
            return GestureDetector(
              onTap: () {
                if (onServiceTap != null) {
                  onServiceTap!(item);
                } else {
                  GoRouter.of(context).push(AppRouter.allCategoriesView);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.04),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: item.topBgColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Image.asset(
                              item.iconAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16.r),
                            bottomRight: Radius.circular(16.r),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.titleDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
