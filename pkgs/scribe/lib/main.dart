import 'dart:async';
import 'dart:io';

import 'package:brick_core/query.dart';
import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:collection/collection.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:painting/painting.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:scribe/accordion.dart';
import 'package:scribe/brick/models/note.model.dart';
import 'package:scribe/brick/models/user.model.dart';
import 'package:scribe/brick/repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:scribe/debug.dart';
import 'package:scribe/i18n/strings.g.dart';
import 'package:scribe/notification_service.dart';
import 'package:scribe/services.dart';
import 'package:scribe/settings.dart';
import 'package:scribe/sliver_search.dart';
import 'package:scribe/theme.dart';
import 'package:scribe/two_pane_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_quill/super_editor_quill.dart';
import 'package:widgets/widgets.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:slang_flutter/slang_flutter.dart';
import 'app.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:path/path.dart' as path;

@pragma("vm:entry-point")
void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Notifications.ensureInitialized();
  await LocaleSettings.useDeviceLocale();

  // FlutterNativeSplash.preserve(widgetsBinding: binding);

  await NoiseGradientDelegate.ensureInitialized();
  // URI scheme protocol

  if (Platform.isWindows) await _register("scribe");

  // Database

  sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;
  final applicationDocumentsDirectory =
      await getApplicationDocumentsDirectory();
  await applicationDocumentsDirectory.create(recursive: true);

  // Offline repository
  const supabaseUrl = "https://yxumyouzbebhebyzylyp.supabase.co";
  const supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dW15b3V6YmViaGVieXp5bHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzMzU2NjUsImV4cCI6MjA1MTkxMTY2NX0.SHHyDOQ8txR3z3t6dwmjyFSrA9SucjX-PNPcSGD6HiM";
  // await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await Repository.configure(
    databaseFactory: switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => databaseFactory,
      _ => databaseFactoryFfi,
    },
    databasePath: path.join(
      applicationDocumentsDirectory.path,
      "supabase.sqlite",
    ),
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await Repository().initialize();
  // Media player

  MediaKit.ensureInitialized();

  const AppServices().hideSplashScreen();

  // FlutterNativeSplash.remove();

  final sharedPreferencesWithCache = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  runApp(
    Settings(
      adapter: SettingsAdapter.sharedPreferencesWithCache(
        sharedPreferencesWithCache,
      ),
      child: App(),
    ),
  );
}

Future<void> _register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = "Software\\Classes\\$scheme";
  RegistryValue protocolRegValue = const RegistryValue(
    "URL Protocol",
    RegistryValueType.string,
    "",
  );
  String protocolCmdRegKey = "shell\\open\\command";
  RegistryValue protocolCmdRegValue = RegistryValue(
    "",
    RegistryValueType.string,
    "\"$appPath\" \"%1\"",
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) => null;

  List<Route<dynamic>> _onGenerateInitialRoutes(String initialRoute) {
    return [MaterialRoute(builder: (context) => const Test1())];
  }

  Widget _buildWrapper(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return ColoredBox(color: theme.colorScheme.surface, child: child);
  }

  Widget _buildMaterialApp(BuildContext context) {
    final useDynamicColor = Settings.useDynamicColorOf(context);
    final themeMode = Settings.themeModeOf(context);
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        ColorScheme? light;
        ColorScheme? dark;

        if (useDynamicColor && lightDynamic != null) {
          light = lightDynamic.harmonized();
        }
        if (useDynamicColor && darkDynamic != null) {
          dark = darkDynamic.harmonized();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "Scribe",
          // Localization
          locale: TranslationProvider.of(context).flutterLocale,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          // Theme
          themeMode: themeMode,
          theme:
              light != null
                  ? AppTheme.withColorScheme(light)
                  : AppTheme.custom(brightness: Brightness.light),
          darkTheme:
              dark != null
                  ? AppTheme.withColorScheme(dark)
                  : AppTheme.custom(brightness: Brightness.dark),
          // Routing
          navigatorKey: _navigatorKey,
          initialRoute: "/",
          onGenerateRoute: _onGenerateRoute,
          onGenerateInitialRoutes: _onGenerateInitialRoutes,
          builder: _buildWrapper,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TranslationProvider(child: Builder(builder: _buildMaterialApp));
  }
}

class Test1 extends StatefulWidget {
  const Test1({super.key});

  @override
  State<Test1> createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  final _listNavigatorKey = GlobalKey<NavigatorState>();
  final _detailNavigatorKey = GlobalKey<NavigatorState>();

  int _selectedIndex = 0;

