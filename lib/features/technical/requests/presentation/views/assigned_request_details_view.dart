import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/functions/is_arabic.dart';
import '../../../../account/presentation/widgets/account_avatar.dart';
import '../../../../account/presentation/widgets/account_ui.dart';
import '../../data/models/assigned_requests_model.dart';

class AssignedRequestDetailsView extends StatelessWidget {
  final AssignedRequest request;
  const AssignedRequestDetailsView({super.key, required this.request});

  Future<void> open(BuildContext context, Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
          context.mounted) {
        accountInfo(context, 'تعذر فتح الرابط', 'Could not open link');
      }
    } catch (_) {
      if (context.mounted)
        accountInfo(context, 'تعذر فتح الرابط', 'Could not open link');
    }
  }

  Uri get directions => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${request.latitude},${request.longitude}',
    'travelmode': 'driving',
  });

  @override
  Widget build(BuildContext context) {
    final hasCustomer =
        request.customerName?.trim().isNotEmpty == true ||
            request.customerPhone?.trim().isNotEmpty == true ||
            request.address?.trim().isNotEmpty == true;
    return AccountScaffold(
      title: accountText(
        context,
        'طلب #${request.code}',
        'Request #${request.code}',
      ),
      bottomBar: AccountSaveBar(
        label: accountText(
          context,
          'ابدأ العمل ',
          'start job',
        ),
        onPressed:(){},
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 20.h),
        children: [
          if (request.hasLocation) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 145.h,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(request.latitude!, request.longitude!),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('customer'),
                      position: LatLng(request.latitude!, request.longitude!),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                  onTap: (_) => open(context, directions),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
          if (hasCustomer) ...[
            AccountCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AccountAvatar(radius: 23.r),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (request.customerName?.trim().isNotEmpty == true)
                          Text(
                            request.customerName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        if (request.address?.trim().isNotEmpty == true) ...[
                          SizedBox(height: 5.h),
                          Text(
                            request.address!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.subtitleGrey,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (request.customerPhone?.trim().isNotEmpty == true) ...[
                    SizedBox(width: 8.w),
                    FilledButton(
                      onPressed: () => open(
                        context,
                        Uri(scheme: 'tel', path: request.customerPhone),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        minimumSize: Size(48.w, 34.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: Text(
                        accountText(context, 'اتصال', 'Call'),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],
          AccountCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountText(context, 'الخدمات', 'Services'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    if (request.customerDate?.isNotEmpty == true)
                      Expanded(
                        child: Text(
                          request.customerDate!,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                  ],
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
                if (request.itemsTotal != null) ...[
                  const Divider(height: 1),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          accountText(context, 'الإجمالي', 'Total'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        request.itemsTotal!.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.badgeTextGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (request.notes?.trim().isNotEmpty == true)
            AccountCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    accountText(context, 'ملاحظة العميل', 'Customer note'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    request.notes!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.subtitleGrey,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}