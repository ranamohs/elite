import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/features/account/presentation/widgets/account_ui.dart';
import '../../data/models/technical_request_history.dart';

class TechnicalHistoryCard extends StatelessWidget {
  final TechnicalHistoryEntry entry;
  final VoidCallback onDetails;
  const TechnicalHistoryCard({
    super.key,
    required this.entry,
    required this.onDetails,
  });
  @override
  Widget build(BuildContext context) {
    final request = entry.request;
    final status = request.statusLabel.trim().isNotEmpty
        ? request.statusValue
        : entry.unpaid
        ? accountText(context, 'مكتملة غير مدفوعة الأجر', 'Completed, unpaid')
        : entry.started
        ? accountText(context, 'جاري التنفيذ', 'In progress')
        : entry.source == TechnicalRequestSource.received
        ? accountText(context, 'تم استلام الطلب', 'Received')
        : accountText(context, 'حالة غير متاحة', 'Status unavailable');
    final color = entry.canceled
        ? Colors.deepOrange
        : entry.started || entry.unpaid
        ? AppColors.badgeTextGreen
        : Colors.blue;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: AccountCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.title(isArabic(context)),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(fontSize: 9.sp, color: color),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              '#${request.code}${request.customerDate?.isNotEmpty == true ? ' · ${request.customerDate}' : ''}${request.itemsTotal == null ? '' : ' · ${request.itemsTotal!.toStringAsFixed(2)}'}',
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.subtitleGrey,
                height: 1.5,
              ),
            ),
            if (request.customerName?.isNotEmpty == true ||
                request.address?.isNotEmpty == true) ...[
              SizedBox(height: 8.h),
              Text(
                [request.customerName, request.address]
                    .whereType<String>()
                    .where((e) => e.trim().isNotEmpty)
                    .join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.sp, height: 1.5),
              ),
            ],
            SizedBox(height: 10.h),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!entry.canceled &&
                    entry.tab != TechnicalRequestTab.completed ||
                    entry.unpaid)
                  TextButton(
                    onPressed: onDetails,
                    child: Text(
                      accountText(
                        context,
                        entry.started || entry.unpaid
                            ? 'كمّل الطلب'
                            : 'ابدأ العمل',
                        entry.started || entry.unpaid
                            ? 'Continue request'
                            : 'Start job',
                      ),
                      style: TextStyle(
                        color: AppColors.badgeTextGreen,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: onDetails,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.subtitleGrey,
                  ),
                  child: Text(
                    accountText(context, 'التفاصيل', 'Details'),
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
