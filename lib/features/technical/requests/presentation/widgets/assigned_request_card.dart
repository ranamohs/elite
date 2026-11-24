import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/functions/is_arabic.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/assigned_requests_model.dart';

class AssignedRequestCard extends StatelessWidget {
  final AssignedRequest request;
  final bool prominent;
  final bool busy;
  final VoidCallback onDetails;
  final VoidCallback? onAccept, onReject;
  const AssignedRequestCard({
    super.key,
    required this.request,
    required this.onDetails,
    this.prominent = false,
    this.busy = false,
    this.onAccept,
    this.onReject,
  });
  @override
  Widget build(BuildContext context) {
    final title = request.title(isArabic(context));
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: prominent
              ? AppColors.primaryColor
              : AppColors.unselectedBorder,
          width: prominent ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title.isEmpty
                      ? accountText(
                    context,
                    'طلب #${request.code}',
                    'Request #${request.code}',
                  )
                      : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: request.isCanceled
                        ? const Color(0xFFFFEDE7)
                        : request.isClosed
                        ? AppColors.badgeBg
                        : const Color(0xFFE8F1FF),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    request.statusLabel.isNotEmpty
                        ? request.statusLabel
                        : request.statusValue,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: request.isCanceled
                          ? Colors.deepOrange
                          : request.isClosed
                          ? AppColors.badgeTextGreen
                          : Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '#${request.code}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.subtitleGrey),
          ),
          if (request.customerDate?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 15,
                  color: AppColors.subtitleGrey,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    request.customerDate!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.subtitleGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (prominent && request.address?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.subtitleGrey,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    request.address!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.subtitleGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (request.itemsTotal != null) ...[
            SizedBox(height: 12.h),
            Text(
              '${accountText(context, 'قيمة البنود', 'Items total')}: ${request.itemsTotal!.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.badgeTextGreen,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (prominent && request.statusValue == 'assigned_to_technician') ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Tooltip(
                    message: accountText(
                      context,
                      'قبول الطلب',
                      'Accept request',
                    ),
                    child: FilledButton(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        disabledBackgroundColor: AppColors.primaryColor
                            .withValues(alpha: .45),
                        disabledForegroundColor: Colors.white,
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: busy
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(accountText(context, 'قبول الطلب', 'Accept')),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Tooltip(
                    message: accountText(
                      context,
                      'رفض الطلب',
                      'Decline request',
                    ),
                    child: TextButton(
                      onPressed: onReject,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEDE7),
                        disabledForegroundColor: Colors.deepOrange.withValues(
                          alpha: .5,
                        ),
                        foregroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(accountText(context, 'رفض', 'Reject')),
                    ),
                  ),
                ),
              ],
            ),
          ],
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onDetails,
              child: Text(
                accountText(context, 'عرض التفاصيل', 'View details'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.badgeTextGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
