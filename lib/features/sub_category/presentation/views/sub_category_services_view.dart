import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/databases/api/dio_consumer.dart';
import 'package:elite/core/databases/cache/secure_storage_helper.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/routes/app_router.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/core/state_management/network_connection_cubit/network_connection_cubit.dart';
import 'package:elite/core/widgets/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/models/sub_category_model.dart';
import '../../data/repos/sub_category_repo_impl.dart';
import '../manager/sub_category_cubit.dart';
import '../manager/sub_category_state.dart';
import '../widgets/sub_category_bottom_banner.dart';
import '../widgets/sub_category_breadcrumb.dart';
import '../widgets/sub_category_card_item.dart';
import '../widgets/sub_category_empty_widget.dart';

class SubCategoryServicesView extends StatelessWidget {
  final int subCategoryId;
  final String subCategoryArName;
  final String subCategoryEnName;
  final String? mainCategoryArName;
  final String? mainCategoryEnName;

  const SubCategoryServicesView({
    super.key,
    required this.subCategoryId,
    required this.subCategoryArName,
    required this.subCategoryEnName,
    this.mainCategoryArName,
    this.mainCategoryEnName,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final existingCubit = context.read<SubCategoryCubit?>();
      if (existingCubit != null) {
        return _SubCategoryServicesContent(
          subCategoryId: subCategoryId,
          subCategoryArName: subCategoryArName,
          subCategoryEnName: subCategoryEnName,
          mainCategoryArName: mainCategoryArName,
          mainCategoryEnName: mainCategoryEnName,
        );
      }
    } catch (_) {}

    SubCategoryCubit cubit;
    try {
      cubit = getIt<SubCategoryCubit>();
    } catch (_) {
      cubit = SubCategoryCubit(
        subCategoryRepo: SubCategoryRepoImpl(
          dioConsumer: getIt<DioConsumer>(),
          networkCubit: getIt<NetworkConnectionCubit>(),
          secureStorageHelper: getIt.isRegistered<SecureStorageHelper>()
              ? getIt<SecureStorageHelper>()
              : null,
        ),
      );
    }

    return BlocProvider<SubCategoryCubit>(
      create: (context) => cubit..getSubCategories(subCategoryId: subCategoryId),
      child: _SubCategoryServicesContent(
        subCategoryId: subCategoryId,
        subCategoryArName: subCategoryArName,
        subCategoryEnName: subCategoryEnName,
        mainCategoryArName: mainCategoryArName,
        mainCategoryEnName: mainCategoryEnName,
      ),
    );
  }
}

class _SubCategoryServicesContent extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryArName;
  final String subCategoryEnName;
  final String? mainCategoryArName;
  final String? mainCategoryEnName;

  const _SubCategoryServicesContent({
    required this.subCategoryId,
    required this.subCategoryArName,
    required this.subCategoryEnName,
    this.mainCategoryArName,
    this.mainCategoryEnName,
  });

  @override
  State<_SubCategoryServicesContent> createState() =>
      _SubCategoryServicesContentState();
}

class _SubCategoryServicesContentState
    extends State<_SubCategoryServicesContent> {
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
          .read<SubCategoryCubit>()
          .loadNextPage(widget.subCategoryId);
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
    final title = isAr ? widget.subCategoryArName : widget.subCategoryEnName;
    final mainCategoryTitle = isAr
        ? (widget.mainCategoryArName ?? 'سباكة')
        : (widget.mainCategoryEnName ?? 'Plumbing');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 18.w,
        title: Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => Navigator.of(context).maybePop(),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    isAr
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.arrow_back_ios_rounded,
                    size: 19.sp,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Breadcrumb: الرئيسية > سباكة > سخانات كهرباء
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
              child: SubCategoryBreadcrumb(
                isArabic: isAr,
                mainCategoryName: mainCategoryTitle,
                subCategoryName: title,
                onHomeTap: () => GoRouter.of(context).go(AppRouter.homePage),
                onMainCategoryTap: () => Navigator.of(context).maybePop(),
              ),
            ),

            // Level / Step Header: المستوى 3 من 4 • اختار نوع المشكلة أو الشغل
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 14.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      isAr ? 'المستوى 3 من 4' : 'Level 3 of 4',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF558B2F),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'اختار نوع المشكلة أو الشغل'
                          : 'Choose problem or job type',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: BlocBuilder<SubCategoryCubit, SubCategoryState>(
                builder: (context, state) {
                  if (state is SubCategoryLoading) {
                    return _buildLoadingShimmer();
                  }

                  if (state is SubCategoryFailure) {
                    return Center(
                      child: RetryWidget(
                        message: state.failure.errMessage,
                        onPressed: () {
                          context
                              .read<SubCategoryCubit>()
                              .refreshSubCategories(widget.subCategoryId);
                        },
                      ),
                    );
                  }

                  List<SubCategoryItem> items = [];
                  bool isLoadingMore = false;

                  if (state is SubCategorySuccess) {
                    items = state.subCategoryModel.data;
                  } else if (state is SubCategoryLoadingMore) {
                    items = state.subCategoryModel.data;
                    isLoadingMore = true;
                  }

                  if (items.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.homeHeaderGreen,
                      onRefresh: () async {
                        context
                            .read<SubCategoryCubit>()
                            .refreshSubCategories(widget.subCategoryId);
                      },
                      child: SubCategoryEmptyWidget(
                        isArabic: isAr,
                        subCategoryName: title,
                        onRefresh: () {
                          context
                              .read<SubCategoryCubit>()
                              .refreshSubCategories(widget.subCategoryId);
                        },
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.homeHeaderGreen,
                    onRefresh: () async {
                      context
                          .read<SubCategoryCubit>()
                          .refreshSubCategories(widget.subCategoryId);
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 16.h),
                      itemCount: items.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == items.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.homeHeaderGreen,
                              ),
                            ),
                          );
                        }

                        final item = items[index];
                        return SubCategoryCardItem(
                          item: item,
                          index: index,
                          isArabic: isAr,
                          onTap: () {},
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 16.h),
              child: SubCategoryBottomBanner(
                isArabic: isAr,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 90.h,
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
