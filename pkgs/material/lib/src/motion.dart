import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

@immutable
class EasingThemeData extends ThemeExtension<EasingThemeData>
    with Diagnosticable {
  const EasingThemeData({
    Curve? linear,
    Curve? emphasized,
    Curve? emphasizedAccelerate,
    Curve? emphasizedDecelerate,
    Curve? standard,
    Curve? standardAccelerate,
    Curve? standardDecelerate,
    Curve? legacy,
    Curve? legacyAccelerate,
    Curve? legacyDecelerate,
  }) : _linear = linear,
       _emphasized = emphasized,
       _emphasizedAccelerate = emphasizedAccelerate,
       _emphasizedDecelerate = emphasizedDecelerate,
       _standard = standard,
       _standardAccelerate = standardAccelerate,
       _standardDecelerate = standardDecelerate,
       _legacy = legacy,
       _legacyAccelerate = legacyAccelerate,
       _legacyDecelerate = legacyDecelerate;

  final Curve? _linear;
  final Curve? _emphasized;
  final Curve? _emphasizedAccelerate;
  final Curve? _emphasizedDecelerate;
  final Curve? _standard;
  final Curve? _standardAccelerate;
  final Curve? _standardDecelerate;
  final Curve? _legacy;
  final Curve? _legacyDecelerate;
  final Curve? _legacyAccelerate;

  /// The linear easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get linear => _linear ?? Easing.linear;

  /// The emphasized easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get emphasized => _emphasized ?? Easing.emphasized;

  /// The emphasizedAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get emphasizedAccelerate =>
      _emphasizedAccelerate ?? Easing.emphasizedAccelerate;

  /// The emphasizedDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get emphasizedDecelerate =>
      _emphasizedDecelerate ?? Easing.emphasizedDecelerate;

  /// The standard easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get standard => _standard ?? Easing.standard;

  /// The standardAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get standardAccelerate =>
      _standardAccelerate ?? Easing.standardAccelerate;

  /// The standardDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get standardDecelerate =>
      _standardDecelerate ?? Easing.standardDecelerate;

  /// The legacy easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get legacy => _legacy ?? Easing.legacy;

  /// The legacyDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get legacyDecelerate => _legacyDecelerate ?? Easing.legacyDecelerate;

  /// The legacyAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Curve get legacyAccelerate => _legacyAccelerate ?? Easing.legacyAccelerate;

  @override
  EasingThemeData copyWith({
    Curve? linear,
    Curve? emphasized,
    Curve? emphasizedAccelerate,
    Curve? emphasizedDecelerate,
    Curve? standard,
    Curve? standardAccelerate,
    Curve? standardDecelerate,
    Curve? legacy,
    Curve? legacyAccelerate,
    Curve? legacyDecelerate,
  }) => EasingThemeData(
    linear: linear ?? _linear,
    emphasized: emphasized ?? _emphasized,
    emphasizedAccelerate: emphasizedAccelerate ?? _emphasizedAccelerate,
    emphasizedDecelerate: emphasizedDecelerate ?? _emphasizedDecelerate,
    standard: standard ?? _standard,
    standardAccelerate: standardAccelerate ?? _standardAccelerate,
    standardDecelerate: standardDecelerate ?? _standardDecelerate,
    legacy: legacy ?? _legacy,
    legacyAccelerate: legacyAccelerate ?? _legacyAccelerate,
    legacyDecelerate: legacyDecelerate ?? _legacyDecelerate,
  );

  @override
  EasingThemeData lerp(covariant EasingThemeData? other, double t) {
    return EasingThemeData(
      linear: t < 0.5 ? _linear : other?._linear,
      emphasized: t < 0.5 ? _emphasized : other?._emphasized,
      emphasizedAccelerate:
          t < 0.5 ? _emphasizedAccelerate : other?._emphasizedAccelerate,
      emphasizedDecelerate:
          t < 0.5 ? _emphasizedDecelerate : other?._emphasizedDecelerate,
      standard: t < 0.5 ? _standard : other?._standard,
      standardAccelerate:
          t < 0.5 ? _standardAccelerate : other?._standardAccelerate,
      standardDecelerate:
          t < 0.5 ? _standardDecelerate : other?._standardDecelerate,
      legacy: t < 0.5 ? _legacy : other?._legacy,
      legacyAccelerate: t < 0.5 ? _legacyAccelerate : other?._legacyAccelerate,
      legacyDecelerate: t < 0.5 ? _legacyDecelerate : other?._legacyDecelerate,
    );
  }

  EasingThemeData merge(EasingThemeData? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      linear: other._linear,
      emphasized: other._emphasized,
      emphasizedAccelerate: other._emphasizedAccelerate,
      emphasizedDecelerate: other._emphasizedDecelerate,
      standard: other._standard,
      standardDecelerate: other._standardDecelerate,
      standardAccelerate: other._standardAccelerate,
      legacy: other._legacy,
      legacyDecelerate: other._legacyDecelerate,
      legacyAccelerate: other._legacyAccelerate,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Curve?>("linear", linear, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Curve?>("emphasized", emphasized, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "emphasizedAccelerate",
        emphasizedAccelerate,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "emphasizedDecelerate",
        emphasizedDecelerate,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>("standard", standard, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "standardAccelerate",
        standardAccelerate,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "standardDecelerate",
        standardDecelerate,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>("legacy", legacy, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "legacyAccelerate",
        legacyAccelerate,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Curve?>(
        "legacyDecelerate",
        legacyDecelerate,
        defaultValue: null,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EasingThemeData &&
        _linear == other._linear &&
        _emphasized == other._emphasized &&
        _emphasizedAccelerate == other._emphasizedAccelerate &&
        _emphasizedDecelerate == other._emphasizedDecelerate &&
        _standard == other._standard &&
        _standardAccelerate == other._standardAccelerate &&
        _standardDecelerate == other._standardDecelerate &&
        _legacy == other._legacy &&
        _legacyAccelerate == other._legacyAccelerate &&
        _legacyDecelerate == other._legacyDecelerate;
  }

  @override
  int get hashCode => Object.hash(
    _linear,
    _emphasized,
    _emphasizedAccelerate,
    _emphasizedDecelerate,
    _standard,
    _standardAccelerate,
    _standardDecelerate,
    _legacy,
    _legacyAccelerate,
    _legacyDecelerate,
  );
}

class EasingTheme extends InheritedTheme {
  const EasingTheme({super.key, required this.data, required super.child});

  final EasingThemeData data;

  @override
  bool updateShouldNotify(covariant EasingTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) =>
      EasingTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<EasingThemeData>("data", data));
  }

  static EasingThemeData? maybeOf(BuildContext context) {
    final easingTheme =
        context.dependOnInheritedWidgetOfExactType<EasingTheme>();
    return easingTheme?.data ?? Theme.of(context).easingTheme;
  }

  static EasingThemeData of(BuildContext context) {
    return maybeOf(context) ?? const EasingThemeData();
  }
}

@immutable
class DurationThemeData extends ThemeExtension<DurationThemeData>
    with Diagnosticable {
  const DurationThemeData({
    Duration? short1,
    Duration? short2,
    Duration? short3,
    Duration? short4,
    Duration? medium1,
    Duration? medium2,
    Duration? medium3,
    Duration? medium4,
    Duration? long1,
    Duration? long2,
    Duration? long3,
    Duration? long4,
    Duration? extralong1,
    Duration? extralong2,
    Duration? extralong3,
    Duration? extralong4,
  }) : _short1 = short1,
       _short2 = short2,
       _short3 = short3,
       _short4 = short4,
       _medium1 = medium1,
       _medium2 = medium2,
       _medium3 = medium3,
       _medium4 = medium4,
       _long1 = long1,
       _long2 = long2,
       _long3 = long3,
       _long4 = long4,
       _extralong1 = extralong1,
       _extralong2 = extralong2,
       _extralong3 = extralong3,
       _extralong4 = extralong4;

  final Duration? _short1;
  final Duration? _short2;
  final Duration? _short3;
  final Duration? _short4;
  final Duration? _medium1;
  final Duration? _medium2;
  final Duration? _medium3;
  final Duration? _medium4;
  final Duration? _long1;
  final Duration? _long2;
  final Duration? _long3;
  final Duration? _long4;
  final Duration? _extralong1;
  final Duration? _extralong2;
  final Duration? _extralong3;
  final Duration? _extralong4;

  /// The short1 duration (50ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get short1 => _short1 ?? Durations.short1;

  /// The short2 duration (100ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get short2 => _short2 ?? Durations.short2;

  /// The short3 duration (150ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get short3 => _short3 ?? Durations.short3;

  /// The short4 duration (200ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get short4 => _short4 ?? Durations.short4;

  /// The medium1 duration (250ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get medium1 => _medium1 ?? Durations.medium1;

  /// The medium2 duration (300ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get medium2 => _medium2 ?? Durations.medium2;

  /// The medium3 duration (350ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get medium3 => _medium3 ?? Durations.medium3;

  /// The medium4 duration (400ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get medium4 => _medium4 ?? Durations.medium4;

  /// The long1 duration (450ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get long1 => _long1 ?? Durations.long1;

  /// The long2 duration (500ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get long2 => _long2 ?? Durations.long2;

  /// The long3 duration (550ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get long3 => _long3 ?? Durations.long3;

  /// The long4 duration (600ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get long4 => _long4 ?? Durations.long4;

  /// The extralong1 duration (700ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get extralong1 => _extralong1 ?? Durations.extralong1;

  /// The extralong2 duration (800ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get extralong2 => _extralong2 ?? Durations.extralong2;

  /// The extralong3 duration (900ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get extralong3 => _extralong3 ?? Durations.extralong3;

  /// The extralong4 duration (1000ms) in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Duration tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#c009dec6-f29b-4503-b9f0-482af14a8bbd)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  Duration get extralong4 => _extralong4 ?? Durations.extralong4;

  @override
  DurationThemeData copyWith({
    Duration? short1,
    Duration? short2,
    Duration? short3,
    Duration? short4,
    Duration? medium1,
    Duration? medium2,
    Duration? medium3,
    Duration? medium4,
    Duration? long1,
    Duration? long2,
    Duration? long3,
    Duration? long4,
    Duration? extralong1,
    Duration? extralong2,
    Duration? extralong3,
    Duration? extralong4,
  }) => DurationThemeData(
    short1: short1 ?? _short1,
    short2: short2 ?? _short2,
    short3: short3 ?? _short3,
    short4: short4 ?? _short4,
    medium1: medium1 ?? _medium1,
    medium2: medium2 ?? _medium2,
    medium3: medium3 ?? _medium3,
    medium4: medium4 ?? _medium4,
    long1: long1 ?? _long1,
    long2: long2 ?? _long2,
    long3: long3 ?? _long3,
    long4: long4 ?? _long4,
    extralong1: extralong1 ?? _extralong1,
    extralong2: extralong2 ?? _extralong2,
    extralong3: extralong3 ?? _extralong3,
    extralong4: extralong4 ?? _extralong4,
  );

  @override
  DurationThemeData lerp(covariant DurationThemeData? other, double t) =>
      DurationThemeData(
        short1: _lerpDuration(short1, other?.short1 ?? Durations.short1, t),
        short2: _lerpDuration(short2, other?.short2 ?? Durations.short2, t),
        short3: _lerpDuration(short3, other?.short3 ?? Durations.short3, t),
        short4: _lerpDuration(short4, other?.short4 ?? Durations.short4, t),
        medium1: _lerpDuration(medium1, other?.medium1 ?? Durations.medium1, t),
        medium2: _lerpDuration(medium2, other?.medium2 ?? Durations.medium2, t),
        medium3: _lerpDuration(medium3, other?.medium3 ?? Durations.medium3, t),
        medium4: _lerpDuration(medium4, other?.medium4 ?? Durations.medium4, t),
        long1: _lerpDuration(long1, other?.long1 ?? Durations.long1, t),
        long2: _lerpDuration(long2, other?.long2 ?? Durations.long2, t),
        long3: _lerpDuration(long3, other?.long3 ?? Durations.long3, t),
        long4: _lerpDuration(long4, other?.long4 ?? Durations.long4, t),
        extralong1: _lerpDuration(
          extralong1,
          other?.extralong1 ?? Durations.extralong1,
          t,
        ),
        extralong2: _lerpDuration(
          extralong2,
          other?.extralong2 ?? Durations.extralong2,
          t,
        ),
        extralong3: _lerpDuration(
          extralong3,
          other?.extralong3 ?? Durations.extralong3,
          t,
        ),
        extralong4: _lerpDuration(
          extralong4,
          other?.extralong4 ?? Durations.extralong4,
          t,
        ),
      );

  DurationThemeData merge(DurationThemeData? other) {
    if (other == null) {
      return this;
    }
    return copyWith(
      short1: other._short1,
      short2: other._short2,
      short3: other._short3,
      short4: other._short4,
      medium1: other._medium1,
      medium2: other._medium2,
      medium3: other._medium3,
      medium4: other._medium4,
      long1: other._long1,
      long2: other._long2,
      long3: other._long3,
      long4: other._long4,
      extralong1: other._extralong1,
      extralong2: other._extralong2,
      extralong3: other._extralong3,
      extralong4: other._extralong4,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Duration>("short1", short1));
    properties.add(DiagnosticsProperty<Duration>("short2", short2));
    properties.add(DiagnosticsProperty<Duration>("short3", short3));
    properties.add(DiagnosticsProperty<Duration>("short4", short4));
    properties.add(DiagnosticsProperty<Duration>("medium1", medium1));
    properties.add(DiagnosticsProperty<Duration>("medium2", medium2));
    properties.add(DiagnosticsProperty<Duration>("medium3", medium3));
    properties.add(DiagnosticsProperty<Duration>("medium4", medium4));
    properties.add(DiagnosticsProperty<Duration>("long1", long1));
    properties.add(DiagnosticsProperty<Duration>("long2", long2));
    properties.add(DiagnosticsProperty<Duration>("long3", long3));
    properties.add(DiagnosticsProperty<Duration>("long4", long4));
    properties.add(DiagnosticsProperty<Duration>("extralong1", extralong1));
    properties.add(DiagnosticsProperty<Duration>("extralong2", extralong2));
    properties.add(DiagnosticsProperty<Duration>("extralong3", extralong3));
    properties.add(DiagnosticsProperty<Duration>("extralong4", extralong4));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DurationThemeData &&
        _short1 == other._short1 &&
        _short2 == other._short2 &&
        _short3 == other._short3 &&
        _short4 == other._short4 &&
        _medium1 == other._medium1 &&
        _medium2 == other._medium2 &&
        _medium3 == other._medium3 &&
        _medium4 == other._medium4 &&
        _long1 == other._long1 &&
        _long2 == other._long2 &&
        _long3 == other._long3 &&
        _long4 == other._long4 &&
        _extralong1 == other._extralong1 &&
        _extralong2 == other._extralong2 &&
        _extralong3 == other._extralong3 &&
        _extralong4 == other._extralong4;
  }

  @override
  int get hashCode => Object.hash(
    _short1,
    _short2,
    _short3,
    _short4,
    _medium1,
    _medium2,
    _medium3,
    _medium4,
    _long1,
    _long2,
    _long3,
    _long4,
    _extralong1,
    _extralong2,
    _extralong3,
    _extralong4,
  );
}

Duration _lerpDuration(Duration a, Duration b, double t) {
  return a + (b - a) * t;
}

class DurationTheme extends InheritedTheme {
  const DurationTheme({super.key, required this.data, required super.child});

  final DurationThemeData data;

  @override
  bool updateShouldNotify(covariant DurationTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) =>
      DurationTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DurationThemeData>("data", data));
  }

  static DurationThemeData? maybeOf(BuildContext context) {
    final durationTheme =
        context.dependOnInheritedWidgetOfExactType<DurationTheme>();
    return durationTheme?.data ?? Theme.of(context).durationTheme;
  }

  static DurationThemeData of(BuildContext context) {
    return maybeOf(context) ?? const DurationThemeData();
  }
}

extension MotionThemeExtension on ThemeData {
  EasingThemeData? get easingTheme => extension<EasingThemeData>();
  DurationThemeData? get durationTheme => extension<DurationThemeData>();
}
