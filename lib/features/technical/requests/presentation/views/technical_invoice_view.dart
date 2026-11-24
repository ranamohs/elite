import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/functions/is_arabic.dart';
import 'package:elite/core/routes/app_router.dart';
import 'package:elite/core/services/service_locator.dart';
import 'package:elite/features/account/presentation/widgets/account_ui.dart';
import 'package:elite/features/category_catalog/data/models/catalog_model.dart';
import '../../data/models/assigned_requests_model.dart';
import '../../data/models/deposit_receipt.dart';
import '../../data/models/new_payment_request.dart';
import '../../data/repos/assigned_requests_repo.dart';
import '../manager/payment_request/payment_request_cubit.dart';
import 'invoice_service_picker_view.dart';

class TechnicalInvoiceView extends StatefulWidget {
  final AssignedRequest request;
  const TechnicalInvoiceView({super.key, required this.request});
  @override
  State<TechnicalInvoiceView> createState() => _TechnicalInvoiceViewState();
}

class _TechnicalInvoiceViewState extends State<TechnicalInvoiceView> {
  late final PaymentRequestCubit cubit;
  final selected = <int>{};
  final added = <CatalogItem>[];
  final materials = <(String, double)>[];
  final notes = TextEditingController(), visit = TextEditingController();
  DepositReceipt? receipt;
  String accountType = 'cash';
  bool picking = false;
  @override
  void initState() {
    super.initState();
    cubit = PaymentRequestCubit(getIt<AssignedRequestsRepo>());
    for (var i = 0; i < widget.request.products.length; i++) {
      final price = widget.request.products[i].totalPrice;
      if (price != null && price.isFinite && price >= 0) selected.add(i);
    }
  }

  @override
  void dispose() {
    cubit.close();
    notes.dispose();
    visit.dispose();
    super.dispose();
  }

