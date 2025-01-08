import 'dart:ui';

import 'package:material/material.dart';
import 'dart:math' as math;

class AddClose extends StatelessWidget {
  const AddClose({
    super.key,
    required this.progress,
    this.size,
    this.weight,
    this.color,
  });

  final double progress;

  final double? size;
  final double? weight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final effectiveSize = size ?? iconTheme.size!;
    final effectiveWeight = weight ?? iconTheme.weight!;
    final effectiveColor = color ?? iconTheme.color!;
    return SizedBox.square(
      dimension: effectiveSize,
      child: CustomPaint(
        size: Size.square(effectiveSize),
        painter: _AddClosePainter(
          progress: progress,
          weight: effectiveWeight,
          color: effectiveColor,
        ),
      ),
    );
  }
}

class _AddClosePainter extends CustomPainter {
  const _AddClosePainter({
    required this.progress,
    required this.color,
    required this.weight,
  });

  final double progress;
  final Color color;
  final double weight;

  static const _center = Offset(12, 12);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final weightRange = normalizeDouble(weight, 100, 700);
    const double weight100 = 0.0;
    const double weight400 = 0.5;
    const double weight700 = 1.0;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = linearPoints(
            value: weightRange,
            points: {weight100: 0.7, weight400: 2.0, weight700: 3.15},
          );

    // final addStart = linear(weight, 100, 700, 6.3, 4.15);
    final addStart = linearPoints(
      value: weightRange,
      points: {weight100: 6.3, weight400: 5.0, weight700: 4.15},
    );
    final addEnd = 24 - addStart;

    final closeStart = linearPoints(
      value: weightRange,
      points: {weight100: 3.7269, weight400: 3.0905, weight700: 2.5248},
    );
    final closeEnd = 24 - closeStart;

    final points = [
      Offset.lerp(
        Offset(addStart, _center.dy),
        Offset(closeStart, _center.dy),
        progress,
      )!,
      Offset.lerp(
        Offset(_center.dx, addStart),
        Offset(_center.dx, closeStart),
        progress,
      )!,
      Offset.lerp(
        Offset(addEnd, _center.dy),
        Offset(closeEnd, _center.dy),
        progress,
      )!,
      Offset.lerp(
        Offset(_center.dx, addEnd),
        Offset(_center.dx, closeEnd),
        progress,
      )!,
    ];
    canvas.save();
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(lerpDouble(0, math.pi / 4, progress)!);
    canvas.translate(-_center.dx, -_center.dy);
    for (final point in points) {
      canvas.drawLine(_center, point, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AddClosePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

double normalizeDouble(double x, double min, double max) =>
    (x - min) / (max - min);
// double linear(
//   double value,
//   double valueMin,
//   double valueMax,
//   double min,
//   double max,
// ) {
//   if (min == max || min.isNaN && max.isNaN) {
//     return min;
//   }
//   assert(
//     value.isFinite,
//     "value must be finite when interpolating between values",
//   );
//   assert(
//     valueMin.isFinite,
//     "Cannot interpolate between finite and non-finite values",
//   );
//   assert(
//     valueMax.isFinite,
//     "Cannot interpolate between finite and non-finite values",
//   );
//   assert(
//     min.isFinite,
//     "Cannot interpolate between finite and non-finite values",
//   );
//   assert(
//     max.isFinite,
//     "Cannot interpolate between finite and non-finite values",
//   );
//   final t = ((value - valueMin) / (valueMax - valueMin)).clamp(0.0, 1.0);
//   return min * (1.0 - t) + max * t;
// }

double linearPoints({
  required double value,
  required Map<double, double> points,
}) {
  assert(points.length >= 2);
  assert(points.containsKey(0.0));
  assert(points.containsKey(1.0));
  if (points.containsKey(value)) {
    return points[value]!;
  }
  MapEntry<double, double>? from;
  MapEntry<double, double>? to;
  for (final entry in points.entries) {
    if ((from == null && entry.key < value) ||
        (from != null && from.key < entry.key && entry.key < value)) {
      from = entry;
    }
    if ((to == null && entry.key >= value) ||
        (to != null && value <= entry.key && entry.key < to.key)) {
      to = entry;
    }
  }

  final t = normalizeDouble(value, from!.key, to!.key);
  return from.value * (1.0 - t) + to.value * t;
}
