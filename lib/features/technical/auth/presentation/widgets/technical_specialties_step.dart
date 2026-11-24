import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/functions/is_arabic.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../../../home/presentation/manager/categories_cubit/categories_cubit.dart';
import '../../../../home/presentation/manager/categories_cubit/categories_state.dart';
import '../../../auth/data/models/technical_registration_request.dart';

class TechnicalSpecialtiesStep extends StatefulWidget {
  final CategoriesCubit categories;
  final Set<int> selectedCategories;
  final Set<String> days;
  final List<String> areas;
  final ValueChanged<int> onCategory;
  final ValueChanged<String> onDay, onAddArea, onRemoveArea;
  const TechnicalSpecialtiesStep({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.days,
    required this.areas,
    required this.onCategory,
    required this.onDay,
    required this.onAddArea,
    required this.onRemoveArea,
  });
  @override
  State<TechnicalSpecialtiesStep> createState() =>
      _TechnicalSpecialtiesStepState();
}

class _TechnicalSpecialtiesStepState extends State<TechnicalSpecialtiesStep> {
  final area = TextEditingController();
  @override
  void dispose() {
    area.dispose();
    super.dispose();
  }

  void addArea() {
    final value = area.text.trim();
    if (value.isNotEmpty) {
      widget.onAddArea(value);
      area.clear();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        accountText(
          context,
          'تخصصك (ممكن تختار أكتر من واحد)',
          'Your specialties (select one or more)',
        ),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 12.h),
      BlocBuilder<CategoriesCubit, CategoriesState>(
        bloc: widget.categories,
        builder: (context, state) {
          if (state is CategoriesFailure)
            return TextButton(
              onPressed: () => widget.categories.getCategories(),
              child: Text(state.failure.errMessage),
            );
          final model = switch (state) {
            CategoriesSuccess() => state.categoriesModel,
            CategoriesLoadingMore() => state.categoriesModel,
            _ => null,
          };
          if (model == null)
            return const Center(child: CircularProgressIndicator());
          return Column(
            children: [
              if (model.data.isEmpty)
                Text(
                  accountText(
                    context,
                    'لا توجد تخصصات متاحة حاليًا',
                    'No specialties available yet',
                  ),
                ),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: model.data
                    .map(
                      (category) => FilterChip(
                    label: Text(
                      isArabic(context)
                          ? category.name.ar
                          : category.name.en,
                    ),
                    selected: widget.selectedCategories.contains(
                      category.id,
                    ),
                    onSelected: (_) => widget.onCategory(category.id),
                    selectedColor: AppColors.primaryColor,
                  ),
                )
                    .toList(),
              ),
              if (state is CategoriesLoadingMore)
                const CircularProgressIndicator(strokeWidth: 2)
              else if (model.meta.currentPage < model.meta.lastPage)
                TextButton(
                  onPressed: widget.categories.loadNextPage,
                  child: Text(
                    accountText(context, 'تخصصات أكتر', 'More specialties'),
                  ),
                ),
            ],
          );
        },
      ),
      SizedBox(height: 24.h),
      Text(
        accountText(context, 'مناطق الشغل', 'Work areas'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10.h),
      TextField(
        controller: area,
        onSubmitted: (_) => addArea(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: accountText(
            context,
            'اكتب المنطقة واضغط +',
            'Enter an area and tap +',
          ),
          suffixIcon: IconButton(
            onPressed: addArea,
            icon: const Icon(Icons.add_circle_outline),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
      SizedBox(height: 8.h),
      Wrap(
        spacing: 8.w,
        children: widget.areas
            .map(
              (value) => InputChip(
            label: Text(value),
            onDeleted: () => widget.onRemoveArea(value),
            backgroundColor: AppColors.badgeBg,
          ),
        )
            .toList(),
      ),
      SizedBox(height: 24.h),
      Text(
        accountText(context, 'أيام الشغل', 'Work days'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10.h),
      Wrap(
        spacing: 6.w,
        runSpacing: 6.h,
        children: List.generate(7, (i) {
          final ar = [
            'السبت',
            'الأحد',
            'الاثنين',
            'الثلاثاء',
            'الأربعاء',
            'الخميس',
            'الجمعة',
          ];
          final en = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
          final code = TechnicalRegistrationRequest.dayCodes[i];
          return FilterChip(
            label: Text(isArabic(context) ? ar[i] : en[i]),
            selected: widget.days.contains(code),
            onSelected: (_) => widget.onDay(code),
            selectedColor: AppColors.primaryColor,
          );
        }),
      ),
    ],
  );
}
