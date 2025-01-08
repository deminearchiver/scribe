// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

/// A container that is typically used with [Scaffold.bottomNavigationBar].
///
/// Typically used with a [Scaffold] and a [FloatingActionButton].
///
/// {@tool snippet}
/// ```dart
/// Scaffold(
///   bottomNavigationBar: BottomAppBar(
///     color: Colors.white,
///     child: bottomAppBarContents,
///   ),
///   floatingActionButton: const FloatingActionButton(onPressed: null),
/// )
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows the [BottomAppBar], which can be configured to have a notch using the
/// [BottomAppBar.shape] property. This also includes an optional [FloatingActionButton], which illustrates
/// the [FloatingActionButtonLocation]s in relation to the [BottomAppBar].
///
/// ** See code in examples/api/lib/material/bottom_app_bar/bottom_app_bar.1.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows Material 3 [BottomAppBar] with its expected look and behaviors.
///
/// This also includes an optional [FloatingActionButton], which illustrates
/// the [FloatingActionButtonLocation.endContained].
///
/// ** See code in examples/api/lib/material/bottom_app_bar/bottom_app_bar.2.dart **
/// {@end-tool}
///
/// See also:
///
///  * [NotchedShape] which calculates the notch for a notched [BottomAppBar].
///  * [FloatingActionButton] which the [BottomAppBar] makes a notch for.
///  * [AppBar] for a toolbar that is shown at the top of the screen.
class BottomAppBar extends StatelessWidget {
  /// Creates a bottom application bar.
  ///
  /// The [clipBehavior] argument defaults to [Clip.none].
  /// Additionally, [elevation] must be non-negative.
  ///
  /// If [color], [elevation], or [shape] are null, their [BottomAppBarTheme] values will be used.
  /// If the corresponding [BottomAppBarTheme] property is null, then the default
  /// specified in the property's documentation will be used.
  const BottomAppBar({
    super.key,
    this.color,
    this.elevation,
    this.clipBehavior = Clip.none,
    this.child,
    this.padding,
    this.surfaceTintColor,
    this.shadowColor,
    this.height,
  }) : assert(elevation == null || elevation >= 0.0);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  ///
  /// Typically the child will be a [Row] whose first child
  /// is an [IconButton] with the [Icons.menu] icon.
  final Widget? child;

  /// The amount of space to surround the child inside the bounds of the [BottomAppBar].
  ///
  /// In Material 3 the padding will default to `EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0)`
  /// Otherwise the value will default to EdgeInsets.zero.
  final EdgeInsetsGeometry? padding;

  /// The bottom app bar's background color.
  ///
  /// If this property is null then [BottomAppBarTheme.color] of
  /// [ThemeData.bottomAppBarTheme] is used. If that's null and [ThemeData.useMaterial3]
  /// is true, the default value is [ColorScheme.surface]; if [ThemeData.useMaterial3]
  /// is false, then the default value is `Color(0xFF424242)` in dark theme and
  /// [Colors.white] in light theme.
  final Color? color;

  /// The z-coordinate at which to place this bottom app bar relative to its
  /// parent.
  ///
  /// This controls the size of the shadow below the bottom app bar. The
  /// value is non-negative.
  ///
  /// If this property is null then [BottomAppBarTheme.elevation] of
  /// [ThemeData.bottomAppBarTheme] is used. If that's null and
  /// [ThemeData.useMaterial3] is true, than the default value is 3 else is 8.
  final double? elevation;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.none].
  final Clip clipBehavior;

  /// A custom color for the Material 3 surface-tint elevation effect.
  ///
  /// This is not recommended for use. [Material 3 spec](https://m3.material.io/styles/color/the-color-system/color-roles)
  /// introduced a set of tone-based surfaces and surface containers in its [ColorScheme],
  /// which provide more flexibility. The intention is to eventually remove surface tint color from
  /// the framework.
  ///
  /// If this property is null, then [BottomAppBarTheme.surfaceTintColor]
  /// of [ThemeData.bottomAppBarTheme] is used. If that is also null, the default
  /// value is [Colors.transparent].
  ///
  /// Ignored if [ThemeData.useMaterial3] is false.
  ///
  /// See [Material.surfaceTintColor] for more details on how this overlay is applied.
  final Color? surfaceTintColor;

  /// The color of the shadow below the app bar.
  ///
  /// If this property is null, then [BottomAppBarTheme.shadowColor] of
  /// [ThemeData.bottomAppBarTheme] is used. If that is also null, the default value
  /// is fully opaque black for Material 2, and transparent for Material 3.
  ///
  /// See also:
  ///
  ///  * [elevation], which defines the size of the shadow below the app bar.
  ///  * [shape], which defines the shape of the app bar and its shadow.
  final Color? shadowColor;

  /// The double value used to indicate the height of the [BottomAppBar].
  ///
  /// If this is null, the default value is the minimum in relation to the content,
  /// unless [ThemeData.useMaterial3] is true, in which case it defaults to 80.0.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final BottomAppBarTheme bottomAppBarTheme = BottomAppBarTheme.of(context);
    final BottomAppBarTheme defaults = _BottomAppBarDefaultsM3(context);

    final effectiveElevation =
        elevation ?? bottomAppBarTheme.elevation ?? defaults.elevation!;
    final effectiveHeight =
        height ?? bottomAppBarTheme.height ?? defaults.height;
    final resolvedColor = color ?? bottomAppBarTheme.color ?? defaults.color!;
    final effectiveSurfaceTintColor =
        surfaceTintColor ??
        bottomAppBarTheme.surfaceTintColor ??
        defaults.surfaceTintColor!;
    final effectiveColor = ElevationOverlay.applySurfaceTint(
      resolvedColor,
      effectiveSurfaceTintColor,
      effectiveElevation,
    );
    final effectiveShadowColor =
        shadowColor ?? bottomAppBarTheme.shadowColor ?? defaults.shadowColor!;

    final layout = SizedBox(
      height: effectiveHeight,
      child: Padding(
        padding: padding ?? bottomAppBarTheme.padding ?? defaults.padding!,
        child: child,
      ),
    );

    return Material(
      type: MaterialType.canvas,
      elevation: effectiveElevation,
      shadowColor: effectiveShadowColor,
      color: effectiveColor,
      clipBehavior: clipBehavior,
      child: SafeArea(child: layout),
    );
  }
}

class _BottomAppBarDefaultsM3 extends BottomAppBarTheme {
  _BottomAppBarDefaultsM3(this.context)
    : super(
        elevation: 3.0,
        height: 80.0,
        padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
        shape: const AutomaticNotchedShape(RoundedRectangleBorder()),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surfaceContainer;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  Color? get shadowColor => Colors.transparent;
}
