import 'dart:ui';

import 'package:material/material.dart';

sealed class TwoPaneLayoutFlexFactor {
  const TwoPaneLayoutFlexFactor._();

  const factory TwoPaneLayoutFlexFactor(double flex) = _TwoPaneLayoutFlexFactor;
  const factory TwoPaneLayoutFlexFactor.fixedListWidth(double width) =
      _TwoPaneLayoutFixedListWidthFlexFactor;
  const factory TwoPaneLayoutFlexFactor.fixedDetailWidth(double width) =
      _TwoPaneLayoutFixedDetailWidthFlexFactor;

  /// Must return a value between -1.0 and 1.0
  double resolve(double maxWidth);

  static TwoPaneLayoutFlexFactor? lerp(
    TwoPaneLayoutFlexFactor? a,
    TwoPaneLayoutFlexFactor? b,
    double t,
  ) {
    assert(t >= 0.0);
    assert(t <= 1.0);

    if (identical(a, b)) return a;

    if (a == null && b == null) return null;

    if (t == 0.0) return a;
    if (t == 1.0) return b;

    if (a is _TwoPaneLayoutFlexFactor && b is _TwoPaneLayoutFlexFactor) {
      final flex = lerpDouble(a.flex, b.flex, t)!;
      return _TwoPaneLayoutFlexFactor(flex);
    }
    if (a is _TwoPaneLayoutFixedListWidthFlexFactor &&
        b is _TwoPaneLayoutFixedListWidthFlexFactor) {
      final width = lerpDouble(a.width, b.width, t)!;
      return _TwoPaneLayoutFixedListWidthFlexFactor(width);
    }
    if (a is _TwoPaneLayoutFixedDetailWidthFlexFactor &&
        b is _TwoPaneLayoutFixedDetailWidthFlexFactor) {
      final width = lerpDouble(a.width, b.width, t)!;
      return _TwoPaneLayoutFixedDetailWidthFlexFactor(width);
    }
    return _CompoundTwoPaneLayoutFlexFactor(a, b, t);
  }
}

class TwoPaneLayoutFlexFactorTween extends Tween<TwoPaneLayoutFlexFactor?> {
  TwoPaneLayoutFlexFactorTween({super.begin, super.end});

  @override
  TwoPaneLayoutFlexFactor? lerp(double t) =>
      TwoPaneLayoutFlexFactor.lerp(begin, end, t);
}

class _CompoundTwoPaneLayoutFlexFactor extends TwoPaneLayoutFlexFactor {
  const _CompoundTwoPaneLayoutFlexFactor(this.a, this.b, this.t)
    : assert(a != null || b != null),
      super._();

  final TwoPaneLayoutFlexFactor? a;
  final TwoPaneLayoutFlexFactor? b;
  final double t;

  @override
  double resolve(double maxWidth) {
    final resultA = a?.resolve(maxWidth);
    final resultB = b?.resolve(maxWidth);
    if (resultA != null && resultB != null) {
      return lerpDouble(resultA, resultB, t)!;
    }
    if (resultA != null) return resultA;
    if (resultB != null) return resultB;
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CompoundTwoPaneLayoutFlexFactor &&
            a == other.a &&
            b == other.b &&
            t == other.t;
  }

  @override
  int get hashCode => Object.hash(a, b, t);
}

class _TwoPaneLayoutFlexFactor extends TwoPaneLayoutFlexFactor {
  const _TwoPaneLayoutFlexFactor(this.flex)
    : assert(
        flex >= -1.0 && flex <= 1.0,
        "Flex factor must be between -1.0 and 1.0",
      ),
      super._();

  final double flex;

  @override
  double resolve(double maxWidth) => flex;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TwoPaneLayoutFlexFactor && flex == other.flex;
  }

  @override
  int get hashCode => flex.hashCode;
}

class _TwoPaneLayoutFixedListWidthFlexFactor extends TwoPaneLayoutFlexFactor {
  const _TwoPaneLayoutFixedListWidthFlexFactor(this.width) : super._();

  final double width;

  @override
  double resolve(double maxWidth) {
    return _remap(width, 0.0, maxWidth, -1.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TwoPaneLayoutFixedListWidthFlexFactor && width == other.width;
  }

  @override
  int get hashCode => width.hashCode;
}

class _TwoPaneLayoutFixedDetailWidthFlexFactor extends TwoPaneLayoutFlexFactor {
  const _TwoPaneLayoutFixedDetailWidthFlexFactor(this.width) : super._();

