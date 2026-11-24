import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/features/account/presentation/widgets/account_ui.dart';
import '../../data/models/assigned_requests_model.dart';
import 'technical_invoice_view.dart';

class TechnicalWorkInProgressView extends StatefulWidget {
  final AssignedRequest request;
  final DateTime? startedAt;
  final bool awaitingPayment;
  const TechnicalWorkInProgressView({
    super.key,
    required this.request,
    this.startedAt,
    this.awaitingPayment = false,
  });
  @override
  State<TechnicalWorkInProgressView> createState() =>
      _TechnicalWorkInProgressViewState();
}

class _TechnicalWorkInProgressViewState
    extends State<TechnicalWorkInProgressView> {
  Timer? timer;
  bool get completedUnpaid =>
      widget.awaitingPayment ||
          widget.request.statusValue.trim().toLowerCase() == 'completed_unpaid';
  final photos = <(Uint8List, String)>[];
  bool picking = false;

  @override
  void initState() {
    super.initState();

    if (!completedUnpaid && widget.startedAt != null)
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  String get elapsed {
    final startedAt = widget.startedAt;
    if (startedAt == null) return '—';
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    final duration = Duration(seconds: seconds < 0 ? 0 : seconds);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}';
  }

  Future<void> addPhoto() async {
    if (picking) return;
    final before = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(
                accountText(context, 'صورة قبل الشغل', 'Before work'),
              ),
              onTap: () => Navigator.pop(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(accountText(context, 'صورة بعد الشغل', 'After work')),
              onTap: () => Navigator.pop(context, false),
            ),
          ],
        ),
      ),
    );
    if (before == null || !mounted) return;
    setState(() => picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (mounted)
          setState(() => photos.add((bytes, before ? 'before' : 'after')));
      }
    } catch (_) {
      if (mounted)
        accountInfo(context, 'تعذر اختيار الصورة', 'Could not select image');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return AccountScaffold(
      title: accountText(
        context,
        'طلب #${request.code}',
        'Request #${request.code}',
      ),
      bottomBar: AccountSaveBar(
        label: accountText(
          context,
          completedUnpaid ? 'إنشاء الفاتورة' : 'إنهاء الشغل وإنشاء الفاتورة',
          completedUnpaid ? 'Create invoice' : 'Finish work and create invoice',
        ),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TechnicalInvoiceView(request: request),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 20.h),
        children: [
          Row(
            children: [
              stage(accountText(context, 'وصلت', 'Arrived'), false),
              SizedBox(width: 6.w),
              stage(
                accountText(
                  context,
                  completedUnpaid ? 'بانتظار الدفع' : 'جاري التنفيذ',
                  completedUnpaid ? 'Awaiting payment' : 'In progress',
                ),
                true,
              ),
              SizedBox(width: 6.w),
              stage(accountText(context, 'الفاتورة', 'Invoice'), false),
            ],
          ),
          SizedBox(height: 12.h),
          AccountCard(
            child: Column(
              children: [
                Text(
                  accountText(
                    context,
                    completedUnpaid ? 'حالة الطلب' : 'مدة منذ بدء الطلب',
                    completedUnpaid
                        ? 'Order status'
                        : 'Time since starting request',
                  ),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.subtitleGrey,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  completedUnpaid
                      ? (request.statusLabel.isNotEmpty
                      ? request.statusLabel
                      : accountText(
                    context,
                    'مكتملة غير مدفوعة الأجر',
                    'Completed, unpaid',
                  ))
                      : elapsed,
                  textDirection: completedUnpaid ? null : TextDirection.ltr,
                  style: TextStyle(
                    fontSize: completedUnpaid ? 16.sp : 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          AccountCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  accountText(
                    context,
                    'البنود المطلوبة من العميل',
                    'Items requested by customer',
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                ...request.products.map(
                      (product) => Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${product.title(isArabic(context))}${product.quantity == null ? '' : ' × ${product.quantity}'}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.subtitleGrey,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (product.totalPrice != null) ...[
                          SizedBox(width: 12.w),
                          Text(
                            product.totalPrice!.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.badgeBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  accountText(
                    context,
                    'لقيت أعطال تانية؟',
                    'Found other issues?',
                  ),
                  style: TextStyle(
                    color: AppColors.badgeTextGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  accountText(
                    context,
                    'راجع أي بنود إضافية مع العميل قبل تنفيذها.',
                    'Discuss additional items with the customer before carrying them out.',
                  ),
                  style: TextStyle(
                    color: AppColors.badgeTextGreen,
                    fontSize: 11.sp,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            accountText(
              context,
              'صور قبل وبعد الشغل',
              'Before and after photos',
            ),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: [
              ...photos.asMap().entries.map(
                    (entry) => SizedBox(
                  width: 82.w,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.memory(
                              entry.value.$1,
                              width: 82.w,
                              height: 82.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              tooltip: accountText(
                                context,
                                'حذف الصورة',
                                'Remove photo',
                              ),
                              onPressed: () =>
                                  setState(() => photos.removeAt(entry.key)),
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black38,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        accountText(
                          context,
                          entry.value.$2 == 'before' ? 'قبل' : 'بعد',
                          entry.value.$2 == 'before' ? 'Before' : 'After',
                        ),
                        style: TextStyle(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 82.w,
                height: 82.h,
                child: OutlinedButton(
                  onPressed: picking ? null : addPhoto,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.badgeTextGreen,
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: picking
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    accountText(context, '+ صورة', '+ Photo'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            accountText(
              context,
              'الصور المختارة محفوظة مؤقتًا في الصفحة ولم تُرفع بعد.',
              'Selected photos are temporarily kept on this page and have not been uploaded.',
            ),
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.subtitleGrey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget stage(String label, bool current) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: current ? AppColors.badgeBg : Colors.white,
        border: Border.all(
          color: current ? AppColors.primaryColor : AppColors.unselectedBorder,
        ),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          color: current ? AppColors.badgeTextGreen : AppColors.subtitleGrey,
          fontWeight: current ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}
