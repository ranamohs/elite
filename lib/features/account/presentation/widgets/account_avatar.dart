import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/end_points.dart';

class AccountAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  const AccountAvatar({super.key, this.url, this.radius = 25});
  @override
  Widget build(BuildContext context) {
    final raw = url?.trim() ?? '';
    final icon = Icon(
      Icons.person_rounded,
      color: AppColors.badgeTextGreen,
      size: radius * 1.3,
    );
    return ClipOval(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: AppColors.badgeBg,
        child: raw.isEmpty
            ? icon
            : CachedNetworkImage(
          imageUrl: Uri.parse(
            EndPoints.imageBaseUrl,
          ).resolve(raw).toString(),
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => icon,
          placeholder: (_, _) => icon,
        ),
      ),
    );
  }
}
