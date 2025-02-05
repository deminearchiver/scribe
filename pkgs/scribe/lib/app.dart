import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:painting/painting.dart';
import 'package:scribe/debug.dart';
import 'package:scribe/home.dart';
import 'package:scribe/i18n/strings.g.dart';
import 'package:scribe/list_detail.dart';
import 'package:scribe/onboarding_auth.dart';
import 'package:scribe/views/primary/list_detail_view.dart';
import 'package:scribe/onboarding.dart';
// import 'package:scribe/editor/audio.dart';
// import 'package:scribe/editor/iframe.dart';
// import 'package:scribe/editor/video.dart';
import 'package:scribe/services.dart';
import 'package:scribe/super_editor_video.dart';
import 'package:scribe/theme.dart';
import 'package:material/material.dart';
import 'package:scribe/views/auth.dart';
import 'package:scribe/widgets/add_close.dart';
import 'package:scribe/widgets/fab.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';
import 'package:widgets/widgets.dart';
// import 'editor/image.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // const AppServices().getShapesPathData(null).then((data) {
    //   if (data != null) {
    //     for (final entry in data.entries) {
    //       debugPrint("\"${entry.key}\": ${entry.value}");
    //     }
    //   }
    // });
    return const _TranslationPart(child: _AppPart());
  }
}

class _TranslationPart extends StatelessWidget {
  const _TranslationPart({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(child: child);
  }
}

class _AppPart extends StatelessWidget {
  const _AppPart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      themeMode: ThemeMode.system,
      theme: AppTheme.custom(brightness: Brightness.light),
      darkTheme: AppTheme.custom(
        brightness: Brightness.dark,
        seedColor: Color(0xFFFFDE3F),
      ),
      builder: (context, child) {
        return IconTheme.merge(
          data: const IconThemeData(
            size: 24.0,
            weight: 400.0,
            opticalSize: 24.0,
            fill: 0.0,
            grade: 0.0,
          ),
          child: child!,
        );
      },
      // home: const HomeView(),
      // home: const OnboardingFlow(),
      // home: const NavigationView(),
      // home: const ListDetail(),
      home: const ListDetailView(),
      // home: const AccountView(),
      // home: const OnboardingAuth(),
    );
  }
}

class ShapeView extends StatefulWidget {
  const ShapeView({super.key});

  @override
  State<ShapeView> createState() => _ShapeViewState();
}

