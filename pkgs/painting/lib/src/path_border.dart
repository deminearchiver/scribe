import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:vector_math/vector_math_64.dart' show Matrix4, Vector3;

Matrix4 _computeRotation(double radians) {
  assert(
    radians.isFinite,
    'Cannot compute the rotation matrix for a non-finite angle: $radians',
  );
  if (radians == 0.0) {
    return Matrix4.identity();
  }
  final double sin = math.sin(radians);
  if (sin == 1.0) {
    return _createZRotation(1.0, 0.0);
  }
  if (sin == -1.0) {
    return _createZRotation(-1.0, 0.0);
  }
  final double cos = math.cos(radians);
  if (cos == -1.0) {
    return _createZRotation(0.0, -1.0);
  }
  return _createZRotation(sin, cos);
}

Matrix4 _createZRotation(double sin, double cos) {
  final Matrix4 result = Matrix4.zero();
  result.storage[0] = cos;
  result.storage[1] = sin;
  result.storage[4] = -sin;
  result.storage[5] = cos;
  result.storage[10] = 1.0;
  result.storage[15] = 1.0;
  return result;
}

Matrix4 _getScalingMatrix(double scaleX, double scaleY, Offset center) {
  assert(scaleX >= 0);
  assert(scaleY >= 0);
  return Matrix4.identity()
    ..translate(center.dx, center.dy)
    ..scale(scaleX, scaleY, 1.0)
    ..translate(-center.dx, -center.dy);
}

// extension PathExtension on Path {
//   Path scaleToFit(Rect rect, [Rect? bounds]) {
//     bounds ??= getBounds();

//     final offset = rect.topLeft - bounds.topLeft;

//     final scaleX = rect.width / bounds.width;
//     final scaleY = rect.height / bounds.height;

//     final matrix = Matrix4.diagonal3Values(scaleX, scaleY, 1.0);
//     return transform(matrix.storage).shift(offset);
//   }
// }

class PathBorder extends OutlinedBorder {
  const PathBorder({
    super.side,
    this.bounds = const Rect.fromLTRB(0.0, 0.0, 1.0, 1.0),
    this.rotation = 0.0,
    required this.path,
  });

  final Rect bounds;
  final double rotation;
  final Path path;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  Path _generatePath(Rect rect) {
    // final delta = rect.center - bounds.center;
    final scaleX = rect.width / bounds.width;
    final scaleY = rect.height / bounds.height;
    // final center = Offset(delta.dx / rect.width, delta.dy / rect.height);
    // final matrix =
    //     Matrix4.identity()
    //       ..translate(bounds.center.dx, bounds.center.dy)
    //       ..scale(scaleX, scaleY, 1.0)
    //       ..translate(-bounds.center.dx, -bounds.center.dy)
    //       ..translate();
    // ..translate(bounds.center.dx, bounds.center.dy);
    // return path.transform(matrix.storage);
    return path
        .shift(-bounds.center)
        .transform(Matrix4.diagonal3Values(scaleX, scaleY, 1.0).storage)
        .transform(_computeRotation(rotation).storage)
        .shift(rect.center);

    // final scaleMatrix = Matrix4.diagonal3Values(scaleX, scaleY, 1.0);
    // final rotationMatrix = _computeRotation(rotation);
    // return path
    //     .transform(scaleMatrix.storage)
    //     .shift(-rect.center)
    //     .transform(rotationMatrix.storage)
    //     .shift(rect.center);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final adjustedRect = rect.deflate(side.strokeInset);
    return _generatePath(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _generatePath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final adjustedRect = rect.inflate(side.strokeOffset / 2);
        final path = _generatePath(adjustedRect);
        canvas.drawPath(path, side.toPaint());
    }
  }

  @override
  PathBorder scale(double t) => PathBorder(
    side: side.scale(t),
    bounds: bounds,
    rotation: rotation,
    path: path,
  );

  @override
  PathBorder copyWith({
    BorderSide? side,
    Rect? bounds,
    double? rotation,
    Path? path,
  }) => PathBorder(
    side: side ?? this.side,
    bounds: bounds ?? this.bounds,
    rotation: rotation ?? this.rotation,
    path: path ?? this.path,
  );
}
