import 'package:flutter/material.dart';
import 'package:plainpad/shared/theme/theme.dart';

/// The launcher icon, drawn in Flutter: a white notepad with ruled lines on
/// the brand blue.
///
/// Mirrors `android/app/src/main/res/drawable/ic_launcher_foreground.xml` and
/// the `ic_launcher_background` colour, so the About and Licenses pages show
/// the same mark as the home screen (task #451). Change both together.
class AppIconMark extends StatelessWidget {
  const AppIconMark({super.key, this.size = AppSpacing.aboutIconContainer});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xlBorder,
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _AppIconPainter()),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter();

  /// The adaptive icon is 108 units; the launcher shows the central 72.
  static const double _viewport = 72;
  static const double _inset = (108 - _viewport) / 2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = AppColors.brand)
      ..save()
      ..scale(size.width / _viewport, size.height / _viewport)
      ..translate(-_inset, -_inset);

    final white = Paint()..color = Colors.white;
    // The ruled lines are the background showing through the paper.
    final line = Paint()..color = AppColors.brand;

    // The paper.
    canvas
      ..drawRRect(
        RRect.fromLTRBR(40, 35, 68, 73, const Radius.circular(3)),
        white,
      )
      // Three full ruled lines and a shorter last one.
      ..drawRect(const Rect.fromLTRB(45, 45, 63, 48), line)
      ..drawRect(const Rect.fromLTRB(45, 52, 63, 55), line)
      ..drawRect(const Rect.fromLTRB(45, 59, 63, 62), line)
      ..drawRect(const Rect.fromLTRB(45, 66, 56, 69), line)
      ..restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter oldDelegate) => false;
}
