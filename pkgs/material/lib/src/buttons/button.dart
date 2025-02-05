import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;

const _ = flutter.FilledButton(onPressed: null, child: Text(""));

enum CommonButtonVariant { elevated, filled, filledTonal, outlined, text }

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    required this.variant,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       child = null;

  const CommonButton.elevated({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       variant = CommonButtonVariant.elevated,
       child = null;
  const CommonButton.filled({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       variant = CommonButtonVariant.filled,
       child = null;
  const CommonButton.filledTonal({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       variant = CommonButtonVariant.filledTonal,
       child = null;
  const CommonButton.outlined({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       variant = CommonButtonVariant.outlined,
       child = null;
  const CommonButton.text({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.style,
    this.focusNode,
    this.autofocus = false,
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    this.icon,
    required this.label,
  }) : assert(
         icon != null || label != null,
         "At least icon or label must be provided",
       ),
       variant = CommonButtonVariant.text,
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
    this.clipBehavior,
    this.statesController,
    this.isSemanticButton = true,
    this.tooltip,
    required this.variant,
    required Widget this.child,
  }) : icon = null,
       label = null;

  final CommonButtonVariant variant;
  final VoidCallback? onPressed;

  final VoidCallback? onLongPress;

  final ValueChanged<bool>? onHover;

  final ValueChanged<bool>? onFocusChange;

  final ButtonStyle? style;

  final Clip? clipBehavior;

  final FocusNode? focusNode;

  final bool autofocus;

  final WidgetStatesController? statesController;

  final bool? isSemanticButton;

  final String? tooltip;

  final Widget? icon;
  final Widget? label;
  final Widget? child;

  ButtonStyle? _styleOf(BuildContext context) {
    final padding = _defaultPadding(
      iconAlignment: style?.iconAlignment ?? IconAlignment.start,
      hasIcon: icon != null,
      hasLabel: label != null,
    );
    final newStyle = ButtonStyle(padding: WidgetStatePropertyAll(padding));
    return style?.merge(newStyle) ?? newStyle;
  }

  Widget? _buildLabel(BuildContext context) {
    return label != null
        ? DefaultTextStyle.merge(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          child: label!,
        )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _styleOf(context);
    return _CommonButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: resolvedStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isSemanticButton: isSemanticButton,
      tooltip: tooltip,
      variant: variant,
      child: CommonButtonChild(
        icon: icon,
        iconAlignment: resolvedStyle?.iconAlignment ?? IconAlignment.start,
        label: _buildLabel(context),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<CommonButtonVariant>("variant", variant));
  }
}

class _CommonButton extends ButtonStyleButton {
  const _CommonButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior,
    super.statesController,
    super.isSemanticButton = true,
    super.tooltip,
    required this.variant,
    required super.child,
  });

  final CommonButtonVariant variant;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return switch (variant) {
      CommonButtonVariant.elevated => _ElevatedButtonDefaults(context: context),
      CommonButtonVariant.filled => _FilledButtonDefaults(context: context),
      CommonButtonVariant.filledTonal => _FilledTonalButtonDefaults(
        context: context,
      ),
      CommonButtonVariant.outlined => _OutlinedButtonDefaults(context: context),
      CommonButtonVariant.text => _TextButtonDefaults(context: context),
    };
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return null;
  }
}

EdgeInsetsGeometry _defaultPadding({
  required IconAlignment iconAlignment,
  required bool hasIcon,
  required bool hasLabel,
}) {
  if (hasIcon && hasLabel) {
    return switch (iconAlignment) {
      IconAlignment.start => const EdgeInsetsDirectional.only(
        start: 16.0,
        end: 24.0,
      ),
      IconAlignment.end => const EdgeInsetsDirectional.only(
        start: 24.0,
        end: 16.0,
      ),
    };
  }
  if (hasIcon) return const EdgeInsetsDirectional.symmetric(horizontal: 8);
  if (hasLabel) return const EdgeInsetsDirectional.symmetric(horizontal: 24);
  return EdgeInsetsDirectional.zero;
}

class _ButtonDefaults extends ButtonStyle {
  _ButtonDefaults({required this.context})
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final StateThemeData _state = StateTheme.of(context);
  late final ElevationThemeData _elevation = ElevationTheme.of(context);

  ColorScheme get _colors => _theme.colorScheme;
  TextTheme get _text => _theme.textTheme;

  @override
  WidgetStateProperty<TextStyle?>? get textStyle =>
      WidgetStatePropertyAll(_text.labelLarge);

  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(64.0, 40.0));

  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size(double.infinity, 40.0));

  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(18.0);

  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.full);

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;

  @override
  InteractiveInkFeatureFactory? get splashFactory => _theme.splashFactory;

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateMouseCursor.clickable;
}

class _ElevatedButtonDefaults extends _ButtonDefaults
    with _ElevatedButtonElevation {
  _ElevatedButtonDefaults({required super.context});

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        return _colors.surfaceContainerLow;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });
}

class _FilledButtonDefaults extends _ButtonDefaults
    with _ContainedButtonElevation {
  _FilledButtonDefaults({required super.context});

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    _colors.onPrimary,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.onPrimary;
      });
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.onPrimary;
      });
}

class _FilledTonalButtonDefaults extends _ButtonDefaults
    with _ContainedButtonElevation {
  _FilledTonalButtonDefaults({required super.context});

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        return _colors.secondaryContainer;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    _colors.onSecondaryContainer,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.onSecondaryContainer;
      });
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.onSecondaryContainer;
      });
}

class _OutlinedButtonDefaults extends _ButtonDefaults
    with _UncontainedButtonElevation {
  _OutlinedButtonDefaults({required super.context});

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });

  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _colors.onSurface.withValues(alpha: 0.12));
        }
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: _colors.primary);
        }
        return BorderSide(color: _colors.outline);
      });
}

class _TextButtonDefaults extends _ButtonDefaults
    with _UncontainedButtonElevation {
  _TextButtonDefaults({required super.context});

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        return _colors.primary;
      });
}

mixin _ElevatedButtonElevation on _ButtonDefaults {
  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      WidgetStatePropertyAll(_colors.shadow);

  @override
  WidgetStateProperty<double?>? get elevation =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _elevation.level0;
        }
        if (states.contains(WidgetState.pressed)) {
          return _elevation.level1;
        }
        if (states.contains(WidgetState.hovered)) {
          return _elevation.level2;
        }
        if (states.contains(WidgetState.focused)) {
          return _elevation.level1;
        }
        return _elevation.level1;
      });
}

mixin _ContainedButtonElevation on _ButtonDefaults {
  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      WidgetStatePropertyAll(_colors.shadow);
  @override
  WidgetStateProperty<double>? get elevation =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return _elevation.level0;
        }
        if (states.contains(WidgetState.pressed)) {
          return _elevation.level0;
        }
        if (states.contains(WidgetState.hovered)) {
          return _elevation.level1;
        }
        if (states.contains(WidgetState.focused)) {
          return _elevation.level1;
        }
        return _elevation.level0;
      });
}

mixin _UncontainedButtonElevation on _ButtonDefaults {
  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<double?>? get elevation =>
      WidgetStatePropertyAll(_elevation.level0);
}
