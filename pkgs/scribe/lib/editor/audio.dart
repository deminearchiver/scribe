import 'dart:async';

import 'package:scribe/widgets/play_pause.dart';
import 'package:scribe/widgets/video_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:super_editor/super_editor.dart';

/// [DocumentNode] that represents an audio at a URL.
class AudioNode extends BlockNode with ChangeNotifier {
  AudioNode({
    required this.id,
    ExpectedSize? expectedBitmapSize,
    String altText = '',
    Map<String, dynamic>? metadata,
  }) : _expectedBitmapSize = expectedBitmapSize,
       _altText = altText {
    this.metadata = metadata;

    putMetadataValue("blockType", const NamedAttribution("audio"));
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
    return other is AudioNode && altText == other.altText;
  }

  @override
  AudioNode copy() {
    return AudioNode(
      id: id,
      expectedBitmapSize: expectedBitmapSize,
      altText: altText,
      metadata: Map.from(metadata),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          _altText == other._altText;

  @override
  int get hashCode => id.hashCode ^ _altText.hashCode;
}

class AudioComponentBuilder implements ComponentBuilder {
  const AudioComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! AudioNode) return null;
    return AudioComponentViewModel(nodeId: node.id);
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! AudioComponentViewModel) {
      return null;
    }
    return AudioComponent(
      componentKey: componentContext.componentKey,
      selection:
          componentViewModel.selection?.nodeSelection
              as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
    );
  }
}

class AudioComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  AudioComponentViewModel({
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
  AudioComponentViewModel copy() => AudioComponentViewModel(
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
          other is AudioComponentViewModel &&
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

class AudioComponent extends StatefulWidget {
  const AudioComponent({
    super.key,
    required this.componentKey,
    this.selection,
    this.selectionColor = Colors.transparent,
  });

  final GlobalKey componentKey;
  final UpstreamDownstreamNodeSelection? selection;
  final Color selectionColor;

  @override
  State<AudioComponent> createState() => _AudioComponentState();
}

class _AudioComponentState extends State<AudioComponent> {
  final List<StreamSubscription> _subscriptions = [];

  late final Player _player;

  late bool _buffering;
  late bool _playing;
  late Duration _duration;
  late Duration _position;
  late double _volume;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _player.open(
      Media(
        // 'https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwutupr4-GM3-Components-Carousel-Guidelines-7-v01.mp4?alt=media&token=60140626-ce6d-48e5-8031-b93f5d56fadf',
        "https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4",
      ),
      play: false,
    );

    _player.setVideoTrack(VideoTrack.no());
    _player.setAudioTrack(AudioTrack.auto());
    _player.setSubtitleTrack(SubtitleTrack.no());

    _buffering = _player.state.buffering;
    _playing = _player.state.playing;
    _duration = _player.state.duration;
    _position = _player.state.position;
    _volume = _player.state.volume;

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
      _player.stream.volume.listen((event) {
        if (mounted) setState(() => _volume = event);
      }),
    ]);
  }

  @override
  void didUpdateWidget(covariant AudioComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected =
        widget.selection != null && !widget.selection!.isCollapsed;
    final double progress =
        _duration == Duration.zero
            ? 0.0
            : _position.inMicroseconds / _duration.inMicroseconds;
    return Stack(
      children: [
        MouseRegion(
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: Center(
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: ShapeDecoration(
                shape: Shapes.medium,
                color:
                    isSelected
                        ? widget.selectionColor.withValues(alpha: 0.5)
                        : null,
              ),
              child: BoxComponent(
                key: widget.componentKey,
                child: Material(
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: Shapes.extraLarge,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    "Title",
                                    style: theme.textTheme.titleLarge!.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                                        style: theme.textTheme.labelMedium!
                                            .copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // IconButton(
                            //   onPressed: () {},
                            //   icon: const Icon(Symbols.replay_5),
                            // ),
                            (_playing ? IconButton.filled : IconButton.filled)(
                              isSelected: !_playing,
                              onPressed: () {
                                _player.playOrPause();
                              },
                              // color: theme.colorScheme.onPrimary,
                              icon:
                                  _buffering
                                      ? const CircularProgressIndicator.icon(
                                        constraints: BoxConstraints.tightFor(
                                          width: 24,
                                          height: 24,
                                        ),
                                      )
                                      : TweenAnimationBuilder(
                                        tween: Tween<double>(
                                          end: _playing ? 1 : 0,
                                        ),
                                        duration: Durations.long4,
                                        curve: Easing.emphasized,
                                        builder:
                                            (context, value, child) =>
                                                PlayPause(progress: value),
                                      ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 20),
                        child: Row(
                          children: [
                            // const SizedBox(width: 8),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  overlayColor: Colors.transparent,
                                  thumbSize: WidgetStateProperty.resolveWith((
                                    states,
                                  ) {
                                    if (states.contains(WidgetState.pressed))
                                      return Size(2, 24);
                                    if (states.contains(WidgetState.focused))
                                      return Size(2, 24);
                                    return Size(4, 24);
                                  }),
                                ),
                                child: Slider(
                                  value: progress,
                                  onChanged: (value) {
                                    _player.seek(_duration * value);
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),

                            const SizedBox(width: 4),
                            // IconButton.outlined(
                            //   onPressed: () {
                            //     if (_volume == 0) {
                            //       _player.setVolume(100);
                            //     } else {
                            //       _player.setVolume(0);
                            //     }
                            //   },
                            //   isSelected: _volume == 0,
                            //   icon: Icon(
                            //     _volume == 0
                            //         ? Symbols.volume_off
                            //         : Symbols.volume_up,
                            //   ),
                            // ),
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: const Icon(Symbols.forward_5),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