  late _Controller _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        _Controller()
          .._attach(this)
          ..addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Test1 oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller._detach(this);
    super.dispose();
  }

  void _listener() {
    // if (SchedulerBinding.instance.schedulerPhase ==
    //     SchedulerPhase.persistentCallbacks) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
    // } else {
    //   setState(() {});
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = Theme.of(context);
    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    final windowHeightSizeClass = WindowHeightSizeClass.of(context);
    final backgroundColor = theme.colorScheme.surfaceContainer;

    const duration = Durations.extralong2;
    const curve = Easing.emphasized;

    final useGlobalSafeArea =
        windowWidthSizeClass >= WindowWidthSizeClass.medium;
    final inset =
        windowHeightSizeClass <= WindowHeightSizeClass.compact ? 16.0 : 24.0;
    final margin =
        windowWidthSizeClass <= WindowWidthSizeClass.compact
            ? EdgeInsets.zero
            : windowWidthSizeClass <= WindowWidthSizeClass.medium
            ? EdgeInsets.fromLTRB(inset, inset, inset, 0)
            : EdgeInsets.fromLTRB(0, inset, inset, inset);
    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: useGlobalSafeArea,
        left: useGlobalSafeArea,
        right: useGlobalSafeArea,
        top: useGlobalSafeArea,
        child: Flex.horizontal(
          children: [
            AnimatedAlign(
              duration: duration,
              curve: curve,
              alignment: Alignment.centerRight,

              widthFactor:
                  windowWidthSizeClass >= WindowWidthSizeClass.expanded
                      ? 1.0
                      : 0.0,
              child: NavigationRail(
                backgroundColor: backgroundColor,
                groupAlignment: 0,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected:
                    (value) => setState(() => _selectedIndex = value),
                selectedIndex: _selectedIndex,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Symbols.notes, fill: 0),
                    selectedIcon: Icon(Symbols.notes, fill: 1),
                    label: Text("Notes"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Symbols.notifications, fill: 0),
                    selectedIcon: Icon(Symbols.notifications, fill: 1),
                    label: Text("Reminders"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Symbols.settings, fill: 0),
                    selectedIcon: Icon(Symbols.settings, fill: 1),
                    label: Text("Settings"),
                  ),
                ],
              ),
            ),
            Flexible.expand(
              child: IndexedStack(
                index: _selectedIndex,

                sizing: StackFit.expand,
                children: [
                  NotesLayout(
                    controller: _selectedIndex == 0 ? _controller : null,
                    padding: margin,
                  ),
                  NotesLayout(
                    controller: _selectedIndex == 1 ? _controller : null,
                    padding: margin,
                  ),
                  _SettingsLayout(
                    controller: _selectedIndex == 2 ? _controller : null,
                    padding: margin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedAlign(
        duration: Durations.extralong2,
        curve: Easing.emphasized,
        alignment: Alignment.topCenter,
        heightFactor:
            (_controller.showNavigationBar &&
                        windowWidthSizeClass <= WindowWidthSizeClass.compact) ||
                    windowWidthSizeClass == WindowWidthSizeClass.medium
                ? 1.0
                : 0.0,
        child: IgnorePointer(
          ignoring:
              (!_controller.showNavigationBar &&
                  windowWidthSizeClass <= WindowWidthSizeClass.compact) ||
              windowWidthSizeClass >= WindowWidthSizeClass.expanded,
          child: NavigationBar(
            onDestinationSelected:
                (value) => setState(() => _selectedIndex = value),
            selectedIndex: _selectedIndex,
            destinations: [
              NavigationDestination(
                icon: Icon(Symbols.notes, fill: 0),
                selectedIcon: Icon(Symbols.notes, fill: 1),
                label: "Notes",
              ),
              NavigationDestination(
                icon: Icon(Symbols.notifications, fill: 0),
                selectedIcon: Icon(Symbols.notifications, fill: 1),
                label: "Reminders",
              ),
              NavigationDestination(
                icon: Icon(Symbols.settings, fill: 0),
                selectedIcon: Icon(Symbols.settings, fill: 1),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotesLayout extends StatefulWidget {
  const NotesLayout({
    super.key,
    this.controller,
    this.padding = EdgeInsets.zero,
  });

  final _Controller? controller;
  final EdgeInsetsGeometry padding;

  @override
  State<NotesLayout> createState() => _NotesLayoutState();
}

class _NotesLayoutState extends State<NotesLayout> {
  final _listKey = GlobalKey();
  final _searchBarKey = GlobalKey();
  final _listNavigatorKey = GlobalKey<NavigatorState>();
  final _detailNavigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get _listNavigatorOrNull => _listNavigatorKey.currentState;
  NavigatorState get _listNavigator {
    final navigator = _listNavigatorOrNull;
    assert(navigator != null);
    return navigator!;
  }

  NavigatorState? get _detailNavigatorOrNull =>
      _detailNavigatorKey.currentState;
  NavigatorState get _detailNavigator {
    final navigator = _detailNavigatorOrNull;
    assert(navigator != null);
    return navigator!;
  }

  late WindowWidthSizeClass _windowWidthSizeClass;

  bool get _useTwoPanes =>
      _windowWidthSizeClass >= WindowWidthSizeClass.expanded;

  final SupabaseClient _supabase = Supabase.instance.client;
  final Repository _repository = Repository();

  StreamSubscription<AuthState>? _authSubscription;

  StreamSubscription<List<NoteModel>>? _notesSubscription;
  final _notesController = BehaviorSubject<List<NoteModel>>();

  List<NoteModel> _notes = [];
  List<MutableDocument> _documents = [];

  NoteModel? _current;

  @override
  void initState() {
    super.initState();
    _authSubscription = _supabase.auth.onAuthStateChange.listen(_authListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _windowWidthSizeClass = WindowWidthSizeClass.of(context);
  }

  @override
  void didUpdateWidget(covariant NotesLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(callback);
      });
    } else {
      if (mounted) setState(callback);
    }
  }

  void _authListener(AuthState data) {
    final session = data.session;
    _notesSubscription?.cancel();
    if (session != null) {
      final notes = _repository.subscribe<NoteModel>(
        query: Query.where(
          "user",
          const Where("id").isExactly(session.user.id),
        ),
      );
      _notesSubscription = notes.listen((data) {
        setState(() {
          _notes = data;
          _documents =
              _notes
                  .map((note) => parseQuillDeltaDocument(note.rawQuillDelta))
                  .toList();
        });
        _notesController.add(data);
      });
    } else {
      setState(() {
        _notes = [];
        _documents = [];
      });
      _notesController.add([]);
    }
  }

  Widget _buildList(BuildContext context, bool keyed) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    return SafeArea(
      child: CustomScrollView(
        key: keyed ? _listKey : null,
        slivers: [
          SliverSearchView(
            padding: const EdgeInsets.all(16),
            dockedViewMargin: const EdgeInsets.all(16),
            supportingText: "Search your notes",
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: _notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final note = _notes[index];
                final document = _documents[index];
                final selected = _current?.id == note.id;
                return Material(
                  animationDuration: Duration.zero,
                  color:
                      selected
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radii.medium),
                    side:
                        selected
                            ? BorderSide.none
                            : BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                  ),
                  child: InkWell(
                    onTap: () => setState(() => _current = note),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (note.title != null)
                            Text(
                              note.title!,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPane(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        _windowWidthSizeClass <= WindowWidthSizeClass.compact
            ? Shapes.none
            : Shapes.medium;

    return Pane(
      duration: Durations.extralong2,
      curve: Easing.emphasized,
      shape: shape,
      child: _useTwoPanes ? _buildList(context, true) : const SizedBox.shrink(),
    );
  }

  Widget _buildDetailPane(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        _windowWidthSizeClass <= WindowWidthSizeClass.compact
            ? Shapes.none
            : Shapes.medium;
    final List<Page> pages = [
      MaterialRoutePage(
        key: const ValueKey("first"),
        canPop: false,
        child:
            _useTwoPanes
                ? Flex.vertical(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 112,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: PathBorder(path: ShapePaths.cookie12(false)),
                          color: theme.colorScheme.secondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select something first",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                : _buildList(context, true),
      ),
      if (_current != null)
        MaterialRoutePage(
          backgroundColor: theme.colorScheme.surface,
          key: const ValueKey("editor"),
          child: NoteEditor(
            windowWidthSizeClass: _windowWidthSizeClass,
            note: _current!,
          ),
        ),
    ];
    return Pane(
      duration: Durations.extralong2,
      curve: Easing.emphasized,
      shape: shape,
      child: Navigator(
        key: _detailNavigatorKey,
        pages: pages,
        onDidRemovePage: (page) {
          final key = page.key;
          final args = page.arguments;
          if (key is ValueKey<String> && page.name == "editor") {
            _scheduleSetState(() => _current = null);
          }
          // final args = page.arguments;
          // if (args is _SettingsCategory) {
          // }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      child: TwoPaneLayout(
        shift: _windowWidthSizeClass <= WindowWidthSizeClass.medium ? -1 : 0,
        flex:
            _windowWidthSizeClass <= WindowWidthSizeClass.expanded
                ? const TwoPaneLayoutFlexFactor(0)
                : const TwoPaneLayoutFlexFactor.fixedListWidth(412),
        padding: widget.padding,
        separator: const SizedBox(width: 24),
        list: _buildListPane(context),
        detail: _buildDetailPane(context),
      ),
    );
  }
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({
    super.key,
    required this.windowWidthSizeClass,
    required this.note,
  });

  final WindowWidthSizeClass windowWidthSizeClass;
  final NoteModel note;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _documentLayoutKey = GlobalKey();

  late TextEditingController _titleController;

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
    _titleController = TextEditingController(text: widget.note.title ?? "");
    _document = parseQuillDeltaDocument(widget.note.rawQuillDelta);
    // _document = MutableDocument(
    //   nodes: [
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 1"),
    //       metadata: const {NodeMetadata.blockType: header1Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 2"),
    //       metadata: const {NodeMetadata.blockType: header2Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 3"),
    //       metadata: const {NodeMetadata.blockType: header3Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 4"),
    //       metadata: const {NodeMetadata.blockType: header4Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 5"),
    //       metadata: const {NodeMetadata.blockType: header5Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText("Header 6"),
    //       metadata: const {NodeMetadata.blockType: header6Attribution},
    //     ),
    //     ParagraphNode(
    //       id: Editor.createNodeId(),
    //       text: AttributedText(
    //         "Elit nostrud qui veniam in laborum cupidatat sunt velit. Nostrud veniam qui exercitation dolor labore tempor laboris sint ea mollit nisi id. Et nisi irure ex Lorem amet minim. Ullamco do elit ullamco voluptate esse cillum elit exercitation commodo ut id. Minim pariatur occaecat excepteur ea aute velit irure esse culpa commodo cupidatat eu eu sint. Eiusmod id incididunt sit nulla. Excepteur eiusmod ea mollit id incididunt voluptate esse consectetur nostrud ipsum.",
    //       ),
    //     ),
    //   ],
    // );

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
              onPressed: Navigator.of(context).pop,
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

class _Controller with ChangeNotifier {
  _Test1State? _state;
  bool get isAttached => _state != null;

  bool _showNavigationBar = true;
  bool get showNavigationBar => _showNavigationBar;
  set showNavigationBar(bool value) {
    if (_showNavigationBar != value) {
      _showNavigationBar = value;
    }
    notifyListeners();
  }

  void _attach(_Test1State state) {
    _state = state;
  }

  void _detach(_Test1State state) {
    if (_state == state) _state = null;
  }
}

class Pane extends ImplicitlyAnimatedWidget {
  const Pane({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.shape,
    this.color,
    this.child,
  });

  final Color? color;
  final ShapeBorder? shape;

  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<Pane> createState() => _PaneState();
}

class _PaneState extends AnimatedWidgetBaseState<Pane> {
  Color? get _color => widget.color ?? _theme?.colorScheme.surface;
  ShapeBorder? get _shape => widget.shape ?? Shapes.medium;

  Tween<Color?>? _colorTween;
  Tween<ShapeBorder?>? _shapeTween;

  ThemeData? _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween =
        visitor(
              _colorTween,
              _color,
              (value) => ColorTween(begin: value as Color?),
            )
            as Tween<Color?>?;
    _shapeTween =
        visitor(
              _shapeTween,
              _shape,
              (value) => ShapeBorderTween(begin: value as ShapeBorder?),
            )
            as Tween<ShapeBorder?>?;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorTween?.evaluate(animation) ?? _color;
    final shape = _shapeTween?.evaluate(animation) ?? _shape;
    return Material(
      animationDuration: Duration.zero,
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      color: color,
      shape: shape,
      child: widget.child,
    );
  }
}

enum _SettingsCategory { account, general, appearance, tips, licenses, about }

@immutable
class _SettingsItem {
  const _SettingsItem({required this.headline, this.supportingText});

  final String headline;
  final String? supportingText;
}

class _SettingsLayout extends StatefulWidget {
  const _SettingsLayout({
    super.key,
    this.controller,
    this.padding = EdgeInsets.zero,
  });

  final _Controller? controller;
  final EdgeInsetsGeometry padding;

  @override
  State<_SettingsLayout> createState() => _SettingsLayoutState();
}

class _SettingsLayoutState extends State<_SettingsLayout> {
  final _listKey = GlobalKey();
  final _searchBarKey = GlobalKey();
  final _listNavigatorKey = GlobalKey<NavigatorState>();
  final _detailNavigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get _listNavigatorOrNull => _listNavigatorKey.currentState;
  NavigatorState get _listNavigator {
    final navigator = _listNavigatorOrNull;
    assert(navigator != null);
    return navigator!;
  }

  NavigatorState? get _detailNavigatorOrNull =>
      _detailNavigatorKey.currentState;
  NavigatorState get _detailNavigator {
    final navigator = _detailNavigatorOrNull;
    assert(navigator != null);
    return navigator!;
  }

  final List<_SettingsCategory> _pages = <_SettingsCategory>[];

  late WindowWidthSizeClass _windowWidthSizeClass;
  late WindowHeightSizeClass _windowHeightSizeClass;

  bool get _useTwoPanes =>
      _windowWidthSizeClass >= WindowWidthSizeClass.expanded;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _windowWidthSizeClass = WindowWidthSizeClass.of(context);
    _windowHeightSizeClass = WindowHeightSizeClass.of(context);
    _updateShowNavigationBar();
  }

  @override
  void didUpdateWidget(covariant _SettingsLayout oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _updateShowNavigationBar() {
    widget.controller?.showNavigationBar = _useTwoPanes || _pages.isEmpty;
  }

  void _setCategory(_SettingsCategory value) {
    if (_pages.lastOrNull == value) return;
    setState(() => _pages.add(value));
    _updateShowNavigationBar();
  }

  Widget _buildList(BuildContext context, bool keyed) {
    final theme = Theme.of(context);
    final selected =
        _windowWidthSizeClass >= WindowWidthSizeClass.expanded
            ? _pages.lastOrNull
            : null;
    return SafeArea(
      child: CustomScrollView(
        // key: _listKey,
        slivers: [
          SliverSearchView(
            key: keyed ? _searchBarKey : null,
            pinned: true,
            padding: const EdgeInsets.all(16),
            dockedViewMargin: EdgeInsets.all(16),
            flexibleSpace: Material(
              animationDuration: Duration.zero,
              type: MaterialType.canvas,
              clipBehavior: Clip.none,
              color: theme.colorScheme.surface,
              shape: Shapes.none,
            ),
            supportingText: "Search settings",
            suggestionsBuilder:
                (context) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Flex.vertical(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Symbols.search,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "No results for <query>",
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.list(
              children: [
                SettingsGroup(
                  children: [
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.account
                              ? () => _setCategory(_SettingsCategory.account)
                              : null,

                      selected: selected == _SettingsCategory.account,
                      leading: const CircleAvatar(
                        child: Icon(Symbols.account_circle),
                      ),
                      headline: Text("deminarchiver"),
                      supportingText: Text("Manage your account"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsGroup(
                  // supportingText: Text("General"),
                  children: [
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.general
                              ? () => _setCategory(_SettingsCategory.general)
                              : null,

                      selected: selected == _SettingsCategory.general,
                      leading: const Icon(Symbols.tune),
                      headline: Text("General"),
                      supportingText: Text("Behaviors"),
                    ),
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.appearance
                              ? () => _setCategory(_SettingsCategory.appearance)
                              : null,

                      selected: selected == _SettingsCategory.appearance,
                      leading: const Icon(Symbols.palette),
                      headline: Text("Appearance"),
                      supportingText: Text("Theme mode, colors, styles"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsGroup(
                  children: [
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.tips
                              ? () => _setCategory(_SettingsCategory.tips)
                              : null,
                      selected: selected == _SettingsCategory.tips,
                      leading: const Icon(Symbols.help),
                      headline: Text("Tips & support"),
                      supportingText: Text("Help articles"),
                    ),
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.licenses
                              ? () => _setCategory(_SettingsCategory.licenses)
                              : null,

                      selected: selected == _SettingsCategory.licenses,
                      leading: const Icon(Symbols.license),
                      headline: Text("Open source licenses"),
                    ),
                    SettingsGroupItem(
                      onPressed:
                          selected != _SettingsCategory.about
                              ? () => _setCategory(_SettingsCategory.about)
                              : null,

                      selected: selected == _SettingsCategory.about,
                      leading: const Icon(Symbols.info),
                      headline: Text("About"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPane(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        _windowWidthSizeClass <= WindowWidthSizeClass.compact
            ? Shapes.none
            : Shapes.medium;

    return Pane(
      duration: Durations.extralong2,
      curve: Easing.emphasized,
      shape: shape,
      child: _useTwoPanes ? _buildList(context, true) : const SizedBox.shrink(),
    );
  }

  Widget _buildDetailPane(BuildContext context) {
    final theme = Theme.of(context);
    final shape =
        _windowWidthSizeClass <= WindowWidthSizeClass.compact
            ? Shapes.none
            : Shapes.medium;
    final List<Page> pages = [
      MaterialRoutePage(
        key: const ValueKey("first"),
        canPop: false,
        child:
            _useTwoPanes
                ? Flex.vertical(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: 112,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: PathBorder(path: ShapePaths.cookie12(false)),
                          color: theme.colorScheme.secondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select something first",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
                : _buildList(context, true),
      ),
      ..._pages.mapIndexed(
        (index, category) => MaterialRoutePage(
          backgroundColor: theme.colorScheme.surface,
          key: ValueKey(index),
          arguments: category,
          // child: _buildDetail(context),
          child: _SettingsCategoryView(category: category),
        ),
      ),
    ];
    return Pane(
      duration: Durations.extralong2,
      curve: Easing.emphasized,
      shape: shape,
      child: Navigator(
        key: _detailNavigatorKey,
        observers: [],
        pages: pages,
        onDidRemovePage: (page) {
          final key = page.key;
          final args = page.arguments;
          if (key is ValueKey<int> &&
              args is _SettingsCategory &&
              _pages.elementAtOrNull(key.value) == args) {
            _scheduleSetState(() => _pages.removeAt(key.value));
            _updateShowNavigationBar();
            debugPrint("${_pages}");
          }
          // final args = page.arguments;
          // if (args is _SettingsCategory) {
          // }
        },
      ),
    );
  }

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(callback);
      });
    } else {
      if (mounted) setState(callback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler(
      onPopWithResult: (result) {
        if (_detailNavigator.canPop()) {
          _detailNavigator.pop(result);
        }
        // _pages.removeLast();
      },
      child: TwoPaneLayout(
        shift: _windowWidthSizeClass <= WindowWidthSizeClass.medium ? -1 : 0,
        flex:
            _windowWidthSizeClass <= WindowWidthSizeClass.expanded
                ? const TwoPaneLayoutFlexFactor(0)
                : const TwoPaneLayoutFlexFactor.fixedListWidth(412),
        padding: widget.padding,
        separator: const SizedBox(width: 24),
        list: _buildListPane(context),
        detail: _buildDetailPane(context),
      ),
    );
  }
}

class _SettingsCategoryView extends StatefulWidget {
  const _SettingsCategoryView({super.key, required this.category});

  final _SettingsCategory category;

  @override
  State<_SettingsCategoryView> createState() => _SettingsCategoryViewState();
}

class _SettingsCategoryViewState extends State<_SettingsCategoryView> {
  late ThemeData _theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
  }

  Widget _buildTopAppBar(BuildContext context) {
    final String headline = switch (widget.category) {
      _SettingsCategory.account => "My account",
      _SettingsCategory.general => "General",
      _SettingsCategory.appearance => "Appearance",
      _SettingsCategory.tips => "Tips & support",
      _SettingsCategory.licenses => "Licenses",
      _SettingsCategory.about => "About",
    };
    return SliverTopAppBar.large(
      automaticallyImplyLeading: false,
      leading: Align(
        child: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Symbols.arrow_back),
        ),
      ),
      pinned: true,
      title: Text(headline),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => switch (widget.category) {
    _SettingsCategory.account => [_SettingsAccountList()],
    _SettingsCategory.general => [
      SliverList.list(children: [ListTile(onTap: () {})]),
    ],
    _SettingsCategory.appearance => [_SettingsAppearanceList()],
    _ => [],
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [_buildTopAppBar(context), ..._buildSlivers(context)],
      ),
    );
  }
}

class _SettingsAccountList extends StatelessWidget {
  const _SettingsAccountList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    return SliverList.list(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            animationDuration: Duration.zero,
            type: MaterialType.card,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radii.large),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Flex.horizontal(
                      children: [
                        CircleAvatar(child: const Icon(Symbols.account_circle)),
                        const SizedBox(width: 16),
                        Flexible.expand(
                          child: Text(
                            "deminearchiver",
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CommonButton.filledTonal(
                    onPressed:
                        () => rootNavigator.push(
                          MaterialRoute(
                            builder: (context) => const AccountView(),
                          ),
                        ),
                    label: Text("Manage your Scribe account"),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

enum _SignInState { google, other }

class _AccountViewState extends State<AccountView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Repository _repository = Repository();
  final AuthController _controller = AuthController(
    webClientId:
        "73597778780-tuun4q8i2cbreah9603crvr4pss9cv84.apps.googleusercontent.com",
    iosClientId:
        "73597778780-8ognocm4dkbbk6p598afuun6cfkeaqth.apps.googleusercontent.com",
    redirectTo: "scribe://auth",
  );

  StreamSubscription<AuthState>? _subscription;

  StreamSubscription<UserModel?>? _userSubscription;

  final _userController = BehaviorSubject<UserModel?>();

  bool _signingInWithGoogle = false;
  bool _signingInWithOther = false;
  bool get _signingIn => _signingInWithGoogle || _signingInWithOther;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final users = _repository.subscribeToRealtime<UserModel>(
        query: Query.where("id", user.id),
      );
      _userSubscription = users
          .map((data) => data.singleOrNull)
          .listen(_userListener);
    } else {
      _userController.add(null);
    }
    _subscription = _supabase.auth.onAuthStateChange.listen(_authListener);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AccountView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  void _authListener(AuthState state) {
    if (state.event == AuthChangeEvent.signedIn && _signingIn) {
      setState(() {
        _signingInWithGoogle = false;
        _signingInWithOther = false;
      });
    }
    final session = state.session;
    _userSubscription?.cancel();
    if (session != null) {
      final users = _repository.subscribeToRealtime<UserModel>(
        query: Query.where("id", session.user.id),
      );
      _userSubscription = users
          .map((data) => data.singleOrNull)
          .listen(_userListener);
    } else {
      _userController.add(null);
    }
  }

  void _userListener(UserModel? data) {
    _userController.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverTopAppBar.large(title: Text("Manage account")),
            StreamBuilder(
              stream: _userController.stream,
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (user != null) {
                  return SliverList.list(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          foregroundImage:
                              user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!.toString())
                                  : null,
                          child: const Icon(Symbols.account_circle),
                        ),
                        title: Text(user.name),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton(
                          onPressed: () => _supabase.auth.signOut(),
                          icon: const Icon(Symbols.logout),
                          label: Text("Logout"),
                        ),
                      ),
                    ],
                  );
                } else {
                  return SliverList.list(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Accordion(
                          items: [
                            AccordionItem(
                              variant: AccordionItemVariant.secondary,
                              onPressed:
                                  !_signingIn
                                      ? () {
                                        setState(
                                          () => _signingInWithGoogle = true,
                                        );
                                        _controller.signInWithGoogle();
                                      }
                                      : null,
                              expanded: false,
                              leading: const CircleAvatar(
                                child: Icon(SimpleIcons.google),
                              ),
                              headline: Text("Sign in with Google"),
                              supportingText: const Text(
                                "The recommended way of authorizing",
                              ),
                              child: null,
                            ),
                            // AccordionItem.secondary(
                            //   expanded: false,
                            //   headline: Text("Sign in with Google"),
                            //   child: null,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AuthController with ChangeNotifier {
  AuthController({
    required this.webClientId,
    required this.iosClientId,
    this.redirectTo,
  });

  final SupabaseClient _supabase = Supabase.instance.client;

  String? redirectTo;
  String webClientId;
  String iosClientId;

  Future<bool> signInWith(OAuthProvider provider) {
    return switch (provider) {
      OAuthProvider.google => signInWithGoogle(),
      OAuthProvider.discord => signInWithDiscord(),
      OAuthProvider.github => signInWithGithub(),
      OAuthProvider.notion => signInWithNotion(),
      OAuthProvider.figma => signInWithFigma(),
      _ => Future.value(false),
    };
  }

  Future<bool> signInWithGoogle() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android || TargetPlatform.iOS:
        return _signInWithGoogleNative()
            .then((_) => true)
            .catchError((_) => false);
      default:
        return _signInWithGoogleOAuth();
    }
  }

  Future<void> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw "No Access Token found.";
    }
    if (idToken == null) {
      throw "No ID Token found.";
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<bool> _signInWithGoogleOAuth() {
    return _signInWithOAuth(OAuthProvider.google);
  }

  Future<bool> signInWithDiscord() {
    return _signInWithOAuth(OAuthProvider.discord);
  }

  Future<bool> signInWithGithub() {
    return _signInWithOAuth(OAuthProvider.github);
  }

  Future<bool> signInWithNotion() {
    return _signInWithOAuth(OAuthProvider.notion);
  }

  Future<bool> signInWithFigma() {
    return _signInWithOAuth(OAuthProvider.figma);
  }

  Future<bool> _signInWithOAuth(OAuthProvider provider) async {
    return _supabase.auth
        .signInWithOAuth(provider, redirectTo: redirectTo)
        .then((_) => true)
        .catchError((_) => false);
  }

  Future<void> signOut([SignOutScope scope = SignOutScope.local]) {
    return _supabase.auth.signOut(scope: scope);
  }
}

extension _UserExtension on User {
  OAuthProvider? get providerOrNull {
    final provider = appMetadata["provider"];
    if (provider != null && provider is String) {
      return OAuthProvider.values.firstWhereOrNull(
        (value) => value.name == provider,
      );
    }
    return null;
  }

  Set<OAuthProvider> get providers {
    final providers = appMetadata["providers"];
    if (providers != null && providers is List) {
      final Set<OAuthProvider> values = <OAuthProvider>{};
      for (final name in providers) {
        if (name is! String) continue;
        final value = OAuthProvider.values.firstWhereOrNull(
          (value) => value.name == name,
        );
        if (value != null) values.add(value);
      }
      return UnmodifiableSetView(values);
    }

    final provider = providerOrNull;
    return UnmodifiableSetView({if (provider != null) provider});
  }
}

class _SettingsAppearanceList extends StatelessWidget {
  const _SettingsAppearanceList({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Settings.of(context);
    return SliverList.list(
      children: [
        SwitchListTile(
          value: settings.useDynamicColor,
          onChanged: (value) => settings.useDynamicColor = value,
          secondary: const Icon(Symbols.brush),
          title: Text("Use Dynamic color"),
        ),
        SwitchListTile(
          value: settings.useSystemBrightness,
          onChanged: (value) => settings.useSystemBrightness = value,
          secondary: const Icon(Symbols.auto_mode),
          title: Text("Follow system brightness"),
          subtitle: Text("Make current theme match the system setting"),
        ),
        ListTile(
          enabled: !settings.useSystemBrightness,
          leading: const Icon(Symbols.brightness_6),
          title: Text("Custom brightness"),
          subtitle: Text("Override system theme brightness value"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SegmentedButton<Brightness>(
            onSelectionChanged:
                !settings.useSystemBrightness
                    ? (value) => settings.brightness = value.first
                    : null,
            selected: {settings.brightness},
            segments: const [
              ButtonSegment(
                value: Brightness.light,
                icon: Icon(Symbols.light_mode),
                label: Text("Light"),
              ),
              ButtonSegment(
                value: Brightness.dark,
                icon: Icon(Symbols.dark_mode),
                label: Text("Dark"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    this.supportingText,
    this.children = const [],
  });

  final Widget? supportingText;
  final List<SettingsGroupItem> children;

  Widget _buildItem(BuildContext context, SettingsGroupItem item, int index) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    const int firstIndex = 0;
    final int lastIndex = children.length - 1;
    final isFirst = index == firstIndex;
    final isLast = index == lastIndex;

    final backgroundColor =
        item.selected
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest;
    final foregroundColor =
        item.selected
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurface;
    final secondaryForegroundColor =
        item.selected
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant;

    return Material(
      animationDuration: Duration.zero,
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radii.large : Radii.extraSmall,
          bottom: isLast ? Radii.large : Radii.extraSmall,
        ),
      ),
      child: InkWell(
        onTap: item.onPressed,
        onLongPress: item.onLongPress,
        overlayColor: WidgetStateLayerColor(
          foregroundColor,
          opacity: stateTheme.stateLayerOpacity,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Flex.horizontal(
              spacing: 16,
              children: [
                if (item.leading != null)
                  IconTheme.merge(
                    data: IconThemeData(color: foregroundColor),
                    child: item.leading!,
                  ),
                Flexible.expand(
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DefaultTextStyle.merge(
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: foregroundColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: item.headline,
                      ),
                      if (item.supportingText != null)
                        DefaultTextStyle.merge(
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: secondaryForegroundColor,
                          ),
                          child: item.supportingText!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = Flex.vertical(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children:
          children
              .mapIndexed((index, item) => _buildItem(context, item, index))
              .toList(),
    );
    if (supportingText != null) {
      final theme = Theme.of(context);
      return Flex.vertical(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DefaultTextStyle.merge(
              style: theme.textTheme.labelLarge!.copyWith(
                color: theme.colorScheme.secondary,
              ),
              child: supportingText!,
            ),
          ),
          list,
        ],
      );
    }
    return list;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<List<SettingsGroupItem>>("children", children),
    );
  }
}

@immutable
class SettingsGroupItem with Diagnosticable {
  const SettingsGroupItem({
    this.selected = false,
    this.onPressed,
    this.onLongPress,
    this.leading,
    required this.headline,
    this.supportingText,
  });

  final bool selected;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? leading;
  final Widget headline;
  final Widget? supportingText;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>("selected", selected));
    properties.add(DiagnosticsProperty<VoidCallback?>("onPressed", onPressed));
    properties.add(
      DiagnosticsProperty<VoidCallback?>("onLongPress", onLongPress),
    );
    properties.add(DiagnosticsProperty<Widget?>("leading", leading));
    properties.add(DiagnosticsProperty<Widget>("headline", headline));
    properties.add(
      DiagnosticsProperty<Widget?>("supportingText", supportingText),
    );
  }
}
