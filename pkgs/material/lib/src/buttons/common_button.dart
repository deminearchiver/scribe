import "package:flutter/foundation.dart";
import "package:material/material.dart";
import "package:flutter/material.dart"
    as flutter
    show ElevatedButton, FilledButton, OutlinedButton, TextButton;

part 'defaults.dart';
part 'elevated_button.dart';
part 'filled_button.dart';
part 'filled_tonal_button.dart';
part 'outlined_button.dart';
part 'text_button.dart';

const double _kIconPadding = 16.0;
const double _kLabelPadding = 24.0;
const double _kIconLabelGap = 8.0;

abstract class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.iconAlignment = IconAlignment.start,
    this.icon,
    required this.label,
  }) : assert(icon != null || label != null),
       child = null;

  const CommonButton.custom({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.statesController,
    this.iconAlignment = IconAlignment.start,
    required this.child,
  }) : icon = null,
       label = null;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final ButtonStyle? style;
  final FocusNode? focusNode;

  final bool autofocus;

  final Clip clipBehavior;

  final WidgetStatesController? statesController;

  final Widget? icon;

  final Widget? label;

  final Widget? child;

  /// {@macro flutter.material.ButtonStyleButton.iconAlignment}
  final IconAlignment iconAlignment;

  @protected
  ButtonStyle? themeStyleOf(BuildContext context);

  @protected
  Widget buildButton({
    required BuildContext context,
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip? clipBehavior,
    WidgetStatesController? statesController,
    required Widget child,
  });

  ButtonStyle _getButtonStyle(BuildContext context) {
    final minimumSize = label == null ? const Size(48, 40) : null;
    final inheritedStyle = CommonButtonTheme.of(context)?.style;
    final defaultPadding = _defaultPadding(
      hasIcon: icon != null,
      hasLabel: label != null,
    );
    final padding = child == null ? defaultPadding : EdgeInsets.zero;
    final newStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(minimumSize),
    );
    final defaultedStyle = inheritedStyle?.merge(newStyle) ?? newStyle;
    return style?.merge(defaultedStyle) ?? defaultedStyle;
  }

  @override
  Widget build(BuildContext context) {
    final content =
        child ??
        CommonButtonChild(
          icon: icon,
          iconAlignment: iconAlignment,
          label: label,
        );
    return buildButton(
      context: context,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: _getButtonStyle(context),
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      child: child != null ? _CustomButtonChildMarker(child: content) : content,
    );
  }

  static EdgeInsetsGeometry _defaultPadding({
    required bool hasIcon,
    required bool hasLabel,
    IconAlignment iconAlignment = IconAlignment.start,
  }) {
    if (hasIcon && hasLabel) {
      return switch (iconAlignment) {
        IconAlignment.start => const EdgeInsetsDirectional.only(
          start: _kIconPadding,
          end: _kLabelPadding,
        ),
        IconAlignment.end => const EdgeInsetsDirectional.only(
          start: _kLabelPadding,
          end: _kIconPadding,
        ),
      };
    }
    if (hasIcon) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 8);
    }
    if (hasLabel) {
      return const EdgeInsetsDirectional.symmetric(horizontal: _kLabelPadding);
    }
    return EdgeInsetsDirectional.zero;
  }

  static _CustomButtonChildMarker? _maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_CustomButtonChildMarker>();
  }

  static bool _isCustomOf(BuildContext context) {
    return _maybeOf(context) != null;
  }

  // static _CustomButtonChildScope _of(BuildContext context) {
  //   final result = _maybeOf(context);
  //   assert(result != null);
  //   return result!;
  // }

  // static EdgeInsetsGeometry? maybePaddingOf(BuildContext context) {
  //   return _maybeOf(context)?.padding;
  // }

  // static EdgeInsetsGeometry paddingOf(BuildContext context) {
  //   return _of(context).padding;
  // }
}

