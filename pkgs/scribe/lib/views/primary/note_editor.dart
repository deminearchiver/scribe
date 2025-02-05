import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';
import 'package:scribe/brick/models/note.model.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_quill/super_editor_quill.dart';

class NoteController {
  NoteController({required NoteModel note}) : _note = note {}

  NoteModel _note;
  NoteModel get note => _note;

  void update({String? title}) {}
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.windowWidthSizeClass});

  final WindowWidthSizeClass windowWidthSizeClass;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _documentLayoutKey = GlobalKey();

  late FocusNode _focusNode;
  late Editor _editor;
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late CommonEditorOperations _operations;

  late Stylesheet _stylesheet;

  SuperEditorAndroidControlsController? _androidControlsController;
  SuperEditorIosControlsController? _iosControlsController;

  @override
  void initState() {
    super.initState();
    _document = MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 1"),
          metadata: const {NodeMetadata.blockType: header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 2"),
          metadata: const {NodeMetadata.blockType: header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 3"),
          metadata: const {NodeMetadata.blockType: header3Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 4"),
          metadata: const {NodeMetadata.blockType: header4Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 5"),
          metadata: const {NodeMetadata.blockType: header5Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 6"),
          metadata: const {NodeMetadata.blockType: header6Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Elit nostrud qui veniam in laborum cupidatat sunt velit. Nostrud veniam qui exercitation dolor labore tempor laboris sint ea mollit nisi id. Et nisi irure ex Lorem amet minim. Ullamco do elit ullamco voluptate esse cillum elit exercitation commodo ut id. Minim pariatur occaecat excepteur ea aute velit irure esse culpa commodo cupidatat eu eu sint. Eiusmod id incididunt sit nulla. Excepteur eiusmod ea mollit id incididunt voluptate esse consectetur nostrud ipsum.",
          ),
        ),
      ],
    );

    _focusNode = FocusNode();

    _composer = MutableDocumentComposer();
    _editor = Editor(
      editables: {Editor.documentKey: _document, Editor.composerKey: _composer},
      requestHandlers: [...defaultRequestHandlers],
      reactionPipeline: [...defaultEditorReactions],
      historyGroupingPolicy: defaultMergePolicy,
      listeners: [FunctionalEditListener((_) => setState(() {}))],
      isHistoryEnabled: true,
    );

    _operations = CommonEditorOperations(
      composer: _composer,
      editor: _editor,
      document: _document,
      documentLayoutResolver:
          () => _documentLayoutKey.currentState! as DocumentLayout,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final controlsColor = theme.colorScheme.primary;
        if (controlsColor != _androidControlsController?.controlsColor) {
          _androidControlsController?.dispose();
          _androidControlsController = SuperEditorAndroidControlsController(
            controlsColor: controlsColor,
          );
        }

      case TargetPlatform.iOS:
        final handleColor =
            theme.colorScheme.primary; // TODO: investigate handle color
        if (handleColor != _iosControlsController?.handleColor) {
          _iosControlsController?.dispose();
          _iosControlsController = SuperEditorIosControlsController(
            handleColor: handleColor,
          );
        }
      default:
    }

    _stylesheet = defaultStylesheet.copyWith(
      documentPadding: const EdgeInsets.symmetric(horizontal: 16),
      selectedTextColorStrategy:
          ({required originalTextColor, required selectionHighlightColor}) =>
              originalTextColor,
      rules: [
        StyleRule(BlockSelector.all, (doc, docNode) {
          return {
            Styles.textStyle: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          };
        }),
        StyleRule(
          const BlockSelector("header1"),
          (document, node) => {
            Styles.textStyle: theme.textTheme.headlineMedium,
          },
        ),
        StyleRule(
          const BlockSelector("header2"),
          (document, node) => {Styles.textStyle: theme.textTheme.headlineSmall},
        ),
        StyleRule(
          const BlockSelector("header3"),
          (document, node) => {Styles.textStyle: theme.textTheme.titleLarge},
        ),
        StyleRule(
          const BlockSelector("header4"),
          (document, node) => {Styles.textStyle: theme.textTheme.titleMedium},
        ),
        StyleRule(
          const BlockSelector("header5"),
          (document, node) => {Styles.textStyle: theme.textTheme.titleSmall},
        ),
        StyleRule(
          const BlockSelector("header6"),
          (document, node) => {Styles.textStyle: theme.textTheme.labelMedium},
        ),
        StyleRule(
          BlockSelector.all,
          (document, node) => {
            Styles.textStyle: TextStyle(color: theme.colorScheme.onSurface),
          },
        ),
        StyleRule(
          const BlockSelector("image"),
          (_, _) => {Styles.borderRadius: const BorderRadius.all(Radii.medium)},
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _iosControlsController?.dispose();
    _androidControlsController?.dispose();

    _editor.dispose();
    _composer.dispose();
    _document.dispose();
    super.dispose();
  }

  void _undo() {
    _editor.undo();
  }

  void _redo() {
    _editor.redo();
  }

  Widget _buildControlsScope({
    required BuildContext context,
    required Widget child,
  }) {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => SuperEditorAndroidControlsScope(
        controller: _androidControlsController!,
        child: child,
      ),
      TargetPlatform.iOS => SuperEditorIosControlsScope(
        controller: _iosControlsController!,
        child: child,
      ),
      _ => child,
    };
  }

  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);
    return SuperEditor(
      tapRegionGroupId: "super_editor",
      focusNode: _focusNode,
      documentLayoutKey: _documentLayoutKey,
      editor: _editor,
      stylesheet: _stylesheet,
      componentBuilders: [...defaultComponentBuilders],
      selectionStyle: SelectionStyles(
        selectionColor: theme.colorScheme.primary.withValues(alpha: 0.4),
      ),
      keyboardActions: [...defaultKeyboardActions],
      documentOverlayBuilders: [
        DefaultCaretOverlayBuilder(
          caretStyle: const CaretStyle().copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (defaultTargetPlatform == TargetPlatform.android) ...const [
          SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
          SuperEditorAndroidHandlesDocumentLayerBuilder(),
        ],
        if (defaultTargetPlatform == TargetPlatform.iOS) ...const [
          SuperEditorIosHandlesDocumentLayerBuilder(),
          SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
        ],
      ],
    );
  }

  Widget _buildHistoryActions(BuildContext context) {
    // final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    // if (windowWidthSizeClass <= WindowWidthSizeClass.expanded) {
    return Flex.horizontal(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _editor.history.isNotEmpty ? _undo : null,
          icon: const Icon(Symbols.undo),
          tooltip: "Undo",
        ),
        IconButton(
          onPressed: _editor.future.isNotEmpty ? _redo : null,
          icon: const Icon(Symbols.redo),
          tooltip: "Redo",
        ),
      ],
    );
    // }
    // if (windowWidthSizeClass <= WindowWidthSizeClass.medium) {
    // return ButtonGroup.connected(
    //   children: [
    //     TextButton(
    //       onPressed: _editor.history.isNotEmpty ? _undo : null,

    //       icon: const Icon(Symbols.undo),
    //       label: Text("Undo"),
    //     ),
    //     TextButton(
    //       onPressed: _editor.future.isNotEmpty ? _redo : null,

    //       icon: const Icon(Symbols.redo),
    //       label: Text("Redo"),
    //     ),
    //   ],
    // );
    // }
  }

  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    final theme = Theme.of(context);
    return CustomScrollView(
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      slivers: [
        SliverTopAppBar.large(
          automaticallyImplyLeading: false,
          leading: Center(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Symbols.close),
            ),
          ),
          title: InheritedTextField(hintText: "Title"),
          actions: [
            // Stack(
            //   children: [
            //     IconButton.filled(
            //       onPressed: () {},
            //       icon: const Icon(Symbols.sync),
            //     ),
            //     // IconButton(
            //     //   onPressed: () {},
            //     //   icon: CircularProgressIndicator.icon(),
            //     // ),
            //     // const Positioned.fill(
            //     //   child: IgnorePointer(child: CircularProgressIndicator()),
            //     // ),
            //   ],
            // ),
            if (windowWidthSizeClass >= WindowWidthSizeClass.medium)
              AnimatedOpacity(
                duration: Durations.short3,
                curve: Easing.linear,
                opacity: _syncing ? 1.0 : 0.0,
                child: Text(
                  "Sync in progress",
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const Gap(4.0),
            SyncIconButton(
              onPressed: () => setState(() => _syncing = !_syncing),
              syncing: _syncing,
            ),
            _buildHistoryActions(context),
            Stack(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Symbols.share)),
                const Positioned.fill(
                  child: IgnorePointer(child: CircularProgressIndicator()),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        _buildControlsScope(context: context, child: _buildEditor(context)),
      ],
    );
  }
}

class SyncIconButton extends StatefulWidget {
  const SyncIconButton({super.key, this.onPressed, this.syncing = false});

  final VoidCallback? onPressed;
  final bool syncing;

  @override
  State<SyncIconButton> createState() => _SyncIconButtonState();
}

class _SyncIconButtonState extends State<SyncIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Durations.extralong4,
    );
    if (widget.syncing) _controller.repeat();
    _rotation = Tween<double>(
      begin: 0.0,
      end: -2.0 * math.pi,
    ).chain(CurveTween(curve: Easing.standard)).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant SyncIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.syncing != oldWidget.syncing) {
      if (widget.syncing) {
        _controller.repeat();
      } else {
        _controller.forward(from: _controller.value);
      }

      // if (!widget.syncing) {
      //   _controller.forward(from: _controller.value);
      // }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildIcon(BuildContext context) {
    const icon = Icon(Symbols.sync);
    return AnimatedBuilder(
      animation: _rotation,
      child: icon,
      builder:
          (context, child) =>
              Transform.rotate(angle: _rotation.value, child: child!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.onPressed,
      // variant:
      //     widget.syncing
      //         ? IconButtonVariant.filledTonal
      //         : IconButtonVariant.standard,
      selected: widget.syncing,
      icon: _buildIcon(context),
    );
  }
}

class _SyncIconButtonIcon extends StatefulWidget {
  const _SyncIconButtonIcon({super.key, required this.syncing});

  final bool syncing;

  @override
  State<_SyncIconButtonIcon> createState() => _SyncIconButtonIconState();
}

class _SyncIconButtonIconState extends State<_SyncIconButtonIcon> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class InheritedTextField extends StatefulWidget {
  const InheritedTextField({super.key, this.controller, this.hintText});

  final TextEditingController? controller;
  final String? hintText;

  @override
  State<InheritedTextField> createState() => _InheritedTextFieldState();
}

class _InheritedTextFieldState extends State<InheritedTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = DefaultTextStyle.of(context);
    return TextField(
      controller: widget.controller,
      style: defaultTextStyle.style.copyWith(
        color: theme.colorScheme.onSurface,
      ),

      decoration: InputDecoration.collapsed(
        hintText: widget.hintText,
        hintStyle: defaultTextStyle.style.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
