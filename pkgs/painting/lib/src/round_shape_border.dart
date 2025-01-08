import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// A border that fits a stadium-shaped border (a box with semicircles on the ends)
/// within the rectangle of the widget it is applied to.
///
/// Typically used with [ShapeDecoration] to draw a stadium border.
///
/// If the rectangle is taller than it is wide, then the semicircles will be on the
/// top and bottom, and on the left and right otherwise.
///
/// See also:
///
///  * [BorderSide], which is used to describe the border of the stadium.
abstract class RoundBorder extends OutlinedBorder {
  const RoundBorder._({super.side});
  const factory RoundBorder({
    BorderSide side,
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
  }) = _NormalRoundBorder;

  const factory RoundBorder.directional({
    BorderSide side,
    double? topStart,
    double? topEnd,
    double? bottomEnd,
    double? bottomStart,
  }) = _DirectionalRoundBorder;

  @override
  ShapeBorder scale(double t);

  @protected
  BorderRadius _createBorderRadius(Rect rect, {TextDirection? textDirection});

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final borderRadius = _createBorderRadius(
      rect,
      textDirection: textDirection,
    ).resolve(textDirection);
    final borderRect = borderRadius.toRRect(rect);
    final adjustedRect = borderRect.deflate(side.strokeInset);
    return Path()..addRRect(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final borderRadius = _createBorderRadius(
      rect,
      textDirection: textDirection,
    ).resolve(textDirection);
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    final borderRadius = _createBorderRadius(
      rect,
      textDirection: textDirection,
    ).resolve(textDirection);
    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final borderRadius = _createBorderRadius(
          rect,
          textDirection: textDirection,
        ).resolve(textDirection);
        final borderRect = borderRadius.toRRect(rect);

        canvas.drawRRect(
          borderRect.inflate(side.strokeOffset / 2),
          side.toPaint(),
        );
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is RoundBorder && other.side == side;
  }

  @override
  int get hashCode => side.hashCode;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'StadiumBorder')}($side)';
  }
}

class _NormalRoundBorder extends RoundBorder {
  const _NormalRoundBorder({
    super.side,
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  }) : super._();

  final double? topLeft;
  final double? topRight;
  final double? bottomRight;
  final double? bottomLeft;

  @override
  BorderRadius _createBorderRadius(Rect rect, {TextDirection? textDirection}) {
    final full = Radius.circular(rect.shortestSide / 2);
    return BorderRadius.only(
      topLeft: topLeft != null ? Radius.circular(topLeft!) : full,
      topRight: topRight != null ? Radius.circular(topRight!) : full,
      bottomRight: bottomRight != null ? Radius.circular(bottomRight!) : full,
      bottomLeft: bottomLeft != null ? Radius.circular(bottomLeft!) : full,
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) => _NormalRoundBorder(
    side: side ?? this.side,
    topLeft: topLeft,
    topRight: topRight,
    bottomRight: bottomRight,
    bottomLeft: bottomLeft,
  );

  @override
  ShapeBorder scale(double t) => _NormalRoundBorder(
    side: side.scale(t),
    topLeft: topLeft != null ? topLeft! * t : null,
    topRight: topRight != null ? topRight! * t : null,
    bottomRight: bottomRight != null ? bottomRight! * t : null,
    bottomLeft: bottomLeft != null ? bottomLeft! * t : null,
  );

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _DirectionalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(side, b.side, t),
        t: t,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
        topStart: b.topStart,
        topEnd: b.topEnd,
        bottomEnd: b.bottomEnd,
        bottomStart: b.bottomStart,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _DirectionalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(a.side, side, t),
        t: 1 - t,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
        topStart: a.topStart,
        topEnd: a.topEnd,
        bottomEnd: a.bottomEnd,
        bottomStart: a.bottomStart,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _NormalRoundBorder &&
        other.side == side &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomRight == bottomRight &&
        other.bottomLeft == bottomLeft;
  }

  @override
  int get hashCode =>
      Object.hashAll([side, topLeft, topRight, bottomRight, bottomLeft]);
}

class _DirectionalRoundBorder extends RoundBorder {
  const _DirectionalRoundBorder({
    super.side,
    this.topStart,
    this.topEnd,
    this.bottomEnd,
    this.bottomStart,
  }) : super._();

  final double? topStart;
  final double? topEnd;
  final double? bottomEnd;
  final double? bottomStart;

  @override
  BorderRadius _createBorderRadius(Rect rect, {TextDirection? textDirection}) {
    final full = Radius.circular(rect.shortestSide / 2);
    return BorderRadiusDirectional.only(
      topStart: topStart != null ? Radius.circular(topStart!) : full,
      topEnd: topEnd != null ? Radius.circular(topEnd!) : full,
      bottomEnd: bottomEnd != null ? Radius.circular(bottomEnd!) : full,
      bottomStart: bottomStart != null ? Radius.circular(bottomStart!) : full,
    ).resolve(textDirection);
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) => _DirectionalRoundBorder(
    side: side ?? this.side,
    topStart: topStart,
    topEnd: topEnd,
    bottomEnd: bottomEnd,
    bottomStart: bottomStart,
  );