  double get servicesTotal =>
      selected.fold<double>(
        0,
            (sum, i) => sum + widget.request.products[i].totalPrice!,
      ) +
          added.fold<double>(0, (sum, e) => sum + e.price);
  double get materialsTotal =>
      materials.fold<double>(0, (sum, e) => sum + e.$2);
  double? parse(String text) => double.tryParse(
    text.trim().replaceAll('٫', '.').replaceAllMapped(RegExp('[٠-٩۰-۹]'), (m) {
      final code = m[0]!.codeUnitAt(0);
      return '${code - (code >= 0x6f0 ? 0x6f0 : 0x660)}';
    }),
  );
  double get visitAmount => parse(visit.text) ?? 0;
  double get total => servicesTotal + materialsTotal + visitAmount;
  String money(double value) => value.toStringAsFixed(2);
  Future<void> addService() async {
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(builder: (_) => const InvoiceServicePickerView()),
    );
    if (!mounted || item == null) return;
    final original = widget.request.products.indexWhere(
          (p) => p.type == 'service' && p.id == item.id,
    );
    if (original >= 0 &&
        widget.request.products[original].totalPrice != null &&
        widget.request.products[original].totalPrice!.isFinite) {
      setState(() => selected.add(original));
      return;
    }
    if (!added.any((e) => e.id == item.id)) setState(() => added.add(item));
  }

  Future<void> addMaterial() async {
    final name = TextEditingController(), price = TextEditingController();
    final key = GlobalKey<FormState>();
    final value = await showDialog<(String, double)>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accountText(context, 'إضافة خامة', 'Add material')),
        content: Form(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  labelText: accountText(
                    context,
                    'اسم الخامة',
                    'Material name',
                  ),
                ),
                validator: (v) => v?.trim().isNotEmpty == true
                    ? null
                    : accountText(
                  context,
                  'اكتب اسم الخامة',
                  'Enter material name',
                ),
              ),
              TextFormField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: accountText(context, 'التكلفة', 'Cost'),
                ),
                validator: (v) {
                  final amount = parse(v ?? '');
                  return amount != null && amount.isFinite && amount >= 0
                      ? null
                      : accountText(
                    context,
                    'اكتب قيمة صحيحة',
                    'Enter a valid amount',
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(accountText(context, 'إلغاء', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (key.currentState!.validate())
                Navigator.pop(context, (name.text.trim(), parse(price.text)!));
            },
            child: Text(accountText(context, 'إضافة', 'Add')),
          ),
        ],
      ),
    );
    // Dialog fields are disposed after their route animation finishes.
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      name.dispose();
      price.dispose();
    });
    if (mounted && value != null) setState(() => materials.add(value));
  }

  Future<void> pickReceipt() async {
    if (picking || cubit.state.loading) return;
    setState(() => picking = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (file != null) {
        final value = DepositReceipt.fromBytes(await file.readAsBytes());
        if (mounted) setState(() => receipt = value);
      }
    } on FormatException {
      if (mounted)
        accountInfo(
          context,
          'اختار صورة JPG أو PNG أو WEBP',
          'Choose a JPG, PNG or WEBP image',
        );
    } catch (_) {
      if (mounted)
        accountInfo(context, 'تعذر اختيار الإيصال', 'Could not select receipt');
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  void send() {
    if (picking || cubit.state.loading) return;
    final fee = parse(visit.text);
    if (visit.text.trim().isNotEmpty &&
        (fee == null || !fee.isFinite || fee < 0)) {
      accountInfo(context, 'اكتب رسوم زيارة صحيحة', 'Enter a valid visit fee');
      return;
    }
    if (!total.isFinite ||
        total <= 0 ||
        double.parse(total.toStringAsFixed(2)) <= 0) {
      accountInfo(
        context,
        'اختار البنود واكتب إجماليًا أكبر من صفر',
        'Select items for a total greater than zero',
      );
      return;
    }
    if (receipt == null) {
      accountInfo(
        context,
        'اختار صورة إيصال الدفع أولًا',
        'Select the payment receipt first',
      );
      return;
    }
    final ids = <int>[
      for (final i in selected)
        if (widget.request.products[i].type == 'service' &&
            widget.request.products[i].id != null)
          widget.request.products[i].id!,
      ...added.map((e) => e.id),
    ];
    final details = [
      notes.text.trim(),
      ...materials.map(
            (e) =>
        '${accountText(context, 'خامة', 'Material')}: ${e.$1} — ${money(e.$2)}',
      ),
      if (visitAmount > 0)
        '${accountText(context, 'رسوم الزيارة', 'Visit fee')}: ${money(visitAmount)}',
    ].where((e) => e.isNotEmpty).join('\n');
    cubit.send(
      widget.request.id,
      NewPaymentRequest(
        amount: total,
        serviceIds: ids,
        notes: details,
        accountType: accountType,
        receipt: receipt!,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) => BlocConsumer<PaymentRequestCubit, PaymentRequestState>(
    bloc: cubit,
    listener: (context, state) {
      if (state.error != null)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
      if (state.sent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.message?.isNotEmpty == true
                  ? state.message!
                  : accountText(
                context,
                'تم إرسال طلب الدفع',
                'Payment request sent',
              ),
            ),
          ),
        );
        context.go(AppRouter.technicalHome);
      }
    },
    builder: (context, state) => PopScope(
      canPop: !state.loading,
      child: AccountScaffold(
        title: accountText(context, 'إنشاء الفاتورة', 'Create invoice'),
        bottomBar: AccountSaveBar(
          label: accountText(
            context,
            'إرسال الفاتورة للعميل · ${money(total)}',
            'Send invoice · ${money(total)}',
          ),
          loading: state.loading,
          onPressed: picking ? null : send,
        ),
        body: AbsorbPointer(
          absorbing: state.loading,
          child: ListView(
            padding: EdgeInsets.all(18.w),
            children: [
              section(
                accountText(
                  context,
                  'البنود المطلوبة: علّم على اللي اتنفّذ',
                  'Requested items: select completed work',
                ),
                [
                  ...widget.request.products.asMap().entries.map(
                        (entry) => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.primaryColor,
                      value: selected.contains(entry.key),
                      onChanged: entry.value.totalPrice == null
                          ? null
                          : (value) => setState(() {
                        if (value == true)
                          selected.add(entry.key);
                        else
                          selected.remove(entry.key);
                      }),
                      title: Text(
                        '${entry.value.title(isArabic(context))}${entry.value.quantity == null ? '' : ' × ${entry.value.quantity}'}',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      secondary: Text(
                        entry.value.totalPrice == null
                            ? '—'
                            : money(entry.value.totalPrice!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.badgeTextGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // section(
              //   accountText(
              //     context,
              //     'بنود مضافة من الموقع',
              //     'Services added on site',
              //   ),
              //   [
              //     ...added.map(
              //           (item) => ListTile(
              //         contentPadding: EdgeInsets.zero,
              //         title: Text(
              //           item.title(isArabic(context)),
              //           style: TextStyle(fontSize: 12.sp),
              //         ),
              //         subtitle: Text(
              //           accountText(context, 'مضاف من الموقع', 'Added on site'),
              //           style: TextStyle(fontSize: 10.sp, color: Colors.blue),
              //         ),
              //         trailing: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text(money(item.price)),
              //             IconButton(
              //               onPressed: () => setState(() => added.remove(item)),
              //               icon: const Icon(Icons.close),
              //               tooltip: accountText(context, 'حذف', 'Remove'),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     OutlinedButton(
              //       onPressed: addService,
              //       style: OutlinedButton.styleFrom(
              //         minimumSize: Size(double.infinity, 44.h),
              //         foregroundColor: AppColors.badgeTextGreen,
              //         side: const BorderSide(color: AppColors.primaryColor),
              //       ),
              //       child: Text(
              //         accountText(
              //           context,
              //           '+ إضافة خدمة من الكتالوج',
              //           '+ Add catalog service',
              //         ),
              //       ),
              //     ),
              //   ],
              //   border: Colors.blueAccent,
              // ),
              section(
                accountText(
                  context,
                  'الخامات وقطع الغيار',
                  'Materials and spare parts',
                ),
                [
                  ...materials.asMap().entries.map(
                        (e) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.value.$1),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(money(e.value.$2)),
                          IconButton(
                            onPressed: () =>
                                setState(() => materials.removeAt(e.key)),
                            icon: const Icon(Icons.close),
                            tooltip: accountText(context, 'حذف', 'Remove'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: addMaterial,
                      child: Text(
                        accountText(context, '+ إضافة خامة', '+ Add material'),
                      ),
                    ),
                  ),
                  TextField(
                    controller: visit,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: accountText(
                        context,
                        'رسوم الزيارة (اختياري)',
                        'Visit fee (optional)',
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.badgeBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    summary(
                      accountText(context, 'البنود', 'Items'),
                      servicesTotal,
                    ),
                    // summary(
                    //   accountText(context, 'الخامات', 'Materials'),
                    //   materialsTotal,
                    // ),
                    summary(
                      accountText(context, 'رسوم الزيارة', 'Visit fee'),
                      visitAmount,
                    ),
                    const Divider(),
                    summary(
                      accountText(context, 'الإجمالي', 'Total'),
                      total,
                      bold: true,
                    ),
                  ],
                ),
              ),
              section(
                accountText(context, 'بيانات التحصيل', 'Payment details'),
                [
                  DropdownButtonFormField<String>(
                    initialValue: accountType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: accountText(
                        context,
                        'طريقة التحصيل',
                        'Payment method',
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'cash',
                        child: Text(accountText(context, 'كاش', 'Cash')),
                      ),
                      DropdownMenuItem(
                        value: 'employee_transfer',
                        child: Text(
                          accountText(
                            context,
                            'تحويل للفني',
                            'Transfer to technician',
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'company_transfer',
                        child: Text(
                          accountText(
                            context,
                            'تحويل للشركة',
                            'Transfer to company',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => accountType = value);
                    },
                  ),
                  SizedBox(height: 12.h),
                  if (receipt != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.memory(
                        receipt!.bytes,
                        height: 150.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: picking ? null : pickReceipt,
                    icon: picking
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.upload_file_outlined),
                    label: Text(
                      accountText(
                        context,
                        receipt == null ? 'رفع إيصال الدفع' : 'تغيير الإيصال',
                        receipt == null ? 'Upload receipt' : 'Change receipt',
                      ),
                    ),
                  ),
                  TextField(
                    controller: notes,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: accountText(
                        context,
                        'ملاحظات (اختياري)',
                        'Notes (optional)',
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget section(String title, List<Widget> children, {Color? border}) =>
      Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          border: border == null ? null : Border.all(color: border),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: AccountCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              ...children,
            ],
          ),
        ),
      );
  Widget summary(String title, double value, {bool bold = false}) => Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: bold ? null : AppColors.subtitleGrey,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          money(value),
          style: TextStyle(
            fontSize: 14.sp,
            color: bold ? AppColors.badgeTextGreen : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
