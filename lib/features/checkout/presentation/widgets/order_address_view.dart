import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/order_draft.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/order_address_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class OrderAddressView extends StatefulWidget {
  final OrderAddress? initial;
  const OrderAddressView({super.key, this.initial});
  @override
  State<OrderAddressView> createState() => _OrderAddressViewState();
}

class _OrderAddressViewState extends State<OrderAddressView> {
  final formKey = GlobalKey<FormState>();
  late final List<TextEditingController> fields;
  int label = 0;
  LatLng? selectedLocation;
  bool findingAddress = false;
  int locationRequest = 0;

  Future<void> selectLocation(LatLng point) async {
    final request = ++locationRequest;
    setState(() {
      selectedLocation = point;
      findingAddress = true;
      fields[0].clear();
      fields[1].clear();
    });
    try {
      final addresses = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted || request != locationRequest || addresses.isEmpty) return;
      final place = addresses.first;
      final area = [place.subLocality, place.locality, place.administrativeArea]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toSet()
          .join('، ');
      // Keep any text the user has entered while reverse geocoding runs.
      if (fields[0].text.isEmpty) fields[0].text = area;
      if (fields[1].text.isEmpty)
        fields[1].text = place.thoroughfare?.isNotEmpty == true
            ? place.thoroughfare!
            : (place.street ?? '');
    } catch (_) {
      if (mounted && request == locationRequest) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              checkoutText(
                context,
                'تم تحديد المكان. اكتبي المنطقة والشارع يدويًا',
                'Location selected. Enter the area and street manually',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted && request == locationRequest)
        setState(() => findingAddress = false);
    }
  }

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    if (a?.latitude != null && a?.longitude != null) {
      selectedLocation = LatLng(a!.latitude!, a.longitude!);
    }
    fields = [
      a?.area,
      a?.street,
      a?.building,
      a?.floor,
      a?.apartment,
    ].map((e) => TextEditingController(text: e ?? '')).toList();
    if (a != null)
      label =
          ['البيت', 'الشغل', 'تاني', 'Home', 'Work', 'Other'].indexOf(a.label) %
              3;
    if (label < 0) label = 0;
  }

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  Widget field(int index, String name) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CheckoutSectionTitle(name),
      TextFormField(
        controller: fields[index],
        validator: (value) => value == null || value.trim().isEmpty
            ? checkoutText(context, 'مطلوب', 'Required')
            : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.unselectedBorder),
          ),
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    final labels = [
      checkoutText(context, 'البيت', 'Home'),
      checkoutText(context, 'الشغل', 'Work'),
      checkoutText(context, 'تاني', 'Other'),
    ];
    return CheckoutScaffold(
      title: checkoutText(context, 'أضف عنوانك', 'Add your address'),
      action: checkoutText(
        context,
        'حفظ العنوان والبدء',
        'Save address and continue',
      ),
      onAction: () {
        if (selectedLocation == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                checkoutText(
                  context,
                  'حددي مكانك على الخريطة الأول',
                  'Select your location on the map first',
                ),
              ),
            ),
          );
          return;
        }
        if (!formKey.currentState!.validate()) return;
        Navigator.of(context).pop(
          OrderAddress(
            latitude: selectedLocation!.latitude,
            longitude: selectedLocation!.longitude,
            area: fields[0].text.trim(),
            street: fields[1].text.trim(),
            building: fields[2].text.trim(),
            floor: fields[3].text.trim(),
            apartment: fields[4].text.trim(),
            label: labels[label],
          ),
        );
      },
      body: Form(
        key: formKey,
        child: Column(
          children: [
            OrderAddressMap(
              selected: selectedLocation,
              onSelected: selectLocation,
            ),
            if (findingAddress)
              const LinearProgressIndicator(color: AppColors.primaryColor),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                checkoutText(
                  context,
                  selectedLocation == null
                      ? 'اضغطي على الخريطة لتحديد العنوان'
                      : 'ممكن تسحبي العلامة لتعديل المكان',
                  selectedLocation == null
                      ? 'Tap the map to select your address'
                      : 'Drag the marker to adjust your location',
                ),
                style: TextStyle(
                  color: AppColors.badgeTextGreen,
                  fontSize: 11.sp,
                ),
              ),
            ),
            field(0, checkoutText(context, 'المنطقة', 'Area')),
            field(1, checkoutText(context, 'الشارع', 'Street')),
          ],
        ),
      ),
    );
  }
}
