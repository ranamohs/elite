import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';
import '../manager/catalog_state.dart';
import '../manager/catalog_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CatalogTab extends StatelessWidget {
  final bool product, showProducts;
  final CatalogCubit cubit;
  final VoidCallback onTap;
  const CatalogTab({
    super.key,
    required this.product,
    required this.showProducts,
    required this.cubit,
    required this.onTap,
  });
  CatalogPage? catalogPage(CatalogState state) {
    if (state is CatalogSuccess) return state.catalogPage;
    if (state is CatalogLoadingMore) return state.catalogPage;
    if (state is CatalogFailure) return state.catalogPage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;
    return Expanded(
      child: BlocBuilder<CatalogCubit, CatalogState>(
        bloc: cubit,
        builder: (context, state) => InkWell(
          onTap: () => onTap(),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: showProducts == product
                  ? Colors.white
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '${product ? text('المنتجات', 'Products') : text('الخدمات', 'Services')} ${catalogPage(state) != null ? '(${catalogPage(state)!.total})' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: showProducts == product
                    ? AppColors.badgeTextGreen
                    : AppColors.subtitleGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
