import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:painting/painting.dart';
import 'package:scribe/restorable_properties.dart';
import 'package:scribe/theme.dart';
import 'package:scribe/widgets/video_controls.dart';
import 'package:services/services.dart';
import 'package:super_editor/super_editor.dart';
import 'package:widgets/widgets.dart';
import 'package:async/async.dart';

@immutable
class VideoNode extends BlockNode {
  VideoNode({required this.id, super.metadata}) {
    initAddToMetadata({"blockType": const NamedAttribution("video")});
  }

  @override
  final String id;

  @override
  String? copyContent(NodeSelection selection) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      throw Exception(
        "VideoNode can only copy content from a UpstreamDownstreamNodeSelection.",
      );
    }
    return !selection.isCollapsed ? "Video url" : null;
  }

  @override
  VideoNode copyWithAddedMetadata(Map<String, dynamic> newProperties) {
    return VideoNode(id: id, metadata: {...metadata, ...newProperties});
  }

  @override
  VideoNode copyAndReplaceMetadata(Map<String, dynamic> newMetadata) {
    return VideoNode(id: id, metadata: newMetadata);
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is VideoNode;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ImageNode &&
            runtimeType == other.runtimeType &&
            id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

class VideoComponentBuilder implements ComponentBuilder {
  const VideoComponentBuilder();
  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! VideoNode) return null;
    return VideoComponentViewModel(nodeId: node.id);
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! VideoComponentViewModel) return null;
    return VideoComponent(
      restorationId: componentViewModel.nodeId,
      componentKey: componentContext.componentKey,
      selection:
          componentViewModel.selection?.nodeSelection
              as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
    );
  }
}

class VideoComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  VideoComponentViewModel({
    required super.nodeId,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  @override
  VideoComponentViewModel copy() {
    return VideoComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      selection: selection,
      selectionColor: selectionColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        super == other &&
            other is VideoComponentViewModel &&
            runtimeType == other.runtimeType &&
            nodeId == other.nodeId &&
            selection == other.selection &&
            selectionColor == other.selectionColor;
  }

  @override
  int get hashCode => Object.hash(
    nodeId.hashCode,
    maxWidth.hashCode,
    padding.hashCode,
    selection.hashCode,
    selectionColor.hashCode,
  );
}

class VideoComponent extends StatefulWidget {
  const VideoComponent({
    super.key,
    required this.componentKey,
    this.restorationId,
    this.selection,
    this.selectionColor = Colors.transparent,
  });

  final GlobalKey componentKey;

  final String? restorationId;

  final UpstreamDownstreamNodeSelection? selection;
  final Color selectionColor;

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> with RestorationMixin {
  final _containerKey = GlobalKey();

  @override
  String? get restorationId => widget.restorationId;

  // final RestorableValue<Duration> _position = RestorableDuration(Duration.zero);

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_position, "position");
    _player.seek(_position.value);
  }

  final RestorableValue<Duration> _position = RestorableDuration(Duration.zero);

  late Player _player;
  late VideoController _videoController;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);

    // _player.stream.position.listen((event) => _position.value = event);

    _player.open(
      Media(
        "https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4",
      ),
    );
    _player.setPlaylistMode(PlaylistMode.loop);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant VideoComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _player.dispose();

    // Restorable properties
    // _position.dispose();

    super.dispose();
  }

  Future<void> _openView() async {
    final navigator = Navigator.of(context);
    navigator.push(
      _VideoRoute(
        containerKey: _containerKey,
        videoController: _videoController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSelected =
        widget.selection != null && !widget.selection!.isCollapsed;
    final theme = Theme.of(context);

    final controlsTheme = AppTheme.custom(
      brightness: theme.brightness,
      seedColor: Colors.white,
      variant: DynamicSchemeVariant.monochrome,
    );

    // return Center(
    //   child: DecoratedBox(
    //     position: DecorationPosition.foreground,
    //     decoration: BoxDecoration(
    //       color:
    //           isSelected ? widget.selectionColor.withValues(alpha: 0.5) : null,
    //     ),
    //     child: BoxComponent(
    //       key: widget.componentKey,
    //       child: SizedBox(
    //         height: 300,
    //         child: Material(
    //           color: theme.colorScheme.surfaceContainerHighest,
    //           child: Theme(
    //             data: controlsTheme,
    //             child: Video(
    //               controller: _videoController,
    //               fit: BoxFit.fitWidth,
    //               controls: (state) => ExpressiveVideoControls(state: state),
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    // return Center(
    //   child: DecoratedBox(
    //     position: DecorationPosition.foreground,
    //     decoration: BoxDecoration(
    //       color:
    //           isSelected ? widget.selectionColor.withValues(alpha: 0.5) : null,
    //     ),
    //     child: BoxComponent(
    //       key: widget.componentKey,
    //       child: SizedBox(
    //         height: 300,
    //         child: Material(
    //           color: theme.colorScheme.surfaceContainerHighest,
    //           child: Video(
    //             controller: _videoController,
    //             fit: BoxFit.fitWidth,
    //             controls: (state) => ExpressiveVideoControls(state: state),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return Center(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          color:
              isSelected ? widget.selectionColor.withValues(alpha: 0.5) : null,
        ),
        child: BoxComponent(
          key: widget.componentKey,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Material(
              key: _containerKey,
              animationDuration: Duration.zero,
              clipBehavior: Clip.antiAlias,

              color: theme.colorScheme.surfaceContainerHighest,
              shape: Shapes.extraLarge,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Video(controller: _videoController, fit: BoxFit.cover),
                  Center(
                    child: FloatingActionButton.large(
                      onPressed: _openView,
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          PathBorder(path: ShapePaths.cookie9(false)),
                        ),
                      ),
                      child: const Icon(Symbols.play_arrow),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoRoute<T> extends PageRoute<T> {
  _VideoRoute({
    required this.containerKey,
    required this.videoController,
    super.requestFocus,
    super.barrierDismissible = true,
    super.fullscreenDialog = true,
    super.settings,
  }) : super(allowSnapshotting: false);

  final GlobalKey containerKey;

  final VideoController videoController;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => Colors.black;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Durations.extralong2;

  CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );
  void _updateCurvedAnimation(Animation<double> animation) {
    if (_curvedAnimation.parent != animation) {
      _curvedAnimation.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Easing.emphasized,
        reverseCurve: Easing.emphasized.flipped,
      );
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    _updateCurvedAnimation(animation);
    final containerContext = containerKey.currentContext!;
    final navigator = Navigator.of(containerContext);
    final navigatorBox = navigator.context.findRenderObject()! as RenderBox;
    final navigatorRect =
        navigatorBox.localToGlobal(Offset.zero) & navigatorBox.size;
    final containerBox = containerContext.findRenderObject()! as RenderBox;
    final containerRect =
        containerBox.localToGlobal(Offset.zero, ancestor: navigatorBox) &
        containerBox.size;

    final rectTween = MaterialRectCenterArcTween(
      begin: containerRect,
      end: navigatorRect,
    );

    final rect = rectTween.evaluate(_curvedAnimation)!;

    final shape =
        ShapeBorder.lerp(
          Shapes.extraLarge,
          RoundedRectangleBorder(borderRadius: const Services().windowCorners),
          _curvedAnimation.value,
        )!;

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: navigator.pop,
          icon: const Icon(Symbols.close),
        ),
      ),
      body: Video(
        controller: videoController,
        fit: BoxFit.contain,
        wakelock: true,
        alignment: Alignment.center,
        controls: (state) => ExpressiveVideoControls(state: state),
      ),
    );

    if (_curvedAnimation.isCompleted) {
      return scaffold;
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: rect.topLeft,
        child: SizedBox(
          width: rect.width,
          height: rect.height,
          child: Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            color: Colors.red,
            shape: _curvedAnimation.isCompleted ? Shapes.none : shape,
            child: OverflowBox(
              maxWidth: navigatorRect.width,
              maxHeight: navigatorRect.height,
              child: scaffold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox.shrink();
  }
}

class ExpressiveVideoControls extends StatefulWidget {
  const ExpressiveVideoControls({super.key, required this.state});

  final VideoState state;

  @override
  State<ExpressiveVideoControls> createState() =>
      _ExpressiveVideoControlsState();
}

class _ExpressiveVideoControlsState extends State<ExpressiveVideoControls> {
  final List<StreamSubscription> _subscriptions = [];

  VideoController get _videoController => widget.state.widget.controller;
  Player get _player => _videoController.player;

  late bool _buffering;
  late bool _playing;
  late Duration _duration;
  late Duration _position;
  late Duration _buffer;
  late double _volume;
  late PlaylistMode _playlistMode;

  double? _seek;

  bool get _loop => _playlistMode != PlaylistMode.none;
  Future<void> _setLoop(bool value) async {
    return _player.setPlaylistMode(
      value ? PlaylistMode.single : PlaylistMode.none,
    );
  }

  @override
  void initState() {
    super.initState();
    _initInitialState();
    _initSubscriptions();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ExpressiveVideoControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.widget.controller.player !=
        oldWidget.state.widget.controller.player) {
      _disposeSubscriptions();
      _initInitialState();
      _initSubscriptions();
    }
  }

  @override
  void dispose() {
    _disposeSubscriptions();
    super.dispose();
  }

  void _initInitialState() {
    _buffering = _player.state.buffering;
    _playing = _player.state.playing;
    _duration = _player.state.duration;
    _position = _player.state.position;
    _buffer = _player.state.buffer;
    _volume = _player.state.volume;
    _playlistMode = _player.state.playlistMode;
  }

  void _initSubscriptions() {
    _subscriptions.addAll([
      _player.stream.buffering.listen((event) {
        if (mounted) setState(() => _buffering = event);
      }),
      _player.stream.playing.listen((event) {
        if (mounted) setState(() => _playing = event);
      }),
      _player.stream.duration.listen((event) {
        if (mounted) setState(() => _duration = event);
      }),
      _player.stream.position.listen((event) {
        if (mounted) setState(() => _position = event);
      }),
      _player.stream.buffer.listen((event) {
        if (mounted) setState(() => _buffer = event);
      }),
      _player.stream.volume.listen((event) {
        if (mounted) setState(() => _volume = event);
      }),
      _player.stream.playlistMode.listen((event) {
        if (mounted) setState(() => _playlistMode = event);
      }),
    ]);
  }

  void _disposeSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  Widget _buildProgressSlider(BuildContext context) {
    final positionValue =
        _seek ??
        (_duration > Duration.zero
            ? _position.inMicroseconds / _duration.inMicroseconds
            : 0.0);
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        overlayColor: Colors.transparent,
        thumbSize: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return const Size(2, 26);
          }
          if (states.contains(WidgetState.focused)) {
            return const Size(2, 26);
          }
          return const Size(4, 26);
        }),
        padding: EdgeInsets.zero,
      ),
      child: Slider(
        onChanged: (value) {
          setState(() => _seek = value);
        },
        onChangeEnd: (value) async {
          await _player.seek(_duration * value);
          if (mounted) setState(() => _seek = null);
        },
        value: positionValue,
      ),
    );
  }

  Widget _buildVolumeSlider(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 12,
        overlayColor: Colors.transparent,
        thumbSize: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return const Size(2, 26);
          }
          if (states.contains(WidgetState.focused)) {
            return const Size(2, 26);
          }
          return const Size(4, 26);
        }),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Slider(
        onChanged: (value) => _player.setVolume(value),
        value: _volume,
        min: 0.0,
        max: 100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = _duration == Duration.zero;
    final bufferProgress =
        _duration > Duration.zero
            ? _buffer.inMicroseconds / _duration.inMicroseconds
            : 0.0;
    final positionValue =
        _duration > Duration.zero
            ? _position.inMicroseconds / _duration.inMicroseconds
            : 0.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: theme.colorScheme.scrim.withValues(alpha: 0.32),
          ),
        ),
        if (!isLoading)
          // Center(
          //   child: TweenAnimationBuilder<double>(
          //     tween: Tween<double>(end: bufferProgress),
          //     duration: Durations.medium4,
          //     curve: Easing.standard,
          //     builder:
          //         (context, value, child) =>
          //             CircularProgressIndicator.ic(value: value),
          //   ),
          // ),
          if (_buffering) const Center(child: CircularProgressIndicator()),
        Positioned(
          left: 24,
          right: 24,
          bottom: 56 + 24,
          child: _buildProgressSlider(context),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: Flex.horizontal(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PlayPauseButton(
                onPressed: () => _player.playOrPause(),
                playing: _playing,
              ),
              const Spacer(),
              IntrinsicWidth(
                child: Flex.vertical(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _VolumePanel(
                      expanded: _playing,
                      duration: Durations.medium4,
                      curve: Easing.standard,
                      child: _buildVolumeSlider(context),
                    ),
                    TweenAnimationBuilder(
                      tween: Tween<double>(end: _playing ? 4.0 : 0.0),
                      duration: Durations.medium4,
                      curve: Easing.emphasized,
                      builder:
                          (context, value, child) => SizedBox(height: value),
                    ),
                    // const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(height: 56),
                      child: _ActionsPanel(
                        duration: Durations.medium4,
                        curve: Easing.standard,
                        shape:
                            _playing
                                ? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radii.extraSmall,
                                    bottom: Radii.large,
                                  ),
                                )
                                : Shapes.large,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},

                                icon: Icon(switch (_volume) {
                                  > 0.0 && < 50.0 => Symbols.volume_down,
                                  >= 50.0 => Symbols.volume_up,
                                  _ => Symbols.volume_mute,
                                }),
                              ),
                              IconButton(
                                onPressed: () => _setLoop(!_loop),
                                icon: Icon(
                                  _loop ? Symbols.repeat_on : Symbols.repeat,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},

                                icon: const Icon(
                                  Symbols.one_x_mobiledata,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},

                                icon: const Icon(
                                  Symbols.settings,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Symbols.fullscreen,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// class _RepeatIconButton extends StatefulWidget {
//   const _RepeatIconButton({super.key, required this.player});

//   final Player player;

//   @override
//   State<_RepeatIconButton> createState() => __RepeatIconButtonState();
// }

// class __RepeatIconButtonState extends State<_RepeatIconButton> {
//   StreamSubscription<PlaylistMode>? _subscription;

//   late PlaylistMode _playlistMode;

//   bool get _repeat => _playlistMode != PlaylistMode.none;

//   @override
//   void initState() {
//     super.initState();
//     _subscribe(widget.player);
//   }

//   @override
//   void didUpdateWidget(covariant _RepeatIconButton oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.player != oldWidget.player) {
//       _subscribe(widget.player);
//     }
//   }

//   @override
//   void dispose() {
//     _unsubscribe();
//     super.dispose();
//   }

//   void _subscribe(Player player) {
//     _unsubscribe();
//     _playlistMode = player.state.playlistMode;
//     _subscription = player.stream.playlistMode.listen((event) {
//       if (mounted) setState(() => _playlistMode = event);
//     });
//   }

//   void _unsubscribe() {
//     _subscription?.cancel();
//   }

//   void _onPressed() async {
//     await widget.player.setPlaylistMode(
//       _repeat ? PlaylistMode.none : PlaylistMode.single,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: _onPressed,
//       icon: Icon(_repeat ? Symbols.repeat_on : Symbols.repeat),
//     );
//   }
// }

class _ActionsPanel extends ImplicitlyAnimatedWidget {
  const _ActionsPanel({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.shape,
    this.child,
  });

  final ShapeBorder? shape;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<_ActionsPanel> createState() =>
      _ActionsPanelState();
}

class _ActionsPanelState extends AnimatedWidgetBaseState<_ActionsPanel> {
  Tween<ShapeBorder?>? _shapeBorderTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shapeBorderTween =
        visitor(
              _shapeBorderTween,
              widget.shape,
              (value) => ShapeBorderTween(begin: value),
            )
            as Tween<ShapeBorder?>?;
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      shape: _shapeBorderTween?.evaluate(animation) ?? widget.shape,
      child: widget.child,
    );
  }
}

class _VolumePanel extends ImplicitlyAnimatedWidget {
  const _VolumePanel({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    required this.expanded,
    super.onEnd,
    this.child,
  });

  final bool expanded;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<_VolumePanel> createState() =>
      _VolumePanelState();
}

class _VolumePanelState extends AnimatedWidgetBaseState<_VolumePanel> {
  double get _heightFactor => widget.expanded ? 1.0 : 0.0;

  Tween<double>? _heightFactorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _heightFactorTween =
        visitor(
              _heightFactorTween,
              _heightFactor,
              (value) => Tween<double>(begin: value),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radii.large,
          bottom: Radii.extraSmall,
        ),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: _heightFactorTween?.evaluate(animation) ?? _heightFactor,
        child: widget.child,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({super.key, this.filter, this.shape, this.child});

  final ImageFilter? filter;
  final ShapeBorder? shape;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedShape = shape ?? Shapes.large;
    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: resolvedShape,
        textDirection: Directionality.maybeOf(context),
      ),
      child: BackdropFilter.grouped(
        filter: filter ?? ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        blendMode: BlendMode.srcOver,
        child: Material(
          animationDuration: Duration.zero,
          type: MaterialType.canvas,
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          shape: resolvedShape,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.colorScheme.onSurface),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.colorScheme.onSurface),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
