import 'dart:async';

import 'package:scribe/widgets/video_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:super_editor/super_editor.dart';

/// [DocumentNode] that represents an image at a URL.
class VideoNode extends BlockNode with ChangeNotifier {
  VideoNode({
    required this.id,
    ExpectedSize? expectedBitmapSize,
    String altText = '',
    Map<String, dynamic>? metadata,
  }) : _expectedBitmapSize = expectedBitmapSize,
       _altText = altText {
    this.metadata = metadata;

    putMetadataValue("blockType", const NamedAttribution("video"));
  }

  @override
  final String id;

  /// The expected size of the image.
  ///
  /// Used to size the component while the image is still being loaded,
  /// so the content don't shift after the image is loaded.
  ///
  /// It's technically permissible to provide only a single expected dimension,
  /// however providing only a single dimension won't provide enough information
  /// to size an image component before the image is loaded. Providing only a
  /// width in a vertical layout won't have any visual effect. Providing only a height
  /// in a vertical layout will likely take up more space or less space than the final
  /// image because the final image will probably be scaled. Therefore, to take
  /// advantage of [ExpectedSize], you should try to provide both dimensions.
  ExpectedSize? get expectedBitmapSize => _expectedBitmapSize;
  ExpectedSize? _expectedBitmapSize;
  set expectedBitmapSize(ExpectedSize? newValue) {
    if (newValue == _expectedBitmapSize) {
      return;
    }

    _expectedBitmapSize = newValue;

    notifyListeners();
  }

  String _altText;
  String get altText => _altText;
  set altText(String newAltText) {
    if (newAltText != _altText) {
      _altText = newAltText;
      notifyListeners();
    }
  }

