import 'package:material/material.dart';

enum _CardVariant { elevated, filled, outlined }

class Card extends StatelessWidget {
  /// Creates a Material Design card.
  ///
  /// The [elevation] must be null or non-negative.
  const Card.elevated({
    super.key,
    this.animationDuration = Duration.zero,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior,
    this.child,
    this.semanticContainer = true,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.elevated;

  /// Create a filled variant of Card.
  ///
  /// Filled cards provide subtle separation from the background. This has less
  /// emphasis than elevated(default) or outlined cards.
  const Card.filled({
    super.key,
    this.animationDuration = Duration.zero,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior,
    this.child,
    this.semanticContainer = true,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.filled;

  /// Create an outlined variant of Card.
  ///
  /// Outlined cards have a visual boundary around the container. This can
  /// provide greater emphasis than the other types.
  const Card.outlined({
    super.key,
    this.animationDuration = Duration.zero,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior,
    this.child,
    this.semanticContainer = true,
  }) : assert(elevation == null || elevation >= 0.0),
       _variant = _CardVariant.outlined;

  final Duration animationDuration;

  /// The card's background color.
  ///
  /// Defines the card's [Material.color].
  ///
  /// If this property is null then the ambient [CardTheme.color] is used. If that is null,
  /// and [ThemeData.useMaterial3] is true, then [ColorScheme.surfaceContainerLow] of
  /// [ThemeData.colorScheme] is used. Otherwise, [ThemeData.cardColor] is used.
  final Color? color;

  /// The color to paint the shadow below the card.
  ///
  /// If null then the ambient [CardTheme]'s shadowColor is used.
  /// If that's null too, then the overall theme's [ThemeData.shadowColor]
  /// (default black) is used.
  final Color? shadowColor;

  /// The color used as an overlay on [color] to indicate elevation.
  ///
  /// This is not recommended for use. [Material 3 spec](https://m3.material.io/styles/color/the-color-system/color-roles)
  /// introduced a set of tone-based surfaces and surface containers in its [ColorScheme],
  /// which provide more flexibility. The intention is to eventually remove surface tint color from
  /// the framework.
  ///
  /// If this is null, no overlay will be applied. Otherwise this color
  /// will be composited on top of [color] with an opacity related
  /// to [elevation] and used to paint the background of the card.
  ///
  /// The default is [Colors.transparent].
  ///
  /// See [Material.surfaceTintColor] for more details on how this
  /// overlay is applied.
  final Color? surfaceTintColor;

  /// The z-coordinate at which to place this card. This controls the size of
  /// the shadow below the card.
  ///
  /// Defines the card's [Material.elevation].
  ///
  /// If this property is null then [CardTheme.elevation] of
  /// [ThemeData.cardTheme] is used. If that's null, the default value is 1.0.
  final double? elevation;

  /// The shape of the card's [Material].
  ///
  /// Defines the card's [Material.shape].
  ///
  /// If this property is null then [CardTheme.shape] of [ThemeData.cardTheme]
  /// is used. If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 12.0 and if [ThemeData.useMaterial3] is
  /// false, then the circular corner radius will be 4.0.
  final ShapeBorder? shape;

  /// Whether to paint the [shape] border in front of the [child].
  ///
  /// The default value is true.
  /// If false, the border will be painted behind the [child].
  final bool borderOnForeground;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// If this property is null then [CardTheme.clipBehavior] of
  /// [ThemeData.cardTheme] is used. If that's null then the behavior will be [Clip.none].
  final Clip? clipBehavior;

  /// Whether this widget represents a single semantic container, or if false
  /// a collection of individual semantic nodes.
  ///
  /// Defaults to true.
  ///
  /// Setting this flag to true will attempt to merge all child semantics into
  /// this node. Setting this flag to false will force all child semantic nodes
  /// to be explicit.
  ///
  /// This flag should be false if the card contains multiple different types
  /// of content.
  final bool semanticContainer;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  final _CardVariant _variant;

  @override
  Widget build(BuildContext context) {
    final cardTheme = CardTheme.of(context);
    final CardThemeData defaults = switch (_variant) {
      _CardVariant.elevated => _ElevatedCardDefaultsM3(context),
      _CardVariant.filled => _FilledCardDefaultsM3(context),
      _CardVariant.outlined => _OutlinedCardDefaultsM3(context),
    };

    return Semantics(
      container: semanticContainer,
      child: Material(
        animationDuration: animationDuration,
        type: MaterialType.card,
        color: color ?? cardTheme.color ?? defaults.color,
        shadowColor:
            shadowColor ?? cardTheme.shadowColor ?? defaults.shadowColor,
        surfaceTintColor:
            surfaceTintColor ??
            cardTheme.surfaceTintColor ??
            defaults.surfaceTintColor,
        elevation: elevation ?? cardTheme.elevation ?? defaults.elevation!,
        shape: shape ?? cardTheme.shape ?? defaults.shape,
        borderOnForeground: borderOnForeground,
        clipBehavior:
            clipBehavior ?? cardTheme.clipBehavior ?? defaults.clipBehavior!,
        child: Semantics(explicitChildNodes: !semanticContainer, child: child),
      ),
    );
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - Card

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _ElevatedCardDefaultsM3 extends CardThemeData {
  _ElevatedCardDefaultsM3(this.context)
    : super(
        clipBehavior: Clip.none,
        elevation: 1.0,
        margin: const EdgeInsets.all(0.0),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surfaceContainerLow;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );
}

// END GENERATED TOKEN PROPERTIES - Card

// BEGIN GENERATED TOKEN PROPERTIES - FilledCard

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _FilledCardDefaultsM3 extends CardThemeData {
  _FilledCardDefaultsM3(this.context)
    : super(
        clipBehavior: Clip.none,
        elevation: 0.0,
        margin: const EdgeInsets.all(0.0),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surfaceContainerHighest;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  );
}

// END GENERATED TOKEN PROPERTIES - FilledCard

// BEGIN GENERATED TOKEN PROPERTIES - OutlinedCard

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _OutlinedCardDefaultsM3 extends CardThemeData {
  _OutlinedCardDefaultsM3(this.context)
    : super(
        clipBehavior: Clip.none,
        elevation: 0.0,
        margin: const EdgeInsets.all(0.0),
      );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get color => _colors.surface;

  @override
  Color? get shadowColor => _colors.shadow;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
  ).copyWith(side: BorderSide(color: _colors.outlineVariant));
}

// END GENERATED TOKEN PROPERTIES - OutlinedCard
