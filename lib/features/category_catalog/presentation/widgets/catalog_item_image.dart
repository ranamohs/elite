import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/catalog_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CatalogItemImage extends StatelessWidget {
  final CatalogItem item;
  final double size;
  const CatalogItemImage({super.key, required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: item.image.isEmpty
          ? const Icon(Icons.image_outlined, color: AppColors.subtitleGrey)
          : CachedNetworkImage(
        imageUrl: item.image,
        fit: BoxFit.contain,
        placeholder: (_, _) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          color: AppColors.subtitleGrey,
        ),
      ),
    );
  }
}