  @override
  String? copyContent(dynamic selection) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      throw Exception(
        'VideoNode can only copy content from a UpstreamDownstreamNodeSelection.',
      );
    }

    return !selection.isCollapsed ? "IMAGE URL???" : null;
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is VideoNode && altText == other.altText;
  }

  @override
  VideoNode copy() {
    return VideoNode(
      id: id,
      expectedBitmapSize: expectedBitmapSize,
      altText: altText,
      metadata: Map.from(metadata),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          _altText == other._altText;

  @override
  int get hashCode => id.hashCode ^ _altText.hashCode;
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
    if (componentViewModel is! VideoComponentViewModel) {
      return null;
    }
    return VideoComponent(
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
    super.padding = EdgeInsets.zero,
    super.maxWidth,
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  @override
  VideoComponentViewModel copy() => VideoComponentViewModel(
    nodeId: nodeId,
    padding: padding,
    maxWidth: maxWidth,
    selection: selection,
    selectionColor: selectionColor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is VideoComponentViewModel &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          selection == other.selection &&
          selectionColor == other.selectionColor;

  @override
  int get hashCode =>
      Object.hashAll([nodeId, padding, maxWidth, selection, selectionColor]);
  // super.hashCode ^
  // nodeId.hashCode ^
  // selection.hashCode ^
  // selectionColor.hashCode;
}

class VideoComponent extends StatefulWidget {
  const VideoComponent({
    super.key,
    required this.componentKey,
    this.selection,
    this.selectionColor = Colors.transparent,
  });

  final GlobalKey componentKey;
  final UpstreamDownstreamNodeSelection? selection;
  final Color selectionColor;

  @override
  State<VideoComponent> createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.setPlaylistMode(PlaylistMode.loop);
    _player.open(
      Media(
        // 'https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwutupr4-GM3-Components-Carousel-Guidelines-7-v01.mp4?alt=media&token=60140626-ce6d-48e5-8031-b93f5d56fadf',
        "https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4",
      ),
      play: false,
    );
    _player.setSubtitleTrack(SubtitleTrack.auto());
  }

  @override
  void didUpdateWidget(covariant VideoComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected =
        widget.selection != null && !widget.selection!.isCollapsed;
    return Stack(
      children: [
        MouseRegion(
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: Center(
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radii.extraLarge),
                color:
                    isSelected
                        ? widget.selectionColor.withValues(alpha: 0.5)
                        : null,
              ),
              child: BoxComponent(
                key: widget.componentKey,
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  shape: Shapes.extraLarge,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: MediaQuery.sizeOf(context).width * 9.0 / 16.0,
                    child: Video(
                      controller: _controller,
                      controls: (state) => _VideoControls(state: state),
                      subtitleViewConfiguration: SubtitleViewConfiguration(),
                      // controls: MaterialVideoControls,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Positioned.fill(
        //   child: Material(
        //     type: MaterialType.transparency,
        //     child: InkWell(onTap: () {}, customBorder: Shapes.extraLarge),
        //   ),
        // ),
      ],
    );
  }
}

class _VideoControls extends StatefulWidget {
  const _VideoControls({super.key, required this.state});

  final VideoState state;

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  final List<StreamSubscription> _subscriptions = [];

  VideoState get _state => widget.state;
  VideoController get _controller => _state.widget.controller;
  Player get _player => _controller.player;

  Timer? _timer;
  bool _visible = false;
  bool _action = false;

  late bool _buffering;

  late bool _playing;
  late Duration _duration;
  late Duration _position;
  late bool _fullscreen;

  double _seekProgress = 0;
  bool _seeking = false;

  @override
  void initState() {
    super.initState();
    _buffering = _player.state.buffering;
    _playing = _player.state.playing;
    _duration = _player.state.duration;
    _position = _player.state.position;
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
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fullscreen = isFullscreen(context);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes - duration.inHours * 60;
    final seconds = duration.inSeconds - duration.inMinutes * 60;
    final parts = [
      if (hours > 0) hours,
      minutes > 0 ? minutes : "0",
      seconds.toString().padLeft(2, "0"),
    ];
    return parts.join(":");
  }

  void _show() {
    if (_seeking) return;
    setState(() => _visible = true);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  void _onEnter(PointerEnterEvent event) {
    _show();
  }

  void _onExit(PointerExitEvent event) {
    if (_visible) _show();
  }

  void _onTap() {
    if (_seeking) return;
    if (!_visible) {
      setState(() => _visible = true);
      // shiftSubtitle();
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _visible = false);
          // unshiftSubtitle();
        }
      });
    } else {
      if (_action) {
        setState(() => _action = false);
      } else {
        _timer?.cancel();
        setState(() => _visible = false);
      }
      // unshiftSubtitle();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress =
        _duration == Duration.zero
            ? 0.0
            : _position.inMicroseconds / _duration.inMicroseconds;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          duration: Durations.short4,
          opacity: _visible ? 1 : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.32),
                  Colors.black.withValues(alpha: 0.74),
                ],
                stops: const [0, 2 / 3],
              ),
            ),
          ),
        ),
        if (_buffering) const Center(child: CircularProgressIndicator()),
        MouseRegion(
          onEnter: _onEnter,
          onExit: _onExit,
          onHover: (event) => _show(),
          hitTestBehavior: HitTestBehavior.opaque,
          // child: Listener(
          //   onPointerDown: (event) => _onTap(),
          child: GestureDetector(
            onTap: () => _onTap(),
            behavior: HitTestBehavior.opaque,
            child: _ControlsAnimator(
              duration: Durations.medium4,
              curve:
                  _visible
                      ? Easing.emphasizedDecelerate
                      : Easing.emphasizedAccelerate,
              opacity: _visible ? 1 : 0,
              offset: _visible ? Offset.zero : const Offset(0, 0.25),
              builder: (context, value, child) => child!,
              child: IgnorePointer(
                ignoring: !_visible,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: GestureDetector()),
                          Expanded(child: GestureDetector()),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              overlayColor: Colors.transparent,
                              thumbSize: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.pressed))
                                  return Size(2, 26);
                                if (states.contains(WidgetState.focused))
                                  return Size(2, 26);
                                return Size(4, 26);
                              }),
                            ),
                            child: Slider(
                              value: _seeking ? _seekProgress : progress,
                              onChanged: (value) {
                                setState(() => _seekProgress = value);
                              },
                              onChangeStart: (value) {
                                _timer?.cancel();
                                setState(() {
                                  _visible = true;
                                  _seeking = true;
                                });
                              },
                              onChangeEnd: (value) async {
                                _show();
                                await _player.seek(_duration * value);
                                if (mounted) setState(() => _seeking = false);
                              },
                              label: "AAA",

                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Row(
                            children: [
                              PlayPauseButton(
                                onPressed: () {
                                  _show();
                                  setState(() => _action = true);
                                  _player.playOrPause();
                                },
                                playing: _playing,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints.tightFor(
                                  height: 56,
                                ),
                                child: VideoCard(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 24,
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () => _player.seek(
                                                (_position -
                                                        const Duration(
                                                          seconds: 10,
                                                        ))
                                                    .clamp(
                                                      Duration.zero,
                                                      _duration,
                                                    ),
                                              ),
                                          icon: const Icon(Symbols.replay_10),
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => _player.seek(
                                                (_position +
                                                        const Duration(
                                                          seconds: 10,
                                                        ))
                                                    .clamp(
                                                      Duration.zero,
                                                      _duration,
                                                    ),
                                              ),
                                          icon: const Icon(Symbols.forward_10),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                                          style: theme.textTheme.labelLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints.tightFor(
                                  height: 56,
                                ),
                                child: VideoCard(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Symbols.volume_off),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Symbols.closed_caption),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Symbols.one_x_mobiledata),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Symbols.settings),
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => _state.toggleFullscreen(),
                                          icon: Icon(
                                            _fullscreen
                                                ? Symbols.fullscreen_exit
                                                : Symbols.fullscreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ControlsAnimator extends ImplicitlyAnimatedWidget {
  const _ControlsAnimator({
    super.key,
    required super.duration,
    super.curve,
    this.offset = Offset.zero,
    this.opacity = 0,
    this.child,
    required this.builder,
  });

  final Offset offset;
  final double opacity;

  final Widget? child;
  final ValueWidgetBuilder<double> builder;

  @override
  ImplicitlyAnimatedWidgetState<_ControlsAnimator> createState() =>
      _ControlsAnimatorState();
}

class _ControlsAnimatorState
    extends AnimatedWidgetBaseState<_ControlsAnimator> {
  Tween<Offset>? _offsetTween;
  Tween<double>? _opacityTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offsetTween =
        visitor(
              _offsetTween,
              widget.offset,
              (value) => Tween<Offset>(begin: value as Offset?),
            )
            as Tween<Offset>?;
    _opacityTween =
        visitor(
              _opacityTween,
              widget.opacity,
              (value) => Tween<double>(begin: value as double?),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final offset = _offsetTween?.evaluate(animation) ?? widget.offset;
    final opacity = _opacityTween?.evaluate(animation) ?? widget.opacity;
    final child = widget.builder(context, animation.value, widget.child);
    return FractionalTranslation(
      translation: offset,
      child: Opacity(opacity: opacity, child: child),
    );
  }
}

// class ImageComponentBuilder implements ComponentBuilder {
//   const ImageComponentBuilder();

//   @override
//   SingleColumnLayoutComponentViewModel? createViewModel(Document document, DocumentNode node) {
//     if (node is! ImageNode) {
//       return null;
//     }

//     return ImageComponentViewModel(
//       nodeId: node.id,
//       imageUrl: node.imageUrl,
//       expectedSize: node.expectedBitmapSize,
//       selectionColor: const Color(0x00000000),
//     );
//   }

//   @override
//   Widget? createComponent(
//       SingleColumnDocumentComponentContext componentContext, SingleColumnLayoutComponentViewModel componentViewModel) {
//     if (componentViewModel is! ImageComponentViewModel) {
//       return null;
//     }

//     return ImageComponent(
//       componentKey: componentContext.componentKey,
//       imageUrl: componentViewModel.imageUrl,
//       expectedSize: componentViewModel.expectedSize,
//       selection: componentViewModel.selection?.nodeSelection as UpstreamDownstreamNodeSelection?,
//       selectionColor: componentViewModel.selectionColor,
//     );
//   }
// }

// class ImageComponentViewModel extends SingleColumnLayoutComponentViewModel with SelectionAwareViewModelMixin {
//   ImageComponentViewModel({
//     required super.nodeId,
//     super.maxWidth,
//     super.padding = EdgeInsets.zero,
//     required this.imageUrl,
//     this.expectedSize,
//     DocumentNodeSelection? selection,
//     Color selectionColor = Colors.transparent,
//   }) {
//     this.selection = selection;
//     this.selectionColor = selectionColor;
//   }

//   String imageUrl;
//   ExpectedSize? expectedSize;

//   @override
//   ImageComponentViewModel copy() {
//     return ImageComponentViewModel(
//       nodeId: nodeId,
//       maxWidth: maxWidth,
//       padding: padding,
//       imageUrl: imageUrl,
//       expectedSize: expectedSize,
//       selection: selection,
//       selectionColor: selectionColor,
//     );
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       super == other &&
//           other is ImageComponentViewModel &&
//           runtimeType == other.runtimeType &&
//           nodeId == other.nodeId &&
//           imageUrl == other.imageUrl &&
//           selection == other.selection &&
//           selectionColor == other.selectionColor;

//   @override
//   int get hashCode =>
//       super.hashCode ^ nodeId.hashCode ^ imageUrl.hashCode ^ selection.hashCode ^ selectionColor.hashCode;
// }

// /// Displays an image in a document.
// class ImageComponent extends StatelessWidget {
//   const ImageComponent({
//     Key? key,
//     required this.componentKey,
//     required this.imageUrl,
//     this.expectedSize,
//     this.selectionColor = Colors.blue,
//     this.selection,
//     this.imageBuilder,
//   }) : super(key: key);

//   final GlobalKey componentKey;
//   final String imageUrl;
//   final ExpectedSize? expectedSize;
//   final Color selectionColor;
//   final UpstreamDownstreamNodeSelection? selection;

//   /// Called to obtain the inner image for the given [imageUrl].
//   ///
//   /// This builder is used in tests to 'mock' an [Image], avoiding accessing the network.
//   ///
//   /// If [imageBuilder] is `null` an [Image] is used.
//   final Widget Function(BuildContext context, String imageUrl)? imageBuilder;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.basic,
//       hitTestBehavior: HitTestBehavior.translucent,
//       child: IgnorePointer(
//         child: Center(
//           child: SelectableBox(
//             selection: selection,
//             selectionColor: selectionColor,
//             child: BoxComponent(
//               key: componentKey,
//               child: imageBuilder != null
//                   ? imageBuilder!(context, imageUrl)
//                   : Image.network(
//                       imageUrl,
//                       fit: BoxFit.contain,
//                       frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
//                         if (frame != null) {
//                           // The image is already loaded. Use the image as is.
//                           return child;
//                         }

//                         if (expectedSize != null && expectedSize!.width != null && expectedSize!.height != null) {
//                           // Both width and height were provide.
//                           // Preserve the aspect ratio of the original image.
//                           return AspectRatio(
//                             aspectRatio: expectedSize!.aspectRatio,
//                             child: SizedBox(
//                               width: expectedSize!.width!.toDouble(),
//                               height: expectedSize!.height!.toDouble(),
//                             ),
//                           );
//                         }

//                         // The image is still loading and only one dimension was provided.
//                         // Use the given dimension.
//                         return SizedBox(
//                           width: expectedSize?.width?.toDouble(),
//                           height: expectedSize?.height?.toDouble(),
//                         );
//                       },
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
