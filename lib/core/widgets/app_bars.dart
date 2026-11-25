import 'package:elite/core/constants/app_colors.dart';
import 'package:elite/core/constants/app_styles.dart';
import 'package:elite/core/widgets/back_icon_button.dart';
import 'package:flutter/material.dart';


class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PrimaryAppBar({super.key, required this.title, this.backgroundColor , this.actions});
  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const BackIconButton(),
      backgroundColor: backgroundColor ?? AppColors.pureWhiteColor,
      titleSpacing: -1,
      title: FittedBox(
        child: Text(
          title,
          style: AppStyles.styleSemiBold18(context),
        ),
      ),
      scrolledUnderElevation: 0,
      actions: actions ?? [],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