class _ShapeViewState extends State<ShapeView>
    with SingleTickerProviderStateMixin {
  late NoiseGradientController _controller;
  @override
  void initState() {
    super.initState();
    _controller = NoiseGradientController(vsync: this)
      ..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    return Scaffold(
      body: Center(
        // child: FloatingActionButton.large(
        //   onPressed: () {},
        //   style: ButtonStyle(
        //     // backgroundColor: WidgetStatePropertyAll(theme.colorScheme.primary),
        //     // foregroundColor: WidgetStatePropertyAll(
        //     //   theme.colorScheme.onPrimary,
        //     // ),
        //     // iconColor: WidgetStatePropertyAll(theme.colorScheme.onPrimary),
        //     // overlayColor: WidgetStateLayerColor(
        //     //   theme.colorScheme.onPrimary,
        //     //   opacity: stateTheme.stateLayerOpacity,
        //     // ),
        //     shape: WidgetStatePropertyAll(
        //       PathBorder(path: ShapePaths.cookie9(false)),
        //     ),
        //   ),
        //   child: const Icon(Symbols.mic),
        // ),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Ink(
            decoration: ShapeDecoration(
              shape: PathBorder(path: ShapePaths.cookie12(false)),
              // gradient: LinearGradient(
              //   colors: [
              //     theme.colorScheme.primary,
              //     theme.colorScheme.secondary,
              //     theme.colorScheme.tertiary,
              //   ],
              // ),
              gradient: CustomGradient(
                delegate: NoiseGradientDelegate(
                  time: _controller.value,
                  speed: 5,
                  // amplitude: 1,
                  colors: [
                    // Colors.red,
                    // Colors.blue,
                    // Colors.green,
                    // Colors.white,
                    theme.colorScheme.primary,
                    theme.colorScheme.onPrimaryContainer,
                    theme.colorScheme.onPrimaryContainer,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
            ),
            child: InkWell(
              onTap: () {},
              customBorder: PathBorder(path: ShapePaths.cookie12(false)),
              overlayColor: WidgetStateLayerColor(
                theme.colorScheme.onPrimary,
                opacity: stateTheme.stateLayerOpacity,
              ),
              child: Center(
                child: Icon(
                  Symbols.mic,
                  size: 36.0,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey _viewportKey = GlobalKey();

  late final Editor _editor;
  late final MutableDocument _document;
  late final MutableDocumentComposer _composer;

  // late SuperEditorAndroidControlsController _androidControlsController;
  // late SuperEditorIosControlsController _iosControlsController;

  SuperEditorAndroidControlsController? _androidControlsController;
  SuperEditorIosControlsController? _iosControlsController;

  final _selectionLayerLinks = SelectionLayerLinks();

  final _overlayPortalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _document = MutableDocument(
      nodes: [
        // IFrameNode(
        //   id: Editor.createNodeId(),
        //   uri: Uri.https("www.youtube.com", "/embed/9HEempTk3N8"),
        // ),
        // IFrameNode(
        //   id: Editor.createNodeId(),
        //   uri: Uri.https("pauljadam.com", "/demos/html5-input-types.html"),
        // ),
        // AudioNode(id: Editor.createNodeId()),
        VideoNode(id: Editor.createNodeId()),
        // ImageNode(
        //   id: "1",
        //   imageUrl: 'https://i.ibb.co/5nvRdx1/flutter-horizon.png',
        //   expectedBitmapSize: const ExpectedSize(1911, 630),
        //   metadata:
        //       const SingleColumnLayoutComponentStyles(
        //         width: double.infinity,
        //         padding: EdgeInsets.zero,
        //       ).toMetadata(),
        // ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 1"),
          metadata: {"blockType": header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 2"),
          metadata: {"blockType": header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 3"),
          metadata: {"blockType": header3Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 4"),
          metadata: {"blockType": header4Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 5"),
          metadata: {"blockType": header5Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText("Header 6"),
          metadata: {"blockType": header6Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Reprehenderit incididunt non ullamco officia nisi quis ad mollit irure eu. Incididunt aute nulla deserunt dolor incididunt Lorem in deserunt qui incididunt ea nostrud aliquip. Nulla cillum tempor excepteur ad. Ex elit ipsum laborum tempor commodo aliqua. Fugiat aliqua adipisicing qui minim occaecat consequat cillum enim culpa officia excepteur dolor eiusmod. Ea qui esse ea amet cillum est irure.",
          ),
        ),

        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Super Editor is a toolkit to help you build document editors, document layouts, text fields, and more.",
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Ready-made solutions 📦'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            'SuperEditor is a ready-made, configurable document editing experience.',
          ),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            'SuperTextField is a ready-made, configurable text field.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Quickstart 🚀'),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'To get started with your own editing experience, take the following steps:',
          ),
        ),
        TaskNode(
          id: Editor.createNodeId(),
          isComplete: false,
          text: AttributedText(
            'Create and configure your document, for example, by creating a new MutableDocument.',
          ),
        ),
        TaskNode(
          id: Editor.createNodeId(),
          isComplete: false,
          text: AttributedText(
            "If you want programmatic control over the user's selection and styles, create a DocumentComposer.",
          ),
        ),
        TaskNode(
          id: Editor.createNodeId(),
          isComplete: false,
          text: AttributedText(
            "Build a SuperEditor widget in your widget tree, configured with your Document and (optionally) your DocumentComposer.",
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Now, you're off to the races! SuperEditor renders your document, and lets you select, insert, and delete content.",
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Explore the toolkit 🔎'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Use MutableDocument as an in-memory representation of a document.",
          ),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Implement your own document data store by implementing the Document api.",
          ),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Implement your down DocumentLayout to position and size document components however you'd like.",
          ),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            "Use SuperSelectableText to paint text with selection boxes and a caret.",
          ),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Use AttributedText to quickly and easily apply metadata spans to a string.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            "We hope you enjoy using Super Editor. Let us know what you're building, and please file issues for any bugs that you find.",
          ),
        ),
      ],
    );

    _composer = MutableDocumentComposer();

    _editor = Editor(
      editables: {Editor.documentKey: _document, Editor.composerKey: _composer},
      requestHandlers: [...defaultRequestHandlers],
      reactionPipeline: [...defaultEditorReactions],
      historyGroupingPolicy: defaultMergePolicy,
      isHistoryEnabled: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final controlsColor = theme.colorScheme.primary;
    if (controlsColor != _androidControlsController?.controlsColor) {
      _androidControlsController?.dispose();
      _androidControlsController = SuperEditorAndroidControlsController(
        controlsColor: controlsColor,
      );
    }
    final handleColor = controlsColor;
    if (handleColor != _iosControlsController?.handleColor) {
      _iosControlsController?.dispose();
      _iosControlsController = SuperEditorIosControlsController(
        handleColor: handleColor,
      );
    }
  }

  @override
  void dispose() {
    // _androidControlsController.dispose();
    _editor.dispose();
    _composer.dispose();
    _document.dispose();

    super.dispose();
  }

  Widget _buildEditor(BuildContext context) {
    final theme = Theme.of(context);
    return KeyedSubtree(
      child: SuperEditorAndroidControlsScope(
        controller: _androidControlsController!,
        child: SuperEditorIosControlsScope(
          controller: _iosControlsController!,
          child: SuperEditor(
            editor: _editor,
            componentBuilders: [
              // const CustomImageComponentBuilder(),
              // const VideoComponentBuilder(),
              // const AudioComponentBuilder(),
              const BlockquoteComponentBuilder(),
              const ParagraphComponentBuilder(),
              const ListItemComponentBuilder(),
              const HorizontalRuleComponentBuilder(),
              // IFrameComponentBuilder(),
              TaskComponentBuilder(_editor),
              const ImageComponentBuilder(),
              const VideoComponentBuilder(),
            ],
            stylesheet: defaultStylesheet.copyWith(
              documentPadding: EdgeInsets.symmetric(horizontal: 16),
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
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.headlineSmall,
                  },
                ),
                StyleRule(
                  const BlockSelector("header3"),
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.titleLarge,
                  },
                ),
                StyleRule(
                  const BlockSelector("header4"),
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.titleMedium,
                  },
                ),
                StyleRule(
                  const BlockSelector("header5"),
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.titleSmall,
                  },
                ),
                StyleRule(
                  const BlockSelector("header6"),
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.labelMedium,
                  },
                ),
                StyleRule(
                  const BlockSelector("paragraph"),
                  (document, node) => {
                    Styles.textStyle: theme.textTheme.bodyLarge,
                  },
                ),
                StyleRule(
                  BlockSelector.all,
                  (document, node) => {
                    Styles.textStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  },
                ),
                StyleRule(
                  const BlockSelector("image"),
                  (_, _) => {
                    Styles.borderRadius: const BorderRadius.all(
                      Radii.extraLarge,
                    ),
                  },
                ),
              ],
              selectedTextColorStrategy:
                  ({
                    required originalTextColor,
                    required selectionHighlightColor,
                  }) => originalTextColor,
            ),

            documentOverlayBuilders: [
              if (defaultTargetPlatform == TargetPlatform.android) ...const [
                SuperEditorAndroidToolbarFocalPointDocumentLayerBuilder(),
                SuperEditorAndroidHandlesDocumentLayerBuilder(),
              ],
              if (defaultTargetPlatform == TargetPlatform.iOS) ...const [
                SuperEditorIosHandlesDocumentLayerBuilder(),
                SuperEditorIosToolbarFocalPointDocumentLayerBuilder(),
              ],
              DefaultCaretOverlayBuilder(
                caretStyle: const CaretStyle().copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            selectionLayerLinks: _selectionLayerLinks,
            selectionStyle: SelectionStyles(
              selectionColor: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            plugins: {MarkdownInlineUpstreamSyntaxPlugin()},
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Toolbar(
      anchor: _selectionLayerLinks.expandedSelectionBoundsLink,
      editorViewportKey: _viewportKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayPortalController,
      overlayChildBuilder: _buildToolbar,
      child: Scaffold(
        key: _viewportKey,
        body: CustomScrollView(
          slivers: [
            SliverTopAppBar.large(
              pinned: true,
              title: Builder(
                builder:
                    (context) => TextField(
                      style: DefaultTextStyle.of(context).style,
                      decoration: InputDecoration.collapsed(
                        border: InputBorder.none,
                        hintText: "Title",
                      ),
                    ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _overlayPortalController.toggle(),
                  icon: const Icon(Symbols.visibility),
                ),
              ],
            ),
            // _buildEditor(context),
            _buildEditor(context),
            SliverToBoxAdapter(
              child: Center(
                child: FloatingToolbar(
                  variant: FloatingToolbarVariant.standard,
                  direction: Axis.horizontal,
                  actions: [
                    IconButton(
                      onPressed: () {},
                      selected: true,
                      icon: const Icon(Symbols.format_bold),
                    ),
                    IconButton(
                      onPressed: () {},
                      selected: false,
                      icon: const Icon(Symbols.format_italic),
                    ),
                    IconButton(
                      onPressed: () {},
                      selected: false,
                      icon: const Icon(Symbols.format_underlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      selected: false,
                      icon: const Icon(Symbols.format_color_text_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      selected: false,
                      icon: const Icon(Symbols.format_color_fill_rounded),
                    ),
                    IconButton(
                      onPressed: () {},
                      selected: true,
                      icon: const Icon(Symbols.format_h1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: ExpandableFloatingActionButton<String>(
          size: FloatingActionButtonSize.regular,
          collapsedStyle: FloatingActionButton.styleFrom(
            context: context,
            variant: FloatingActionButtonVariant.primary,
          ).copyWith(
            shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
          expandedStyle: FloatingActionButton.styleFrom(
            context: context,
            variant: FloatingActionButtonVariant.secondary,
          ),
          actions: const [
            FloatingActionButtonAction(
              value: "image",
              icon: Icon(Symbols.image),
              label: Text("Image"),
            ),
            FloatingActionButtonAction(
              value: "text",
              icon: Icon(Symbols.text_fields),
              label: Text("Text"),
            ),
            FloatingActionButtonAction(
              value: "list",
              icon: Icon(Symbols.checklist),
              label: Text("List"),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Symbols.image)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class ToolbarAligner implements FollowerAligner {
  const ToolbarAligner([GlobalKey? boundsKey]) : _boundsKey = boundsKey;

  final GlobalKey? _boundsKey;

  static const double _popoverToolbarMinimumDistanceFromEdge = 16;

  @override
  FollowerAlignment align(Rect globalLeaderRect, Size followerSize) {
    final boundsBox =
        _boundsKey?.currentContext?.findRenderObject() as RenderBox?;
    final bounds =
        boundsBox != null
            ? Rect.fromPoints(
              boundsBox.localToGlobal(Offset.zero),
              boundsBox.localToGlobal(boundsBox.size.bottomRight(Offset.zero)),
            )
            : Rect.largest;

    late FollowerAlignment alignment;
    if (globalLeaderRect.top -
            followerSize.height -
            _popoverToolbarMinimumDistanceFromEdge <
        bounds.top) {
      // The follower hit the minimum distance. Invert the follower position.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        followerOffset: Offset(0, 20),
      );
    } else {
      // There's enough room to display toolbar above content. That's our desired
      // default position, so put the toolbar on top.
      alignment = const FollowerAlignment(
        leaderAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        followerOffset: Offset(0, -20),
      );
    }

    return alignment;
  }
}

class Toolbar extends StatefulWidget {
  const Toolbar({
    super.key,
    required this.anchor,
    required this.editorViewportKey,
  });

  final LeaderLink anchor;
  final GlobalKey editorViewportKey;

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  late FollowerAligner _aligner;
  late WidgetFollowerBoundary _boundary;
  @override
  void initState() {
    super.initState();
    _aligner = ToolbarAligner(widget.editorViewportKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _boundary = WidgetFollowerBoundary(
      boundaryKey: widget.editorViewportKey,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
  }

  @override
  void didUpdateWidget(covariant Toolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editorViewportKey != oldWidget.editorViewportKey) {
      _aligner = ToolbarAligner(widget.editorViewportKey);
      _boundary = WidgetFollowerBoundary(
        boundaryKey: widget.editorViewportKey,
        devicePixelRatio: _boundary.devicePixelRatio,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget _buildToolbar(BuildContext context) {
    return FloatingToolbar.horizontal(
      actions: [
        IconButton(
          onPressed: () {},
          selected: true,
          icon: const Icon(Symbols.format_bold),
        ),
        IconButton(
          onPressed: () {},
          selected: false,
          icon: const Icon(Symbols.format_italic),
        ),
        IconButton(
          onPressed: () {},
          selected: false,
          icon: const Icon(Symbols.format_underlined),
        ),
        IconButton(
          onPressed: () {},
          selected: false,
          icon: const Icon(Symbols.format_color_text_rounded),
        ),
        IconButton(
          onPressed: () {},
          selected: false,
          icon: const Icon(Symbols.format_color_fill_rounded),
        ),
        IconButton(
          onPressed: () {},
          selected: true,
          icon: const Icon(Symbols.format_h1),
        ),
      ],
    );
  }

  Widget _buildFollower(BuildContext context) {
    final anchor = widget.anchor;
    return BuildInOrder(
      children: [
        FollowerFadeOutBeyondBoundary(
          link: anchor,
          boundary: _boundary,
          child: Follower.withAligner(
            showDebugPaint: true,
            link: anchor,
            aligner: _aligner,
            boundary: _boundary,
            showWhenUnlinked: false,
            child: _buildToolbar(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildFollower(context);
  }
}
