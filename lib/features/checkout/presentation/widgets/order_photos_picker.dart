import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import 'checkout_widgets.dart';

class OrderPhotosPicker extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const OrderPhotosPicker({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(
      3,
          (index) => Expanded(
        child: Padding(
          padding: EdgeInsetsDirectional.only(end: index < 2 ? 10.w : 0),
          child: AspectRatio(
            aspectRatio: 1,
            child: index < photos.length
                ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    File(photos[index]),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                    const Icon(Icons.broken_image_outlined),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => onRemove(index),
                    tooltip: checkoutText(
                      context,
                      'حذف الصورة',
                      'Remove photo',
                    ),
                    icon: const Icon(Icons.cancel, color: Colors.white),
                  ),
                ),
              ],
            )
                : InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(12.r),
              child: CustomPaint(
                painter: _DashedBorder(radius: 12.r),
                child: Center(
                  child: Text(
                    checkoutText(context, '+ صورة', '+ Photo'),
                    style: const TextStyle(
                      color: AppColors.badgeTextGreen,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _DashedBorder extends CustomPainter {
  final double radius;
  const _DashedBorder({required this.radius});
  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(1),
      Radius.circular(radius),
    );
    canvas.drawRRect(shape, Paint()..color = Colors.white);
    final path = Path()..addRRect(shape);
    final paint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 9) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorder oldDelegate) =>
      oldDelegate.radius != radius;
}
