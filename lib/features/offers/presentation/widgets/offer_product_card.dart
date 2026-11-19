import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';
import '../../data/models/offers_model.dart';
import 'offers_formatters.dart';

class OfferProductCard extends StatelessWidget {
  final OfferItem item;
  final bool isArabic;
  final VoidCallback? onTap;

  const OfferProductCard({
    super.key,
    required this.item,
    required this.isArabic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = offerTitle(item, isArabic);
    final description = offerDescription(item, isArabic);
    final category = offerCategoryName(item, isArabic);
    final priceText = offerPriceText(item);
    final finalPriceText = offerFinalPriceText(item);
    final hasDiscount = offerHasDiscount(item);
    final discountBadge = offerDiscountBadge(item, isArabic);
    final inStock = offerInStock(item);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  child: _buildImage(),
                ),
                if (discountBadge.isNotEmpty)
                  Positioned(
                    top: 12.h,
                    left: isArabic ? null : 12.w,
                    right: isArabic ? 12.w : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer_rounded,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            discountBadge,
                            style: AppStyles.styleRegular14(context).copyWith(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!inStock)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.outOfStock.tr(),
                          style: AppStyles.styleSemiBold18(
                            context,
                          ).copyWith(fontSize: 14.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBg,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.styleRegular14(context).copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.badgeTextGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.styleMedium16(context).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.titleDark,
                    ),
                  ),
                  if (description.trim().isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.styleRegular14(context).copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.subtitleGrey,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (_tags(context).isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: _tags(context),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount && priceText.isNotEmpty)
                              Text(
                                priceText,
                                style: AppStyles.styleRegular14(context)
                                    .copyWith(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subtitleGrey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            if (finalPriceText.isNotEmpty)
                              Text(
                                finalPriceText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.styleMedium16(context)
                                    .copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.homeContractBadgeGreen,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: inStock
                              ? AppColors.homeHeaderGreen
                              : AppColors.navInactiveGrey,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Text(
                          AppStrings.addToCart.tr(),
                          style: AppStyles.styleMedium16(context).copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _tags(BuildContext context) {
    final tags = <Widget>[];
    if (item.freeShipping) {
      tags.add(
        _buildTag(
          context,
          Icons.local_shipping_rounded,
          AppStrings.freeShipping.tr(),
        ),
      );
    }
    if (item.hasMaintenance) {
      tags.add(
        _buildTag(
          context,
          Icons.build_circle_rounded,
          AppStrings.withMaintenance.tr(),
        ),
      );
    }
    final guarantee = item.guarantee;
    if (guarantee != null && guarantee > 0) {
      tags.add(
        _buildTag(
          context,
          Icons.verified_rounded,
          '${AppStrings.warranty.tr()} $guarantee ${AppStrings.year.tr()}',
        ),
      );
    }
    return tags;
  }

  Widget _buildTag(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: AppColors.homeContractBadgeGreen),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppStyles.styleRegular14(context).copyWith(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.homeContractBadgeGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final image = item.image;
    if (image == null || image.isEmpty) {
      return Container(
        height: 180.h,
        color: AppColors.notWhiteColor,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40.sp,
          color: AppColors.subtitleGrey,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: image,
      height: 180.h,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.loadingEffectColor,
        highlightColor: Colors.white,
        child: Container(height: 180.h, color: AppColors.loadingEffectColor),
      ),
      errorWidget: (context, url, error) => Container(
        height: 180.h,
        color: AppColors.notWhiteColor,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40.sp,
          color: AppColors.subtitleGrey,
        ),
      ),
    );
  }
}