  @override
  ShapeBorder scale(double t) => _DirectionalRoundBorder(
    side: side.scale(t),
    topStart: topStart != null ? topStart! * t : null,
    topEnd: topEnd != null ? topEnd! * t : null,
    bottomEnd: bottomEnd != null ? bottomEnd! * t : null,
    bottomStart: bottomStart != null ? bottomStart! * t : null,
  );

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _NormalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(side, b.side, t),
        t: 1 - t,
        topLeft: b.topLeft,
        topRight: b.topRight,
        bottomRight: b.bottomRight,
        bottomLeft: b.bottomLeft,
        topStart: topStart,
        topEnd: topEnd,
        bottomEnd: bottomEnd,
        bottomStart: bottomStart,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _NormalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(a.side, side, t),
        t: t,
        topLeft: a.topLeft,
        topRight: a.topRight,
        bottomRight: a.bottomRight,
        bottomLeft: a.bottomLeft,
        topStart: topStart,
        topEnd: topEnd,
        bottomEnd: bottomEnd,
        bottomStart: bottomStart,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _DirectionalRoundBorder &&
        other.side == side &&
        other.topStart == topStart &&
        other.topEnd == topEnd &&
        other.bottomEnd == bottomEnd &&
        other.bottomStart == bottomStart;
  }

  @override
  int get hashCode =>
      Object.hashAll([side, topStart, topEnd, bottomEnd, bottomStart]);
}

class _NormalToDirectionalRoundBorder extends RoundBorder {
  const _NormalToDirectionalRoundBorder({
    super.side,
    required this.t,
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
    this.topStart,
    this.topEnd,
    this.bottomEnd,
    this.bottomStart,
  }) : super._();

  final double t;

  final double? topLeft;
  final double? topRight;
  final double? bottomRight;
  final double? bottomLeft;

  final double? topStart;
  final double? topEnd;
  final double? bottomEnd;
  final double? bottomStart;

  @override
  BorderRadius _createBorderRadius(Rect rect, {TextDirection? textDirection}) {
    final full = Radius.circular(rect.shortestSide / 2);
    final a = BorderRadius.only(
      topLeft: topLeft != null ? Radius.circular(topLeft!) : full,
      topRight: topRight != null ? Radius.circular(topRight!) : full,
      bottomRight: bottomRight != null ? Radius.circular(bottomRight!) : full,
      bottomLeft: bottomLeft != null ? Radius.circular(bottomLeft!) : full,
    );
    final b = BorderRadiusDirectional.only(
      topStart: topStart != null ? Radius.circular(topStart!) : full,
      topEnd: topEnd != null ? Radius.circular(topEnd!) : full,
      bottomEnd: bottomEnd != null ? Radius.circular(bottomEnd!) : full,
      bottomStart: bottomStart != null ? Radius.circular(bottomStart!) : full,
    ).resolve(textDirection);
    return BorderRadius.lerp(a, b, t)!;
  }

  @override
  OutlinedBorder copyWith({BorderSide? side}) =>
      _NormalToDirectionalRoundBorder(
        side: side ?? this.side,
        t: t,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
        topStart: topStart,
        topEnd: topEnd,
        bottomEnd: bottomEnd,
        bottomStart: bottomStart,
      );

  @override
  ShapeBorder scale(double t) => _NormalToDirectionalRoundBorder(
    side: side.scale(t),
    t: this.t,
    topLeft: topLeft != null ? topLeft! * t : null,
    topRight: topRight != null ? topRight! * t : null,
    bottomRight: bottomRight != null ? bottomRight! * t : null,
    bottomLeft: bottomLeft != null ? bottomLeft! * t : null,
    topStart: topStart != null ? topStart! * t : null,
    topEnd: topEnd != null ? topEnd! * t : null,
    bottomEnd: bottomEnd != null ? bottomEnd! * t : null,
    bottomStart: bottomStart != null ? bottomStart! * t : null,
  );

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _NormalToDirectionalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(side, b.side, t),
        t: lerpDouble(this.t, b.t, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _NormalToDirectionalRoundBorder) {
      return _NormalToDirectionalRoundBorder(
        side: BorderSide.lerp(a.side, side, t),
        t: lerpDouble(a.t, this.t, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _NormalToDirectionalRoundBorder &&
        other.side == side &&
        other.t == t &&
        other.topLeft == topLeft &&
        other.topRight == topRight &&
        other.bottomRight == bottomRight &&
        other.bottomLeft == bottomLeft &&
        other.topStart == topStart &&
        other.topEnd == topEnd &&
        other.bottomEnd == bottomEnd &&
        other.bottomStart == bottomStart;
  }

  @override
  int get hashCode => Object.hashAll([
    side,
    t,
    topLeft,
    topRight,
    bottomRight,
    bottomLeft,
    topStart,
    topEnd,
    bottomEnd,
    bottomStart,
  ]);
}
