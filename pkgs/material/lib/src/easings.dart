import 'package:material/material.dart';

class _Linear extends Curve {
  const _Linear();

  @override
  double transformInternal(double t) => t;
}

/// The set of easing curves in the Material specification.
///
/// See also:
///
/// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
/// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
/// * [Curves], for a collection of non-Material animation easing curves.
abstract final class Easing {
  /// The linear easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve linear = _Linear();

  /// The emphasized easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve emphasized = ThreePointCubic(
    Offset(0.05, 0),
    Offset(0.133333, 0.06),
    Offset(0.166666, 0.4),
    Offset(0.208333, 0.82),
    Offset(0.25, 1),
  );

  /// The emphasizedAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

  /// The emphasizedDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);

  /// The standard easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);

  /// The standardAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);

  /// The standardDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);

  /// The legacyDecelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve legacyDecelerate = Cubic(0.0, 0.0, 0.2, 1.0);

  /// The legacyAccelerate easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve legacyAccelerate = Cubic(0.4, 0.0, 1.0, 1.0);

  /// The legacy easing curve in the Material specification.
  ///
  /// See also:
  ///
  /// * [M3 guidelines: Easing tokens](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs#433b1153-2ea3-4fe2-9748-803a47bc97ee)
  /// * [M3 guidelines: Applying easing and duration](https://m3.material.io/styles/motion/easing-and-duration/applying-easing-and-duration)
  static const Curve legacy = Cubic(0.4, 0.0, 0.2, 1.0);
}
