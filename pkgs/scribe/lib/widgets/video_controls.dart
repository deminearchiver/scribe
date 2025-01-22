import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:material/material.dart';
import 'package:scribe/widgets/play_pause.dart';

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({
    super.key,
    required this.onPressed,
    required this.playing,
    this.filter,
  });

  final VoidCallback? onPressed;
  final bool playing;
  final ImageFilter? filter;

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late WidgetStatesController _statesController;
  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController()..addListener(_statesListener);
  }

  @override
  void didUpdateWidget(covariant PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  void _statesListener() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final states = _statesController.value;
    final active =
        !widget.playing ||
        states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.pressed);
    return _PlayPauseButtonContainer(
      duration: Durations.medium4,
      curve: Easing.standard,
      statesController: _statesController,
      backgroundColor:
          widget.playing
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.primary,
      foregroundColor:
          widget.playing
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onPrimary,
      overlayColor:
          widget.playing
              ? theme.colorScheme.primary
              : theme.colorScheme.onPrimary,
      onPressed: widget.onPressed,
      shape: active ? Shapes.full : Shapes.large,
      // child: Icon(widget.playing ? Symbols.pause : Symbols.play_arrow),
      child: ImplicitPlayPause(
        duration: Durations.medium4,
        curve: Easing.standard,
        state:
            widget.playing ? PlayPauseState.pause : PlayPauseState.play_arrow,
      ),
    );
  }
}

class _PlayPauseButtonContainer extends ImplicitlyAnimatedWidget {
  const _PlayPauseButtonContainer({
    required super.duration,
    super.curve,
    this.statesController,
    this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.overlayColor,
    required this.shape,
    this.filter,
    required this.child,
  });

  final WidgetStatesController? statesController;
  final VoidCallback? onPressed;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color overlayColor;
  final ShapeBorder shape;
  final ImageFilter? filter;

  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<_PlayPauseButtonContainer> createState() =>
      _PlayPauseButtonContainerState();
}

class _PlayPauseButtonContainerState
    extends AnimatedWidgetBaseState<_PlayPauseButtonContainer> {
  ColorTween? _backgroundColorTween;
  ColorTween? _foregroundColorTween;
  ColorTween? _overlayColorTween;
  ShapeBorderTween? _shapeTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    // _backgroundColorTween =
    //     visitor(
    //           _backgroundColorTween,
    //           widget.backgroundColor,
    //           (value) => ColorTween(begin: value as Color?),
    //         )
    //         as ColorTween?;
    // _foregroundColorTween =
    //     visitor(
    //           _foregroundColorTween,
    //           widget.foregroundColor,
    //           (value) => ColorTween(begin: value as Color?),
    //         )
    //         as ColorTween?;
    // _overlayColorTween =
    //     visitor(
    //           _overlayColorTween,
    //           widget.overlayColor,
    //           (value) => ColorTween(begin: value as Color?),
    //         )
    //         as ColorTween?;
    _shapeTween =
        visitor(
              _shapeTween,
              widget.shape,
              (value) => ShapeBorderTween(begin: value as ShapeBorder?),
            )
            as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    final stateTheme = StateTheme.of(context);
    final backgroundColor =
        _backgroundColorTween?.evaluate(animation) ?? widget.backgroundColor;
    final foregroundColor =
        _foregroundColorTween?.evaluate(animation) ?? widget.foregroundColor;
    final overlayColor =
        _overlayColorTween?.evaluate(animation) ?? widget.overlayColor;
    final shape = _shapeTween?.evaluate(animation) ?? widget.shape;
    return ClipPath(
      clipBehavior: Clip.antiAlias,
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter.grouped(
        filter: widget.filter ?? ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 56,
            maxWidth: 124,
            minHeight: 56,
            maxHeight: 56,
          ),
          child: Material(
            animationDuration: Duration.zero,
            type: MaterialType.button,
            color: backgroundColor,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              statesController: widget.statesController,
              onTap: widget.onPressed,
              mouseCursor: SystemMouseCursors.click,
              overlayColor: WidgetStateLayerColor(
                overlayColor,
                opacity: stateTheme.stateLayerOpacity,
              ),
              child: Center(
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: 24,
                    opticalSize: 24,
                    fill: 1,
                    color: foregroundColor,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum PlayPauseState { play_arrow, pause }

class ImplicitPlayPause extends ImplicitlyAnimatedWidget {
  const ImplicitPlayPause({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    required this.state,
  });

  final PlayPauseState state;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitPlayPause> createState() => _S();
}

class _S extends AnimatedWidgetBaseState<ImplicitPlayPause> {
  Tween<double>? _iconTween;

  double get _progress => switch (widget.state) {
    PlayPauseState.play_arrow => 0.0,
    PlayPauseState.pause => 1.0,
  };

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _iconTween =
        visitor(_iconTween, _progress, (value) => Tween<double>(begin: value))
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return PlayPause(progress: _iconTween?.evaluate(animation) ?? _progress);
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard({super.key, this.filter, required this.child});

  final ImageFilter? filter;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radii.large),
      child: BackdropFilter.grouped(
        filter: filter ?? ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        blendMode: BlendMode.srcOver,
        child: Material(
          animationDuration: Duration.zero,
          type: MaterialType.canvas,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          shape: Shapes.large,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.colorScheme.onSurface),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.onSurface),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
