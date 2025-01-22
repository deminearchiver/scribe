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
  }) : assert(icon != null || label != null);

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

  Widget _buildChild(BuildContext context) {
    if (label == null) return _ButtonWithLabelChild(icon: icon!);
    if (icon != null) {
      return _ButtonWithIconChild(
        icon: icon!,
        label: label!,
        iconAlignment: iconAlignment,
      );
    }
    return label!;
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final EdgeInsetsGeometry padding =
        label == null
            ? const EdgeInsetsDirectional.symmetric(horizontal: 8)
            : icon != null
            ? switch (iconAlignment) {
              IconAlignment.start => const EdgeInsetsDirectional.only(
                start: _kIconPadding,
                end: _kLabelPadding,
              ),
              IconAlignment.end => const EdgeInsetsDirectional.only(
                start: _kLabelPadding,
                end: _kIconPadding,
              ),
            }
            : const EdgeInsetsDirectional.symmetric(horizontal: _kLabelPadding);
    final minimumSize = label == null ? const Size(48, 40) : null;
    // final defaultStyle = themeStyleOf(context);
    final inheritedStyle = CommonButtonTheme.of(context)?.style;
    final newStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(minimumSize),
    );
    final defaultedStyle = inheritedStyle?.merge(newStyle) ?? newStyle;
    return style?.merge(defaultedStyle) ?? defaultedStyle;
  }

  @override
  Widget build(BuildContext context) {
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
      child: _buildChild(context),
    );
  }
}

class _ButtonWithLabelChild extends StatelessWidget {
  const _ButtonWithLabelChild({super.key, required this.icon});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconTheme.merge(
      data: const IconThemeData(size: 24, opticalSize: 24),
      child: icon,
    );
  }
}

// class _ButtonWithIconChild extends StatelessWidget {
//   const _ButtonWithIconChild({
//     this.icon,
//     this.label,
//     this.iconAlignment = IconAlignment.start,
//   }): assert(icon != null || label != null);

//   final Widget? icon;
//   final Widget? label;
//   final IconAlignment iconAlignment;

//   @override
//   Widget build(BuildContext context) {
//     final wrappedIcon = IconTheme.merge(
//       data: const IconThemeData(size: 18, opticalSize: 18),
//       child: icon,
//     );
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: switch (iconAlignment) {
//         IconAlignment.start => [
//           wrappedIcon,
//           const SizedBox(width: _kIconLabelGap),
//           Flexible(child: label),
//         ],
//         IconAlignment.end => [
//           Flexible(child: label),
//           const SizedBox(width: _kIconLabelGap),
//           wrappedIcon,
//         ],
//       },
//     );
//   }
// }

class _ButtonWithIconChild extends StatelessWidget {
  const _ButtonWithIconChild({
    required this.label,
    required this.icon,
    required this.iconAlignment,
  });

  final Widget icon;
  final Widget label;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    final wrappedIcon = IconTheme.merge(
      data: const IconThemeData(size: 18, opticalSize: 18, fill: 1),
      child: icon,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: switch (iconAlignment) {
        IconAlignment.start => [
          wrappedIcon,
          const SizedBox(width: _kIconLabelGap),
          Flexible(child: label),
        ],
        IconAlignment.end => [
          Flexible(child: label),
          const SizedBox(width: _kIconLabelGap),
          wrappedIcon,
        ],
      },
    );
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
