import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/routes/app_router.dart';
import '../../../../../../core/services/service_locator.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/deposit_receipt.dart';
import '../../data/repos/assigned_requests_repo.dart';
import '../manager/complete_request_cubit.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/functions/is_arabic.dart';
import '../../data/models/assigned_requests_model.dart';

class TechnicalWorkInProgressView extends StatefulWidget {
  final AssignedRequest request;
  final DateTime startedAt;
  const TechnicalWorkInProgressView({
    super.key,
    required this.request,
    required this.startedAt,
  });
  @override
  State<TechnicalWorkInProgressView> createState() =>
      _TechnicalWorkInProgressViewState();
}

class _TechnicalWorkInProgressViewState
    extends State<TechnicalWorkInProgressView> {
  late final Timer timer;
  final photos = <(Uint8List, String)>[];
  bool picking = false;
  bool pickingReceipt = false;
  DepositReceipt? receipt;
  late final CompleteRequestCubit completeCubit;
  @override
  void initState() {
    super.initState();
    completeCubit = CompleteRequestCubit(getIt<AssignedRequestsRepo>());
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    completeCubit.close();
    super.dispose();
  }

  String get elapsed {
    final seconds = DateTime.now().difference(widget.startedAt).inSeconds;
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

  Future<void> pickReceipt() async {
    if (pickingReceipt || completeCubit.state.loading) return;
    setState(() => pickingReceipt = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file != null) {
        final selected = DepositReceipt.fromBytes(await file.readAsBytes());
        if (mounted) setState(() => receipt = selected);
      }
    } on FormatException {
      if (mounted)
        accountInfo(
          context,
          'اختار صورة إيصال بصيغة JPG أو PNG أو WEBP',
          'Choose a JPG, PNG or WEBP receipt image',
        );
    } catch (_) {
      if (mounted)
        accountInfo(
          context,
          'تعذر اختيار صورة الإيصال',
          'Could not select receipt image',
        );
    } finally {
      if (mounted) setState(() => pickingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return BlocConsumer<CompleteRequestCubit, CompleteRequestState>(
      bloc: completeCubit,
      listener: (context, state) {
        if (state.error != null)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        if (state.completed) {
          timer.cancel();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message?.isNotEmpty == true
                    ? state.message!
                    : accountText(
                  context,
                  'تم إنهاء الطلب بنجاح',
                  'Request completed successfully',
                ),
              ),
            ),
          );
          context.go(AppRouter.technicalHome);
        }
      },
      builder: (context, state) => AccountScaffold(
        title: accountText(
          context,
          'طلب #${request.code}',
          'Request #${request.code}',
        ),
        bottomBar: AccountSaveBar(
          label: accountText(
            context,
            'إنهاء الشغل وإنشاء الفاتورة',
            'Finish work and create invoice',
          ),
          loading: state.loading,
          onPressed: pickingReceipt
              ? null
              : () => receipt == null
              ? pickReceipt()
              : completeCubit.complete(request.id, receipt!),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 20.h),
          children: [
            AccountCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    accountText(
                      context,
                      'إيصال الإيداع (مطلوب)',
                      'Deposit receipt (required)',
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  if (receipt != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.memory(
                        receipt!.bytes,
                        height: 160.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: state.loading || pickingReceipt
                        ? null
                        : pickReceipt,
                    icon: pickingReceipt
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(
                      accountText(
                        context,
                        receipt == null
                            ? 'اختيار صورة الإيصال'
                            : 'تغيير صورة الإيصال',
                        receipt == null
                            ? 'Select receipt image'
                            : 'Change receipt image',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                stage(accountText(context, 'وصلت', 'Arrived'), false),
                SizedBox(width: 6.w),
                stage(
                  accountText(context, 'جاري التنفيذ', 'In progress'),
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
                      'مدة منذ بدء الطلب',
                      'Time since starting request',
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.subtitleGrey,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    elapsed,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 26.sp,
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
