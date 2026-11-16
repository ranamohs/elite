import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'account_avatar.dart';
import 'account_ui.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final String? avatarUrl;
  final ValueChanged<File> onChanged;
  const ProfilePhotoPicker({
    super.key,
    this.avatarUrl,
    required this.onChanged,
  });
  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? image;
  bool picking = false;
  Future<void> pick() async {
    if (picking) return;
    picking = true;
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (!mounted || file == null) return;
      final value = File(file.path);
      setState(() => image = value);
      widget.onChanged(value);
    } catch (_) {
      if (mounted)
        accountInfo(context, 'تعذر اختيار الصورة', 'Could not select a photo');
    } finally {
      picking = false;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (image != null)
        ClipOval(
          child: Image.file(
            image!,
            width: 76.w,
            height: 76.w,
            fit: BoxFit.cover,
          ),
        )
      else
        AccountAvatar(url: widget.avatarUrl, radius: 38.r),
      TextButton(
        onPressed: pick,
        child: Text(
          accountText(context, 'تغيير الصورة', 'Change photo'),
          style: TextStyle(color: AppColors.badgeTextGreen, fontSize: 11.sp),
        ),
      ),
    ],
  );
}