  final double width;

  @override
  double resolve(double maxWidth) {
    return _remap(maxWidth - width, 0.0, maxWidth, -1.0, 1.0);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TwoPaneLayoutFixedDetailWidthFlexFactor &&
            width == other.width;
  }

  @override
  int get hashCode => width.hashCode;
}

double _remap(
  double x,
  double fromMin,
  double fromMax,
  double toMin,
  double toMax,
) {
  if (x <= fromMin) return toMin;
  if (x >= fromMax) return toMax;
  return (((x - fromMin) * (toMax - toMin)) / (fromMax - fromMin)) + toMin;
}

enum _TwoPaneLayoutSlot { list, separator, detail }

class _TwoPaneLayoutDelegate extends MultiChildLayoutDelegate {
  _TwoPaneLayoutDelegate({
    this.shift = 0.0,
    this.flex = const TwoPaneLayoutFlexFactor(0.0),
    this.padding = EdgeInsets.zero,
  });

  /// Shift factor
  final double shift;

  /// Flex factor
  final TwoPaneLayoutFlexFactor flex;

  /// Resolved padding
  final EdgeInsets padding;

  @override
  void performLayout(Size size) {
    final hasList = hasChild(_TwoPaneLayoutSlot.list);
    final hasSeparator = hasChild(_TwoPaneLayoutSlot.separator);
    final hasDetail = hasChild(_TwoPaneLayoutSlot.detail);

    assert(hasList && hasDetail);

    final rect = Offset.zero & size;
    final paddingRect = padding.deflateRect(rect);
    final maxWidth = paddingRect.width;
    final maxHeight = paddingRect.height;

    double separatorWidth = 0.0;
    if (hasSeparator) {
      final separatorSize = layoutChild(
        _TwoPaneLayoutSlot.separator,
        BoxConstraints(
          maxWidth: paddingRect.width,
          minHeight: maxHeight,
          maxHeight: maxHeight,
        ),
      );
      separatorWidth = separatorSize.width;
    }

    final availableWidth = maxWidth - separatorWidth;

    final flex = this.flex.resolve(availableWidth);

    final flexFraction = (flex + 1.0) / 2.0;
    final flexListFraction = clampDouble(flex, 0.0, 1.0);
    final flexDetailFraction = 1.0 - clampDouble(flex, -1.0, 0.0) - 1.0;
    final shiftFraction = (shift + 1.0) / 2.0;
    final shiftListFraction = clampDouble(shift, 0.0, 1.0);
    final shiftDetailFraction = 1.0 - clampDouble(shift, -1.0, 0.0) - 1.0;

    final doubleSeparatorWidth = separatorWidth * 2;

    // double listWidth =
    //     lerpDouble(
    //       lerpDouble(0.0, width, flexFraction)!,
    //       paddingRect.width,
    //       shiftListFraction,
    //     )!;

    // double detailWidth =
    //     lerpDouble(
    //       lerpDouble(width, 0.0, flexFraction)!,
    //       paddingRect.width,
    //       shiftDetailFraction,
    //     )!;
    double listFlexWidth = lerpDouble(0.0, availableWidth, flexFraction)!;

    double detailFlexWidth = lerpDouble(availableWidth, 0.0, flexFraction)!;

    double listWidthCorrection = 0.0;
    final listDelta = paddingRect.width - listFlexWidth;
    if (listDelta <= doubleSeparatorWidth) {
      listWidthCorrection =
          lerpDouble(
            0.0,
            doubleSeparatorWidth,
            1.0 - listDelta / doubleSeparatorWidth,
          )!;
    }

    double detailWidthCorrection = 0.0;
    final detailDelta = paddingRect.width - detailFlexWidth;
    if (detailDelta <= doubleSeparatorWidth) {
      detailWidthCorrection =
          lerpDouble(
            0.0,
            doubleSeparatorWidth,
            1.0 - detailDelta / doubleSeparatorWidth,
          )!;
    }
    listFlexWidth += listWidthCorrection;
    detailFlexWidth += detailWidthCorrection;

    final listWidth =
        lerpDouble(listFlexWidth, paddingRect.width, shiftListFraction)!;
    final detailWidth =
        lerpDouble(detailFlexWidth, paddingRect.width, shiftDetailFraction)!;

    final listFlexX = paddingRect.left;
    final detailFlexX =
        listFlexX +
        listWidth +
        separatorWidth -
        detailWidthCorrection -
        listWidthCorrection;

    final listShiftX =
        lerpDouble(0.0, -listWidth, shiftDetailFraction)! +
        lerpDouble(0.0, -padding.left - separatorWidth, shiftDetailFraction)!;
    final detailShiftX =
        lerpDouble(0.0, padding.right, shiftListFraction)! +
        lerpDouble(0.0, -listWidth - separatorWidth, shiftDetailFraction)!;

    // final separatorFlexX =
    //     lerpDouble(
    //       paddingRect.left,
    //       paddingRect.right - separatorWidth,
    //       flexFraction,
    //     )!;
    final separatorFlexX = listWidth + listFlexX - listWidthCorrection;
    final separatorShiftX =
        lerpDouble(
          0.0,
          -listWidth - padding.left - separatorWidth,
          shiftDetailFraction,
        )! +
        lerpDouble(0.0, padding.right, shiftListFraction)!;

    final listX = listFlexX + listShiftX;
    final detailX = detailFlexX + detailShiftX;
    final separatorX = separatorFlexX + separatorShiftX;
    // final separatorX = switch (shift) {
    //   > 0.0 => lerpDouble(separatorFlexX, size.width, shiftListFraction)!,
    //   < 0.0 =>
    //     lerpDouble(separatorFlexX, -separatorWidth, shiftDetailFraction)!,
    //   _ => separatorFlexX,
    // };

    if (hasSeparator) {
      positionChild(
        _TwoPaneLayoutSlot.separator,
        Offset(separatorX, paddingRect.top),
      );
    }

    if (hasList && hasDetail) {
      layoutChild(
        _TwoPaneLayoutSlot.list,
        BoxConstraints.tightFor(width: listWidth, height: maxHeight),
      );
      layoutChild(
        _TwoPaneLayoutSlot.detail,
        BoxConstraints.tightFor(width: detailWidth, height: maxHeight),
      );

      positionChild(_TwoPaneLayoutSlot.list, Offset(listX, paddingRect.top));
      positionChild(
        _TwoPaneLayoutSlot.detail,
        Offset(detailX, paddingRect.top),
      );
    } else if (hasList) {
      layoutChild(
        _TwoPaneLayoutSlot.list,
        BoxConstraints.tightFor(width: maxWidth, height: maxHeight),
      );
      positionChild(_TwoPaneLayoutSlot.list, paddingRect.topLeft);
    } else if (hasDetail) {
      layoutChild(
        _TwoPaneLayoutSlot.detail,
        BoxConstraints.tightFor(width: maxWidth, height: maxHeight),
      );
      positionChild(_TwoPaneLayoutSlot.detail, paddingRect.topLeft);
    }
  }

  @override
  bool shouldRelayout(covariant _TwoPaneLayoutDelegate oldDelegate) {
    return shift != oldDelegate.shift ||
        flex != oldDelegate.flex ||
        padding != oldDelegate.padding;
  }
}

class TwoPaneLayout extends StatelessWidget {
  const TwoPaneLayout({
    super.key,
    this.shift = 0.0,
    this.flex = const TwoPaneLayoutFlexFactor(0.0),
    this.padding = EdgeInsets.zero,
    required this.list,
    this.separator,
    required this.detail,
  });

  final double shift;
  final TwoPaneLayoutFlexFactor flex;
  final EdgeInsetsGeometry padding;
  final Widget list;
  final Widget? separator;
  final Widget detail;

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final resolvedPadding = padding.resolve(textDirection);
    return CustomMultiChildLayout(
      delegate: _TwoPaneLayoutDelegate(
        shift: shift,
        flex: flex,
        padding: resolvedPadding,
      ),
      children: [
        LayoutId(id: _TwoPaneLayoutSlot.list, child: list),
        if (separator != null)
          LayoutId(id: _TwoPaneLayoutSlot.separator, child: separator!),
        LayoutId(id: _TwoPaneLayoutSlot.detail, child: detail),
      ],
    );
  }
}
