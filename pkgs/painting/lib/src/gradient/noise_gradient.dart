import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:painting/painting.dart';

class _NoiseGradientShaderConfig {
  _NoiseGradientShaderConfig(this.shader);

  final FragmentShader shader;

  set frequency(double value) {
    shader.setFloat(3, value);
  }

  set amplitude(double value) {
    shader.setFloat(4, value);
  }

  set speed(double value) {
    shader.setFloat(5, value);
  }

  set grain(double value) {
    shader.setFloat(6, value);
  }
}

class NoiseGradient extends CustomGradient {
  NoiseGradient({
    double time = 0.0,
    double frequency = 5.0,
    double amplitude = 30.0,
    double speed = 2.0,
    double grain = 0.0,
    required List<Color> colors,
    super.transform,
  }) : super(
         delegate: NoiseGradientDelegate(
           time: time,
           amplitude: amplitude,
           frequency: frequency,
           speed: speed,
           grain: grain,
           colors: colors,
         ),
       );
}

sealed class NoiseGradientDelegate extends GradientDelegate {
  const NoiseGradientDelegate._({
    this.time = 0.0,
    this.frequency = 5.0,
    this.amplitude = 30.0,
    this.speed = 2.0,
    this.grain = 0.0,
    required this.colors,
  }) : assert(colors.length == 4, "Must have exactly 4 colors"),
       assert(grain >= 0 && grain <= 1),
       assert(speed >= 0.01 && speed <= 15);

  const factory NoiseGradientDelegate({
    double time,
    double frequency,
    double amplitude,
    double speed,
    double grain,
    required List<Color> colors,
  }) = _CachedNoiseGradientDelegate;

  const factory NoiseGradientDelegate.withProgram({
    required FragmentProgram program,
    double time,
    double frequency,
    double amplitude,
    double speed,
    double grain,
    required List<Color> colors,
  }) = _ProgramNoiseGradientDelegate;

  @protected
  FragmentProgram get _program;

  final double time;
  final double frequency;
  final double amplitude;
  final double speed;
  final double grain;
  final List<Color> colors;

  @override
  Shader createShader({
    required Rect rect,
    TextDirection? textDirection,
    Float64List? transform,
  }) {
    final shader = _program.fragmentShader();
    shader.setFloat(0, rect.left);
    shader.setFloat(1, rect.top);
    shader.setFloat(2, rect.width);
    shader.setFloat(3, rect.height);

    // Sets the current time to the shader to animate the gradient.
    shader.setFloat(4, time);

    // Sets the animation options to the shader.
    shader.setFloat(5, frequency);
    shader.setFloat(6, amplitude);
    shader.setFloat(7, speed);
    shader.setFloat(8, grain);

    // Converts and sets the gradient colors to the shader.
    int i = 9;
    for (Color color in colors) {
      shader.setFloat(i++, color.r);
      shader.setFloat(i++, color.g);
      shader.setFloat(i++, color.b);
    }
    return shader;
  }

  static Future<void> ensureInitialized() async {
    await _CachedNoiseGradientDelegate._ensureInitialized();
  }
}

class _ProgramNoiseGradientDelegate extends NoiseGradientDelegate {
  const _ProgramNoiseGradientDelegate({
    required FragmentProgram program,
    super.time,
    super.frequency,
    super.amplitude,
    super.speed,
    super.grain,
    required super.colors,
  }) : _program = program,
       super._();

  @override
  final FragmentProgram _program;

  @override
  _ProgramNoiseGradientDelegate scale(double factor) =>
      _ProgramNoiseGradientDelegate(
        program: _program,
        time: time,
        frequency: frequency,
        amplitude: amplitude,
        speed: speed,
        grain: grain,
        colors:
            colors
                .map((Color color) => Color.lerp(null, color, factor)!)
                .toList(),
      );

  @override
  _ProgramNoiseGradientDelegate withOpacity(double opacity) =>
      _ProgramNoiseGradientDelegate(
        program: _program,
        time: time,
        frequency: frequency,
        amplitude: amplitude,
        speed: speed,
        grain: grain,
        colors:
            colors.map((color) => color.withValues(alpha: opacity)).toList(),
      );
}

