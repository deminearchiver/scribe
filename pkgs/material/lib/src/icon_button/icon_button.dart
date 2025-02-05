import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;

enum IconButtonVariant { standard, filled, filledTonal, outlined }

class IconButton extends StatelessWidget {
  const IconButton({
    super.key,
    this.variant = IconButtonVariant.standard,
    this.selected,

    // ButtonStyleButton
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

    required this.icon,
  });

  const IconButton.filled({
    super.key,
    this.selected,

    // ButtonStyleButton
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

    required this.icon,
  }) : variant = IconButtonVariant.filled;

  const IconButton.filledTonal({
    super.key,
    this.selected,

    // ButtonStyleButton
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

    required this.icon,
  }) : variant = IconButtonVariant.filledTonal;

  const IconButton.outlined({
    super.key,
    this.selected,

    // ButtonStyleButton
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

    required this.icon,
  }) : variant = IconButtonVariant.outlined;

  final IconButtonVariant variant;
  final bool? selected;

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

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return _IconButton(
      variant: variant,
      selected: selected,

      // ButtonStyleButton
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHover: onHover,
      onFocusChange: onFocusChange,
      style: style,
      focusNode: focusNode,
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      statesController: statesController,
      isSemanticButton: isSemanticButton,
      tooltip: tooltip,

      child: icon,
    );
  }
}

class _IconButton extends ButtonStyleButton {
  const _IconButton({
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
    required this.selected,
    required super.child,
  });

  final IconButtonVariant variant;
  final bool? selected;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    return switch (variant) {
      IconButtonVariant.standard => _StandardIconButtonDefaults(
        context: context,
        selected: selected,
      ),
      IconButtonVariant.filled => _FilledIconButtonDefaults(
        context: context,
        selected: selected,
      ),
      IconButtonVariant.filledTonal => _FilledTonalIconButtonDefaults(
        context: context,
        selected: selected,
      ),
      IconButtonVariant.outlined => _OutlinedIconButtonDefaults(
        context: context,
        selected: selected,
      ),
    };
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    // final IconThemeData iconTheme = IconTheme.of(context);
    // final bool isDefaultSize = iconTheme.size == const IconThemeData.fallback().size;
    // final bool isDefaultColor = identical(iconTheme.color, switch (Theme.of(context).brightness) {
    //   Brightness.light => kDefaultIconDarkColor,
    //   Brightness.dark => kDefaultIconLightColor,
    // });

    // final ButtonStyle iconThemeStyle = IconButton.styleFrom(
    //   foregroundColor: isDefaultColor ? null : iconTheme.color,
    //   iconSize: isDefaultSize ? null : iconTheme.size,
    // );

    // return IconButtonTheme.of(context).style?.merge(iconThemeStyle) ?? iconThemeStyle;
    return IconButtonTheme.of(context).style?.merge(defaultStyleOf(context));
  }
}

class _IconButtonDefaults extends ButtonStyle {
  _IconButtonDefaults({required this.context, required this.selected})
    : super(
        animationDuration: kThemeChangeDuration,
        enableFeedback: true,
        alignment: Alignment.center,
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final StateThemeData _state = StateTheme.of(context);

  final bool? selected;

  @override
  WidgetStateProperty<double?>? get elevation =>
      const WidgetStatePropertyAll(0.0);
  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStatePropertyAll<Color?>? get surfaceTintColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.all(8.0));

  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size.square(40.0));
  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size.infinite);

  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(24.0);

  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.full);

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateMouseCursor.clickable;

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.padded;
}

class _StandardIconButtonDefaults extends _IconButtonDefaults {
  _StandardIconButtonDefaults({required super.context, super.selected});

  late final _iconTheme = IconTheme.of(context);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    selected == true ? _colors.primary : _colors.onSurfaceVariant,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (selected == true) {
          return _colors.primary;
        }
        if (selected == false) {
          return _colors.onSurfaceVariant;
        }
        return _iconTheme.color ?? _colors.onSurfaceVariant;
      });
}

class _FilledIconButtonDefaults extends _IconButtonDefaults {
  _FilledIconButtonDefaults({required super.context, bool? selected})
    : super(selected: selected ?? true);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        if (selected != false) {
          return _colors.primary;
        }
        return _colors.surfaceContainerHighest;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    selected != false ? _colors.onPrimary : _colors.primary,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (selected != false) {
          return _colors.onPrimary;
        }
        return _colors.primary;
      });
}

class _FilledTonalIconButtonDefaults extends _IconButtonDefaults {
  _FilledTonalIconButtonDefaults({required super.context, bool? selected})
    : super(selected: selected ?? true);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        if (selected != false) {
          return _colors.secondaryContainer;
        }
        return _colors.surfaceContainerHighest;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    selected != false ? _colors.onSecondaryContainer : _colors.onSurfaceVariant,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (selected != false) {
          return _colors.onSecondaryContainer;
        }
        return _colors.onSurfaceVariant;
      });
}

class _OutlinedIconButtonDefaults extends _IconButtonDefaults {
  _OutlinedIconButtonDefaults({required super.context, bool? selected})
    : super(selected: selected ?? false);

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (selected == true) {
          if (states.contains(WidgetState.disabled)) {
            return _colors.onSurface.withValues(alpha: 0.12);
          }
          return _colors.inverseSurface;
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<BorderSide?>? get side =>
      WidgetStateProperty.resolveWith((states) {
        if (selected == true) {
          return BorderSide.none;
        }
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _colors.onSurface.withValues(alpha: 0.12));
        }
        return BorderSide(color: _colors.outline);
      });

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.38);
        }
        if (selected == true) {
          return _colors.onInverseSurface;
        }
        return _colors.onSurfaceVariant;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((states) {
        final opacity = _state.stateLayerOpacity.resolve(states);
        Color color;
        if (selected == true) {
          color = _colors.onInverseSurface;
        } else {
          if (states.contains(WidgetState.pressed)) {
            color = _colors.onSurface;
          } else {
            color = _colors.onSurfaceVariant;
          }
        }
        if (opacity == 0.0) return color.withAlpha(0);
        return color.withValues(alpha: opacity);
      });
}

const _ = flutter.IconButton(onPressed: null, icon: Placeholder());