class CommonButtonChild extends StatelessWidget {
  const CommonButtonChild({
    super.key,
    this.icon,
    this.label,
    this.iconAlignment = IconAlignment.start,
  }) : assert((icon != null || label != null));

  final Widget? icon;
  final Widget? label;
  final IconAlignment iconAlignment;

  Widget _buildDefaultTextStyle(BuildContext context, Widget child) {
    return DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (label != null && icon != null) {
      return _ButtonWithIconAndLabelChild(
        icon: icon!,
        iconAlignment: iconAlignment,
        label: _buildDefaultTextStyle(context, label!),
      );
    }
    if (icon != null) return _ButtonWithIconChild(icon: icon!);
    return _ButtonWithLabelChild(
      label: _buildDefaultTextStyle(context, label!),
    );
  }
}

class _CustomButtonChildMarker extends InheritedWidget {
  const _CustomButtonChildMarker({super.key, required super.child});

  @override
  bool updateShouldNotify(covariant _CustomButtonChildMarker oldWidget) {
    return false;
  }
}

class _ButtonWithIconChild extends StatelessWidget {
  const _ButtonWithIconChild({super.key, required this.icon});

  final Widget icon;

  Widget _buildContent(BuildContext context) {
    return IconTheme.merge(
      data: const IconThemeData(size: 24, opticalSize: 24),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = CommonButton._isCustomOf(context);
    final child = _buildContent(context);
    if (isCustom) {
      return Padding(
        padding: CommonButton._defaultPadding(hasIcon: true, hasLabel: false),
        child: child,
      );
    }
    return child;
  }
}

class _ButtonWithLabelChild extends StatelessWidget {
  const _ButtonWithLabelChild({super.key, required this.label});

  final Widget label;

  Widget _buildContent(BuildContext context) {
    return label;
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = CommonButton._isCustomOf(context);
    final child = _buildContent(context);
    if (isCustom) {
      return Padding(
        padding: CommonButton._defaultPadding(hasIcon: false, hasLabel: true),
        child: child,
      );
    }
    return child;
  }
}

class _ButtonWithIconAndLabelChild extends StatelessWidget {
  const _ButtonWithIconAndLabelChild({
    super.key,
    required this.icon,
    this.iconAlignment = IconAlignment.start,
    required this.label,
  });

  final Widget icon;
  final Widget label;
  final IconAlignment iconAlignment;

  Widget _buildContent(BuildContext context) {
    final wrappedIcon = IconTheme.merge(
      data: const IconThemeData(size: 18, opticalSize: 18, fill: 1),
      child: icon,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: _kIconLabelGap,
      children: switch (iconAlignment) {
        IconAlignment.start => [wrappedIcon, Flexible(child: label)],
        IconAlignment.end => [Flexible(child: label), wrappedIcon],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = CommonButton._isCustomOf(context);
    final child = _buildContent(context);
    if (isCustom) {
      return Padding(
        padding: CommonButton._defaultPadding(hasIcon: true, hasLabel: true),
        child: child,
      );
    }
    return child;
  }
}

class CommonButtonTheme extends InheritedTheme {
  const CommonButtonTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final CommonButtonThemeData data;

  @override
  bool updateShouldNotify(covariant CommonButtonTheme oldWidget) {
    return data != oldWidget.data;
  }

  static CommonButtonThemeData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CommonButtonTheme>()
        ?.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CommonButtonTheme(data: data, child: child);
  }
}

@immutable
class CommonButtonThemeData with Diagnosticable {
  const CommonButtonThemeData({this.style});

  final ButtonStyle? style;

  static CommonButtonThemeData? lerp(
    CommonButtonThemeData? a,
    CommonButtonThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return CommonButtonThemeData(
      style: ButtonStyle.lerp(a?.style, b?.style, t),
    );
  }

  @override
  int get hashCode => style.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CommonButtonThemeData && other.style == style;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ButtonStyle>("style", style, defaultValue: null),
    );
  }
}
