part of 'common_button.dart';

abstract interface class _ColorsProperty {
  ColorScheme get _colors;
}

abstract interface class _TextProperty {
  TextTheme get _text;
}

abstract interface class _StateProperty {
  StateThemeData get _state;
}

class _CommonColor implements WidgetStateProperty<Color> {
  const _CommonColor({
    required this.color,
    this.disabledColor,
    this.focusColor,
  });

  final Color color;
  final Color? disabledColor;
  final Color? focusColor;

  @override
  Color resolve(Set<WidgetState> states) {
    if (disabledColor != null && states.contains(WidgetState.disabled)) {
      return disabledColor!;
    }
    if (focusColor != null && states.contains(WidgetState.focused)) {
      return focusColor!;
    }
    return color;
  }
}

mixin _ElevatedButtonDefaultsM3 on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor => _CommonColor(
    color: _colors.surfaceContainerLow,
    disabledColor: _colors.onSurface.withValues(alpha: 0.12),
  );

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get foregroundColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<Color?>? get iconColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );
}

mixin _FilledButtonDefaultsM3 on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.12),
  );

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    _colors.onPrimary,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get foregroundColor => _CommonColor(
    color: _colors.onPrimary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<Color?>? get iconColor => _CommonColor(
    color: _colors.onPrimary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );
}

mixin _FilledTonalButtonDefaultsM3 on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor => _CommonColor(
    color: _colors.secondaryContainer,
    disabledColor: _colors.onSurface.withValues(alpha: 0.12),
  );

  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    _colors.onSecondaryContainer,
    opacity: _state.stateLayerOpacity,
  );

  @override
  WidgetStateProperty<Color?>? get foregroundColor => _CommonColor(
    color: _colors.onSecondaryContainer,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<Color?>? get iconColor => _CommonColor(
    color: _colors.onSecondaryContainer,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );
}
mixin _OutlinedButtonDefaultsM3 on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const WidgetStatePropertyAll(Colors.transparent);
  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get foregroundColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<Color?>? get iconColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<BorderSide>? get side =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _colors.onSurface.withValues(alpha: 0.12));
        }
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: _colors.primary);
        }
        return BorderSide(color: _colors.outline);
      });
}
mixin _TextButtonDefaultsM3 on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      const WidgetStatePropertyAll(Colors.transparent);
  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(_colors.primary, opacity: _state.stateLayerOpacity);

  @override
  WidgetStateProperty<Color?>? get foregroundColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );

  @override
  WidgetStateProperty<Color?>? get iconColor => _CommonColor(
    color: _colors.primary,
    disabledColor: _colors.onSurface.withValues(alpha: 0.38),
  );
}

mixin _Shared on ButtonStyle
    implements _ColorsProperty, _TextProperty, _StateProperty {
  @override
  WidgetStateProperty<TextStyle?>? get textStyle =>
      WidgetStatePropertyAll(_text.labelLarge);

  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(64.0, 40.0));

  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size.infinite);

  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(StadiumBorder());

  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(18.0);

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateMouseCursor.clickable;
}

// class _FilledButtonDefaultsM3 extends ButtonStyle {
//   _FilledButtonDefaultsM3(this.context)
//    : super(
//        animationDuration: kThemeChangeDuration,
//        enableFeedback: true,
//        alignment: Alignment.center,
//      );

//   final BuildContext context;
//   late final ColorScheme _colors = Theme.of(context).colorScheme;

//   @override
//   MaterialStateProperty<TextStyle?> get textStyle =>
//     MaterialStatePropertyAll<TextStyle?>(Theme.of(context).textTheme.labelLarge);

//   @override
//   MaterialStateProperty<Color?>? get backgroundColor =>
//     MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return _colors.onSurface.withOpacity(0.12);
//       }
//       return _colors.primary;
//     });

//   @override
//   MaterialStateProperty<Color?>? get foregroundColor =>
//     MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return _colors.onSurface.withOpacity(0.38);
//       }
//       return _colors.onPrimary;
//     });

//   @override
//   MaterialStateProperty<Color?>? get overlayColor =>
//     MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.pressed)) {
//         return _colors.onPrimary.withOpacity(0.1);
//       }
//       if (states.contains(MaterialState.hovered)) {
//         return _colors.onPrimary.withOpacity(0.08);
//       }
//       if (states.contains(MaterialState.focused)) {
//         return _colors.onPrimary.withOpacity(0.1);
//       }
//       return null;
//     });

//   @override
//   MaterialStateProperty<Color>? get shadowColor =>
//     MaterialStatePropertyAll<Color>(_colors.shadow);

//   @override
//   MaterialStateProperty<Color>? get surfaceTintColor =>
//     const MaterialStatePropertyAll<Color>(Colors.transparent);

//   @override
//   MaterialStateProperty<double>? get elevation =>
//     MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return 0.0;
//       }
//       if (states.contains(MaterialState.pressed)) {
//         return 0.0;
//       }
//       if (states.contains(MaterialState.hovered)) {
//         return 1.0;
//       }
//       if (states.contains(MaterialState.focused)) {
//         return 0.0;
//       }
//       return 0.0;
//     });

//   @override
//   MaterialStateProperty<EdgeInsetsGeometry>? get padding =>
//     MaterialStatePropertyAll<EdgeInsetsGeometry>(_scaledPadding(context));

//   @override
//   MaterialStateProperty<Size>? get minimumSize =>
//     const MaterialStatePropertyAll<Size>(Size(64.0, 40.0));

//   // No default fixedSize

//   @override
//   MaterialStateProperty<double>? get iconSize =>
//     const MaterialStatePropertyAll<double>(18.0);

//   @override
//   MaterialStateProperty<Color>? get iconColor {
//     return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return _colors.onSurface.withOpacity(0.38);
//       }
//       if (states.contains(MaterialState.pressed)) {
//         return _colors.onPrimary;
//       }
//       if (states.contains(MaterialState.hovered)) {
//         return _colors.onPrimary;
//       }
//       if (states.contains(MaterialState.focused)) {
//         return _colors.onPrimary;
//       }
//       return _colors.onPrimary;
//     });
//   }

//   @override
//   MaterialStateProperty<Size>? get maximumSize =>
//     const MaterialStatePropertyAll<Size>(Size.infinite);

//   // No default side

//   @override
//   MaterialStateProperty<OutlinedBorder>? get shape =>
//     const MaterialStatePropertyAll<OutlinedBorder>(StadiumBorder());

//   @override
//   MaterialStateProperty<MouseCursor?>? get mouseCursor =>
//     MaterialStateProperty.resolveWith((Set<MaterialState> states) {
//       if (states.contains(MaterialState.disabled)) {
//         return SystemMouseCursors.basic;
//       }
//       return SystemMouseCursors.click;
//     });

//   @override
//   VisualDensity? get visualDensity => Theme.of(context).visualDensity;

//   @override
//   MaterialTapTargetSize? get tapTargetSize => Theme.of(context).materialTapTargetSize;

//   @override
//   InteractiveInkFeatureFactory? get splashFactory => Theme.of(context).splashFactory;
// }
