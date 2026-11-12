import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_widgets.dart';

class OrderAddressMap extends StatefulWidget {
  final LatLng? selected;
  final ValueChanged<LatLng> onSelected;
  const OrderAddressMap({super.key, this.selected, required this.onSelected});
  @override
  State<OrderAddressMap> createState() => _OrderAddressMapState();
}

class _OrderAddressMapState extends State<OrderAddressMap> {
  GoogleMapController? controller;
  bool locating = false;
  bool locationGranted = false;
  // Camera fallback only; it is never saved as the user's location.
  static const fallback = LatLng(30.0444, 31.2357);

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void message(String ar, String en, {Future<bool> Function()? settings}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(checkoutText(context, ar, en)),
        action: settings == null
            ? null
            : SnackBarAction(
          label: checkoutText(context, 'الإعدادات', 'Settings'),
          onPressed: () {
            settings();
          },
        ),
      ),
    );
  }

  Future<void> useCurrentLocation() async {
    if (locating) return;
    setState(() => locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        message(
          'فعّلي خدمة الموقع أو اختاري المكان من الخريطة',
          'Enable location services or select a place on the map',
          settings: Geolocator.openLocationSettings,
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (permission == LocationPermission.deniedForever) {
        message(
          'اسمحي بالوصول للموقع من إعدادات التطبيق، أو حددي المكان يدويًا',
          'Allow location access in app settings or select a place manually',
          settings: Geolocator.openAppSettings,
        );
        return;
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        message(
          'ممكن تحددي العنوان بالضغط على الخريطة بدون إذن الموقع',
          'You can select an address on the map without location permission',
        );
        return;
      }
      setState(() => locationGranted = true);
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      widget.onSelected(point);
      await controller?.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
    } catch (_) {
      message(
        'تعذر تحديد موقعك الحالي، جرّبي مرة تانية أو اضغطي على الخريطة',
        'Could not locate you. Try again or tap the map',
      );
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: SizedBox(
          height: 220.h,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.selected ?? fallback,
              zoom: widget.selected == null ? 12 : 16,
            ),
            onMapCreated: (value) => controller = value,
            onTap: widget.onSelected,
            markers: {
              if (widget.selected != null)
                Marker(
                  markerId: const MarkerId('order-address'),
                  position: widget.selected!,
                  draggable: true,
                  onDragEnd: widget.onSelected,
                ),
            },
            myLocationEnabled: locationGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
              ),
            },
          ),
        ),
      ),
      Align(
        alignment: AlignmentDirectional.centerEnd,
        child: TextButton.icon(
          onPressed: locating ? null : useCurrentLocation,
          icon: locating
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.my_location, size: 18),
          label: Text(
            checkoutText(
              context,
              'استخدم موقعي الحالي',
              'Use my current location',
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.badgeTextGreen,
          ),
        ),
      ),
    ],
  );
}