class _CachedNoiseGradientDelegate extends NoiseGradientDelegate {
  static FragmentProgram? _programInstance;
  static Future<FragmentProgram> _loadProgram() async {
    if (_programInstance != null) return _programInstance!;
    try {
      final program = await FragmentProgram.fromAsset(
        "packages/painting/shaders/noise_gradient.frag",
      );
      _programInstance = program;
      return program;
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      rethrow;
    }
  }

  static Future<void> _ensureInitialized() async {
    if (_programInstance == null) await _loadProgram();
  }

  const _CachedNoiseGradientDelegate({
    super.time,
    super.frequency,
    super.amplitude,
    super.speed,
    super.grain,
    required super.colors,
  }) : super._();

  @override
  FragmentProgram get _program {
    assert(_programInstance != null);
    return _programInstance!;
  }

  @override
  _CachedNoiseGradientDelegate scale(double factor) =>
      _CachedNoiseGradientDelegate(
        time: time,
        frequency: frequency,
        amplitude: amplitude,
        speed: speed,
        grain: grain,
        colors:
            colors
                .map((Color color) => Color.lerp(null, color, factor)!)
                .toList(),
      );

  @override
  _CachedNoiseGradientDelegate withOpacity(double opacity) =>
      _CachedNoiseGradientDelegate(
        time: time,
        frequency: frequency,
        amplitude: amplitude,
        speed: speed,
        grain: grain,
        colors:
            colors.map((color) => color.withValues(alpha: opacity)).toList(),
      );
}

class NoiseGradientController
    with AnimationEagerListenerMixin, AnimationLocalListenersMixin {
  NoiseGradientController({required TickerProvider vsync}) {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: "package:painting/painting.dart",
        className: '$NoiseGradientController',
        object: this,
      );
    }
    _ticker = vsync.createTicker(_tick);
  }

  //   void _maybeDispatchObjectCreation() {
  //   if (kFlutterMemoryAllocationsEnabled) {
  //     FlutterMemoryAllocations.instance.dispatchObjectCreated(
  //       library: _flutterAnimationLibrary,
  //       className: '$AnimationController',
  //       object: this,
  //     );
  //   }
  // }

  Ticker? _ticker;
  void resync(TickerProvider vsync) {
    final Ticker oldTicker = _ticker!;
    _ticker = vsync.createTicker(_tick);
    _ticker!.absorbTicker(oldTicker);
  }

  @override
  void dispose() {
    assert(() {
      if (_ticker == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            "NoiseGradientController.dispose() called more than once.",
          ),
          ErrorDescription(
            "A given $runtimeType cannot be disposed more than once.\n",
          ),
          DiagnosticsProperty<NoiseGradientController>(
            "The following $runtimeType object was disposed multiple times",
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          ),
        ]);
      }
      return true;
    }());

    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }

    _ticker?.dispose();
    _ticker = null;
    clearListeners();
    super.dispose();
  }

  Duration? _lastElapsedDuration;

  void _tick(Duration elapsed) {
    _lastElapsedDuration = elapsed;
    final double elapsedInSeconds =
        elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;
    assert(elapsedInSeconds >= 0.0);
    // _value = clampDouble(_simulation!.x(elapsedInSeconds), lowerBound, upperBound);
    _value = elapsedInSeconds;
    notifyListeners();
  }

  double _value = 0.0;
  double get value => _value;

  TickerFuture forward() {
    assert(
      _ticker != null,
      "NoiseGradientController.forward() called after NoiseGradientController.dispose()\n"
      "NoiseGradientController methods should not be used after calling dispose.",
    );
    return _ticker!.start();
  }

  TickerFuture reverse() {
    assert(
      _ticker != null,
      "NoiseGradientController.forward() called after NoiseGradientController.dispose()\n"
      "NoiseGradientController methods should not be used after calling dispose.",
    );
    return _ticker!.start();
  }
}
