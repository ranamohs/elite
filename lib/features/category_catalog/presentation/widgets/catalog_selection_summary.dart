import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/functions/is_arabic.dart';
import '../../data/models/catalog_model.dart';
import '../../../../core/constants/app_styles.dart';

class CatalogSelectionSummary extends StatelessWidget {
  final List<CatalogItem> items;
  final Map<String, int> quantities;
  final String totalLabel;
  const CatalogSelectionSummary({
    super.key,
    required this.items,
    required this.quantities,
    required this.totalLabel,
  });

  @override
  Widget build(BuildContext context) {
    final ar = isArabic(context);
    String text(String arabic, String english) => ar ? arabic : english;
    return SafeArea(
      child: Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text('ملخص الاختيارات', 'Selection summary'),
                style: AppStyles.styleMedium16(context),
              ),
              SizedBox(height: 12.h),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .5,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: items
                      .map(
                        (item) => ListTile(
                      title: Text(item.title(ar)),
                      subtitle: Text(
                        '${quantities[item.key]} × ${item.priceLabel}',
                      ),
                      leading: Icon(
                        item.isProduct
                            ? Icons.shopping_bag_outlined
                            : Icons.home_repair_service_outlined,
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
              const Divider(),
              Text('${text('الإجمالي', 'Total')}: $totalLabel'),
            ],
          ),
        ),
      ),
    );
  }
}
