import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

const _kCurve = Easing.standard;
const _kGrowDuration = Duration(milliseconds: 150);
const _kGrowDelay = Duration.zero;
const _kShrinkDelay = Duration(milliseconds: 150);
const _kShrinkDuration = Duration(milliseconds: 450);

abstract class _ProxyBorderSide extends BorderSide {
  const _ProxyBorderSide(this.parent);

  final BorderSide parent;

  @override
  Color get color => parent.color;

  @override
  double get width => parent.width;

  @override
  BorderStyle get style => parent.style;

  @override
  double get strokeAlign => parent.strokeAlign;

  @override
  double get strokeInset => parent.strokeInset;

  @override
  double get strokeOutset => parent.strokeOutset;

  @override
  double get strokeOffset => parent.strokeOffset;

  @override
  BorderSide scale(double t);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is _ProxyBorderSide &&
            other.parent == parent;
  }

  @override
  int get hashCode => parent.hashCode;
}

class _OffsetBorderSide extends _ProxyBorderSide {
  const _OffsetBorderSide({required BorderSide parent, this.offset = 0.0})
    : super(parent);

  final double offset;

  @override
  double get strokeInset => super.strokeInset - offset;

  @override
  double get strokeOutset => super.strokeOutset + offset;

  @override
  double get strokeOffset => super.strokeOffset + offset;

  @override
  BorderSide scale(double t) =>
      _OffsetBorderSide(parent: parent.scale(t), offset: offset * t);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is _OffsetBorderSide &&
            other.parent == parent &&
            other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(parent, offset);
}
