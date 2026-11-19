import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/service_locator.dart';
import '../../../account/data/repos/addresses_repo/account_addresses_repo.dart';
import '../../../account/presentation/widgets/account_ui.dart';
import '../../../checkout/data/models/order_draft.dart';
import '../../../checkout/presentation/views/order_address_view.dart';
import '../../../checkout/presentation/widgets/order_address_view.dart';
import '../../../home/data/models/contracts_models/maintenance_contracts_model.dart';
import '../../data/models/contract_subscription_model.dart';
import '../../data/models/contract_subscription_request.dart';
import '../widgets/subscription_contract_card.dart';
import '../widgets/subscription_photo_field.dart';
import '../widgets/subscription_step_indicator.dart';
import 'contract_subscription_review_view.dart';
import 'contract_subscription_success_view.dart';

class ContractSubscriptionView extends StatefulWidget {
  final MaintenanceContract contract;
  const ContractSubscriptionView({super.key, required this.contract});
  @override
  State<ContractSubscriptionView> createState() =>
      _ContractSubscriptionViewState();
}

class _ContractSubscriptionViewState extends State<ContractSubscriptionView> {
  OrderAddress? address;
  String? imagePath;
  bool picking = false, reviewing = false;
  @override
  void initState() {
    super.initState();
    loadAddress();
  }

  Future<void> loadAddress() async {
    try {
      final values = await getIt<AccountAddressesRepo>().load();
      if (!mounted || values.isEmpty || address != null) return;
      final saved = values.firstWhere(
            (e) => e.isDefault,
        orElse: () => values.first,
      );
      setState(() => address = saved.address);
    } catch (_) {
      /* Manual selection remains available. */
    }
  }

  Future<void> selectAddress() async {
    final value = await Navigator.of(context).push<OrderAddress>(
      MaterialPageRoute(builder: (_) => OrderAddressView(initial: address)),
    );
    if (mounted && value != null) setState(() => address = value);
  }

  Future<void> selectImage() async {
    if (picking) return;
    picking = true;
    try {
      final value = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (!mounted || value == null) return;
      final ext = value.path.toLowerCase().split('.').last;
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext) ||
          await File(value.path).length() > 5120 * 1024) {
        if (mounted)
          accountInfo(
            context,
            'الصورة لازم تكون JPG أو PNG أو WEBP وأقل من 5 ميجابايت',
            'Choose a JPG, JPEG, PNG or WEBP photo up to 5 MB',
          );
        return;
      }
      if (mounted) setState(() => imagePath = value.path);
    } catch (_) {
      if (mounted)
        accountInfo(
          context,
          'تعذر اختيار الصورة',
          'Could not select the photo',
        );
    } finally {
      picking = false;
    }
  }

  Future<void> review() async {
    if (reviewing) return;
    final value = address;
    if (imagePath == null ||
        value == null ||
        value.latitude == null ||
        value.longitude == null ||
        value.details.trim().isEmpty) {
      accountInfo(
        context,
        'اختاري الصورة والعنوان من الخريطة الأول',
        'Select the required photo and address on the map first',
      );
      return;
    }
    final request = ContractSubscriptionRequest(
      contractId: widget.contract.id,
      imagePath: imagePath!,
      address: value.details,
      latitude: value.latitude!,
      longitude: value.longitude!,
    );
    setState(() => reviewing = true);
    final result = await Navigator.of(context).push<ContractSubscriptionModel>(
      MaterialPageRoute(
        builder: (_) => ContractSubscriptionReviewView(
          contract: widget.contract,
          request: request,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => reviewing = false);
    if (result != null)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ContractSubscriptionSuccessView(subscription: result),
        ),
      );
  }

  @override
  Widget build(BuildContext context) => AccountScaffold(
    title: accountText(
      context,
      'اطلب عقد الصيانة',
      'Request a maintenance contract',
    ),
    bottomBar: AccountSaveBar(
      label: accountText(context, 'التالي: المراجعة', 'Next: review'),
      onPressed: reviewing ? null : review,
    ),
    body: ListView(
      padding: EdgeInsets.all(18.w),
      children: [
        const SubscriptionStepIndicator(step: 1),
        SizedBox(height: 18.h),
        SubscriptionContractCard(contract: widget.contract),
        SizedBox(height: 20.h),
        Text(
          accountText(context, 'العنوان', 'Address'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        AccountCard(
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address?.details ??
                      accountText(
                        context,
                        'اختاري العنوان من الخريطة',
                        'Select the address on the map',
                      ),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              TextButton(
                onPressed: selectAddress,
                child: Text(accountText(context, 'تغيير', 'Change')),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          accountText(
            context,
            'صورة المكان (مطلوبة)',
            'Photo of the place (required)',
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        SubscriptionPhotoField(path: imagePath, onSelect: selectImage),
      ],
    ),
  );
}